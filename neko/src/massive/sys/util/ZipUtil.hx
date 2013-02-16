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

package massive.sys.util;

import Sys;
import massive.sys.io.FileSys;
import haxe.io.Path;

import haxe.zip.Reader;
import haxe.zip.Writer;
import haxe.io.Bytes;

import massive.sys.io.File;
import sys.FileSystem;

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
		var entries:List<haxe.zip.Entry> = convertDirectoryToZipEntries(sourceDir, filter, exclude);
		// zip entries
		
		if(!file.exists)
		{
			file.writeString("");
		}
		
		var zip = sys.io.File.write(file.nativePath, true);
		var writer = new haxe.zip.Writer(zip);
		writer.write(entries);
		zip.close();
		
		// return to previous working directory
		FileSys.setCwd(pwd);

	}
	
	public static function convertDirectoryToZipEntries(dir:File, ?filter:EReg, ?exclude:Bool=false):List<haxe.zip.Entry>
	{
		var files:Array<File> = dir.getRecursiveDirectoryListing(filter, exclude);

		var entries:List<haxe.zip.Entry> = new List();

		var date = Date.now();
			
		for (file in files)
		{
			var stat = sys.FileSystem.stat(file.nativePath);
			var bytes:Bytes = file.isDirectory ? null: sys.io.File.getBytes(file.nativePath);
			var name:String = dir.getRelativePath(file) + (file.isDirectory ? File.seperator : "");
			var entry = {
				fileTime:date,
				fileName:name,
				fileSize:stat.size,
				data:bytes,
				dataSize:bytes.length,
				compressed:true,
				crc32:1
			}
			
			//Sys.print("Added " + entry.fileName + "\n");
			entries.add(entry);
		}
		
		return entries;
	}
}