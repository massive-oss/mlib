/****
* Copyright 2012 Massive Interactive. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE "AS IS" AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Massive Interactive.
* 
****/

package massive.neko.util;

import neko.Lib;
import massive.neko.io.FileSys;
import neko.io.Path;

import neko.zip.Reader;
import neko.zip.Writer;
import haxe.io.Bytes;

import massive.neko.io.File;
import neko.FileSystem;

class ZipUtil
{
	public static function zipDirectory(file:File, sourceDir:File, ?filter:EReg, ?exclude:Bool=false):Void
	{
		if(!sourceDir.exists || !sourceDir.isDirectory) throw "Error: source isn't a valid directory";
		
		// set cwd to directory path
		
		var old:File = File.current;
		
		var pwd:String = FileSys.getCwd();
		
		FileSys.setCwd(sourceDir.nativePath);
		
		var cwd:String = FileSys.getCwd();

		// get entries
		var entries:Array<Dynamic> = convertDirectoryToZipEntries(sourceDir, filter, exclude);
		// zip entries
		
		if(!file.exists)
		{
			file.writeString("");
		}
		
		var zip = neko.io.File.write(file.nativePath, true);
		neko.zip.Writer.writeZip(zip, entries, -1);
		zip.close();
		
		// return to previous working directory
		FileSys.setCwd(pwd);

	}
	
	public static function convertDirectoryToZipEntries(dir:File, ?filter:EReg, ?exclude:Bool=false):Array<Dynamic>
	{
		var files:Array<File> = dir.getRecursiveDirectoryListing(filter, exclude);

		var entries:Array<Dynamic> = [];

		var date = Date.now();
			
		for (file in files)
		{
			var bytes:Bytes = file.isDirectory ? null: neko.io.File.getBytes(file.nativePath);
			var name:String = dir.getRelativePath(file) + (file.isDirectory ? File.seperator : "");
			var entry = { fileTime:date, fileName:name, data:bytes };
			
			//neko.Lib.print("Added " + entry.fileName + "\n");
			entries.push(entry);
		}
		
		return entries;
	}
}