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
			
		for (file in files)
		{
			var bytes:Bytes = file.isDirectory ? null: neko.io.File.getBytes(file.nativePath);
			var stat:FileStat = FileSys.stat(file.nativePath);
			var name:String = dir.getRelativePath(file) + (file.isDirectory ? File.seperator : "");
			var entry = { fileTime:stat.mtime, fileName:name, data:bytes };
			
			//neko.Lib.print("Added " + entry.fileName + "\n");
			entries.push(entry);
		}
		
		return entries;
	}
}