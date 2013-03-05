/****
* Copyright 2013 Massive Interactive. All rights reserved.
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

package massive.sys.io;

import haxe.io.Path;
import Sys;

import massive.haxe.log.Log;
import massive.sys.util.PathUtil;
import haxe.PosInfos;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>;
#end
class File
{	
	public static var seperator(get_seperator, null):String;
	public static var current(get_current, null):File;

	private static var tempCount:Int = 0;
	private static var temp:StringMap<File> = new StringMap();
	
	private static function get_current():File
	{
		return new File(FileSys.getCwd());
	}
	
	
	private static function get_seperator():String
	{
		if(seperator == null)
		{
			seperator = FileSys.isWindows ? "\\" : "/";
		}
		
		return seperator;
	}


	
	public static function create(path:String, ?file:File=null, ?createImmediately:Bool = false, ?posInfos:PosInfos):File
	{
			
		
		if(FileSys.isWindows && path.indexOf(":") == 1 && path.lastIndexOf("/") == path.length-1)
		{
			path = path.substr(0, -1) + "\\";
		}
		
		if(PathUtil.isAbsolutePath(path))
		{
			return new File(path, createImmediately);
		}
		else if(file != null)
		{
			try
			{
				return file.resolvePath(path, createImmediately);	
			}
			catch(e:Dynamic)
			{
				throw new FileException("Unable to resolve path ( " + path + " ) aginst file ( " + file.nativePath + " ) " + e); 
			}
			
		}
		else if(path == ".")
		{
			return File.current;
		}	
		else
		{
			throw new FileException("Path isn't absolute and no reference file provided: " + path);	
		}
		return null;
	}
	
	
	
	/**
	*  creates a temporary file in the current directory.
	*/
	public static function createTempFile(?content:String = "", ?extension:String = ".tmp"):File
	{
		var name:String = ".tmp_" + Std.string(tempCount++) + extension;
		var file:File = current.resolvePath(name);
		file.writeString(content);

		temp.set(name, file);
		return file;
	}
	
	/**
	*  creates a temporary directory in the current directory.
	*/
	public static function createTempDirectory():File
	{
		
		
		var name:String = "tmp_" + Std.string(tempCount++) + seperator;
		var file:File = current.resolveDirectory(name);
		
		file.createDirectory(true);
		
		temp.set(name, file);
		return file;
	}
	

	
	/**
	*  deletes all temporary files and directories created during this session.
	*/
	public static function deleteTempFiles():Void
	{
		var file:File;
		for(key in temp.keys())
		{

			if(temp.exists(key))
			{
				file = temp.get(key);
				
				if(file.isDirectory)
				{
					file.deleteDirectory(true);
				}
				else
				{
					file.deleteFile();
				}
			}
		}
		temp = new StringMap();
	}
	
	/**
	*  @return true if file exists.
	*/
	public var exists(get_exists, null):Bool;
	
	/**
	*  @return true if it is a valid directory path. This is different from sys.FileSystem.isDirectory() that throws error if the path doesn't exist.
	*/
	public var isDirectory(get_isDirectory, null):Bool;
	
	public var isFile(get_isFile, null):Bool;
	public var isUnknown(get_isUnknown, null):Bool;

	
	public var isNativeDirectory(get_isNativeDirectory, null):Bool;
	
	/**
	*  @return full native os path
	*/
	public var nativePath(get_nativePath, null):String;
	
	/**
	*  @return filename.ext if a file, returns null if a directory
	*/
	public var fileName(get_fileName, null):String;
	
	/**
	*  @return name of file without extension (if a file) and directory name if a directory
	*/
	public var name(get_name, null):String;
	
	/**
	*  @return the file extension or null if a directory
	*/
	public var extension(get_extension, null):String;
	
	

	/**
	*  @return the directory of file, or the parent directory of a directory.
	*/
	public var parent(get_parent, null):File;
	
	
	/**
	*  @return the original string passed through in the constructor
	*/
	private var raw:String;

	/**
	*  @return a neko path instance for the file 
	*/
	public var path(default, null):Path;
	
	/**
	*  @return true if directory  is empty (or if it is a file);
	*/
	public var isEmpty(get_isEmpty, null):Bool;
	
	
	private var type:FileType;
	

	private function new(filePath:String, ?fileType:FileType=null, ?createImmediately:Bool=false)
	{
		seperator = get_seperator();
		setInternalPath(filePath, fileType);
		if(createImmediately) 
		{
			if(isDirectory) createDirectory();
			else if(isFile) createFile();
		}
	}

	private function setInternalPath(filePath:String, ?fileType:FileType=null)
	{
		filePath = PathUtil.cleanUpPath(filePath);
		type = fileType;

		var pathExists:Bool = FileSys.exists(filePath);

		if(pathExists)
		{
			var existingType:FileType = FileSys.isDirectory(filePath) ? FileType.DIRECTORY : FileType.FILE;

			if(type == null)
			{
				type = existingType;
			}
			else if(type != existingType)
			{
				throw new FileException("Specified type doesn't match file/dir in system: " + [type, existingType], this);
		
			}

		}

		var segments:Array<String> = filePath.split("\\").join("/").split("/");
		var lastSegment = segments[segments.length-1];

		var dot = lastSegment.lastIndexOf(".");

		if(type == null)
		{
			if(dot == -1)
			{
				type = FileType.DIRECTORY;
			}
			else if(dot > 0)
			{
				//assume it is a file aa.bb
				type = FileType.FILE;
			}
			else
			{
				//not sure - .svn could be a folder or a file
				type = FileType.UNKNOWN;
			}

		}
		
		raw = filePath;
		
		if(type == FileType.DIRECTORY && raw.lastIndexOf(seperator) != raw.length-1)
		{
			raw += seperator;
		}
		
		
		path = new Path(raw);
	}


	
	public function toString():String
	{
		return nativePath;
	}
	
	/**
	*  @param a relative path to resolve (e.g. "sub/example.txt")
	*  @return a new File instance
	*/
	
	public function resolvePath(value:String, ?createImmediately:Bool = false, ?fileType:FileType=null, ?posInfos:PosInfos):File
	{
	
		if(fileType == FileType.DIRECTORY)	
		{
			var c:String = value.substr(-1);
			if(c != "/" && c != "\\")
			{
				value += "/";
			}
		}
	
		var file:File;
		
		if(PathUtil.isAbsolutePath(value))
		{
			file =  new File(value, fileType);
		}
		else if(value == ".")
		{
			if(isFile)
			{
				return this.parent;
			}
			else
			{
				return this;
			}
			
		}
		else
		{
			var p:File = this;
			
			if(isFile) p = this.parent;
			
			if(value.indexOf("./") == 0)
			{
				value = value.substr(2);	
			}
			
			
			while(value.indexOf("../") == 0)
			{
				p = p.parent;
				
				if(p == null)
				{
					throw new FileException("Invalid path: " + value, this);
				}
				value = value.substr(3);
			}
					

			file = new File(p.path.dir + seperator + value, fileType);
		}
		
		if(createImmediately && !file.exists)
		{
			if(file.isDirectory) file.createDirectory(true);
			else file.createFile();
		
		}
		if(isUnknown)
		{
			setInternalPath(raw, FileType.DIRECTORY);
		}
		return file;
	}
	
	public function resolveDirectory(value:String, ?createImmediately:Bool = false):File
	{
		if(seperator == "/")
		{
			value = value.split("\\").join(seperator);
		}
		else
		{
			value = value.split("/").join(seperator);
		}
		
		if(value.lastIndexOf(seperator) != value.length-1)
		{
			value += seperator;
		}
		
		return resolvePath(value, createImmediately, FileType.DIRECTORY);
	}
	
	public function resolveFile(value:String, ?createImmediately:Bool = false):File
	{
		
		return resolvePath(value, createImmediately, FileType.FILE);
	}
	
	
	/**
	*  @param ref:File - a reference file to determine the path to
	*  @param useDotDot:Bool - uses ../../ syntax if true. Otherwise returns null if ref file path is not inside same directory as file
	*  @return a relative path string
	*/
	
	public function getRelativePath(ref:File, useDotDot:Bool = true):String
	{
		var paths:Array<String> = path.dir.split(seperator);
		var refPaths:Array<String> = ref.path.dir.split(seperator);
		
	
		
		var path:String = "";
		var pathBefore:String = "";
		
		var isCommonPath:Bool = true;
		
		var length:Int = paths.length;
		var refLength:Int = refPaths.length;	
		
		var i:Int = 0;
		var l:Int = Std.int(Math.max(length, refLength));
		
		//if on completely different drives
		if(nativePath.charAt(0) != ref.nativePath.charAt(0))
		{
			return ref.nativePath;
		}
		
		if(!isDirectory)
		{
			pathBefore = "./";
		}


		while(i < l)
		{
			if(paths[i] == refPaths[i] && isCommonPath)
			{
				path += "";
				i++;
				continue;
			}
			
			isCommonPath = false;

			if(paths[i] != null && refPaths[i] != null)
			{
				if(!useDotDot) return null;
				
				if(path == "")
				{
					path += refPaths[i];	
				}
				else
				{
					path += "/" + refPaths[i];
				}
				
				if(pathBefore == ".") pathBefore += "/";
				
				pathBefore += "../";
		
			}
			else if(paths[i] == null)
			{
				if(path == "")
				{
					path += refPaths[i];	
				}
				else
				{
					path += "/" + refPaths[i];	
				}
				
			}
			else
			{
				if(!useDotDot) return null;
				pathBefore +=  "../";
			}
			i++;
		}

		if(!ref.isDirectory)
		{
			if(path == "")
			{
				path += ref.fileName;	
			}
			else
			{
				path += "/" + ref.fileName;	
			}
		}
		
		return pathBefore + path;
	}
	
	
	/**
	*  @returns a copy of the current file instance 
	*/
	public function clone():File
	{
		return new File(nativePath);
	}
	
	/**
	* Creates the current directory in the filesystem
	*  
	*  @returns true if directory is created
	* @returns false if directory already exists or if file isn't a directory
	*/
	public function createDirectory(?force:Bool = false, ?posInfos:PosInfos):Bool
	{
		if(isFile)
		{
			throw new FileException("Cannot call createDirectory for a file ", this);
		}
		if(parent != null && !parent.exists) parent.createDirectory(true);
	
		if(force && exists)
		{
			if(isNativeDirectory) deleteDirectory(true);
			else deleteFile();
		}

		if(!exists && (isDirectory || isUnknown))
		{
			try
			{
				FileSys.createDirectory(nativePath);	
			
			}
			catch(e:Dynamic)
			{
				Log.error("Error creating directory \n" + posInfos + "\n" + toDebugString() + "\n" + e);
				return false;
			}	
				
			if(isUnknown)
			{
				setInternalPath(raw, FileType.DIRECTORY);
			}
			return true;
		}
		return false;
	}
	
	/**
	*  deletes the current directory 
	*  @param deleteContents: set to true to allow deleting of directory that contains files/directories
	*  @returns true if directory was removed
	*  @returns false if directory couldn't be removed because it contains files
	*/
	
	public function deleteDirectory(?deleteContents:Bool=true, ?posInfos:PosInfos):Bool
	{
		if(!exists) return false;
		
		if(!isDirectory)
		{
			throw new FileException("cannot deleteDirectory for type: " + type, this);
		}
	
		if(deleteContents == false && !isEmpty)
		{
			return false;
		}
		
		deleteDirectoryContents();
		
		if(exists && FileSys.isDirectory(nativePath))
		{
			try
			{
				FileSys.deleteDirectory(nativePath);
			}
			catch(e:Dynamic)
			{
				Log.error("Error deleting directory \n" + posInfos + "\n" + toDebugString() + "\n" + e + "\n   " + FileSys.readDirectory(nativePath).join("\n   "));			
				return false;
			}
			
		}
		
		return true;
	}
	
	/**
	*  deletes the contents of the current directory 
	*/

	public function deleteDirectoryContents(?filter:EReg=null, ?exclude:Bool=false):Bool
	{
		if(!isDirectory) return false;		
		if(!exists) return false;
		
		var files:Array<File> = getRecursiveDirectoryListing(filter, exclude);
		
		for(file in files)
		{
			if(file.isDirectory)
			{
				file.deleteDirectory(true);
			}
			else
			{
				file.deleteFile();
			}
		}
		
		return true;
	}
	
	
	public function createFile(?value:String=""):Void
	{
		if(isDirectory)
		{
			throw new FileException("Cannot call createFile for a directory object.", this);
		}
		else if(isFile && exists)
		{
			throw new FileException("File already exists", this);
		}
		
		if(isUnknown)
		{
			setInternalPath(raw, FileType.FILE);
		}
		
		writeString(value);
		
		
	}
	
	/**
	* deletes the current file 
	*/
	public function deleteFile():Void
	{
		try
		{
			if(exists && !isNativeDirectory)
			{
				FileSys.deleteFile(nativePath);
			}
		
		}
		catch(e:Dynamic)
		{
			throw new FileException("Error deleting directory (" + e + ")", this);
		}
	}
	

	/**
	*  copies the current file to a destination
	*  @param dst:File - a destination directory (or file if copying a single file);
	*  @param overwrite:Bool - flag to decide whether or not to copy over existing files
	*  @param filter:EReg - optional filter for directory contents (if no filter is set it wil exclude .svn and .DS_STORE by default);
	*  @param exclude:Bool - falg whether or not filter is used to include or exclude files
	*/
	public function copyTo(dst:File, ?overwrite:Bool=true, ?filter:EReg=null, ?exclude:Bool=false):Void
	{
		if(!exists)
		{
			throw new FileException("Cannot copy a file or directory that doesn't exist.", this);
		}
		if(isDirectory && !dst.isDirectory)
		{
			throw new FileException("Cannot copy a directory to a file (" + dst + ")", this);
		}
		
		
		if(filter == null)
		{
			filter = ~/\.(svn)|(DS_Store)/;
			exclude = true;
		}
	
		var targetDir:File = null;
		var targetName:String = null;
		var targetFile:File = null;
		
		if(dst.isDirectory)
		{
			targetDir = dst;	
		}
		else
		{
			targetDir = dst.parent;	
			targetName = dst.fileName;
			targetFile = dst;
		}
		
		if(!targetDir.exists) targetDir.createDirectory();
		
		if(isDirectory)
		{	
			var files:Array<File> = getRecursiveDirectoryListing(filter, exclude, true);
			
			for(file in files)
			{
				targetName = getRelativePath(file);
				targetFile = file.isDirectory ? targetDir.resolveDirectory(targetName) : targetDir.resolveFile(targetName);
			
				if(targetFile.isDirectory)
				{
					if(!targetFile.exists) targetFile.createDirectory();
				}
				else
				{
					if(!targetFile.exists || overwrite == true)
					{
						sys.io.File.copy(file.nativePath, targetFile.nativePath);
					}
				}
			}
		}
		else
		{
			if(targetName == null) targetName = fileName;
			if(targetFile == null) targetFile = targetDir.resolvePath(targetName);

			if(!targetFile.exists || overwrite == true)
			{
				sys.io.File.copy(nativePath, targetFile.nativePath);
			}
		}	
	}
	
	
	/**
	*  copies the current file/directory into another directory (using the same name as the current directory)
	*  @param dst:File - a destination parent directory
	*  @see File#copyTo
	*/
	public function copyInto(dst:File, ?overwrite:Bool=true, ?filter:EReg=null, ?exclude:Bool=false):Void
	{
		if(!dst.isDirectory)
		{
			throw new FileException("Cannot copy a directory to a file (" + dst +")", this);
		}
		
		if(isDirectory)
		{
			copyTo(dst.resolveDirectory(name), overwrite, filter, exclude);
		}
		else
		{
			copyTo(dst, overwrite, filter, exclude);
		}
	}
	
	/**
	*  copies the current file to a destination and then deletes the current version
	*  @see File#copyTo
	**/
	
	public function moveTo(dst:File, ?overwrite:Bool=true, ?filter:EReg=null, ?exclude:Bool=false):Void
	{
		copyTo(dst, overwrite, filter, exclude);
		
		if(isDirectory)
		{		
			deleteDirectory(true);
		}
		else
		{
			deleteFile();
		}
				
	}
	
	/**
	*  moves the current file/directory into another directory (using the same name as the current directory)
	*  @param dst:File - a destination parent directory
	*  @see File#moveTo
	*/
	public function moveInto(dst:File, ?overwrite:Bool=true, ?filter:EReg=null, ?exclude:Bool=false):Void
	{
		if(!dst.isDirectory)
		{
			throw new FileException("Cannot move a directory to a file (" + dst + ")", this);
			return;
		}

		if(isDirectory)
		{
			moveTo(dst.resolveDirectory(name), overwrite, filter, exclude);
		}
		else
		{
			moveTo(dst, overwrite, filter, exclude);
		}	
	}
	
	/**
	*  Writes a string to the current file. Creates the file if it doesn't exist yet.
	*  @param value:String - contents to write;
	*  @param binary:Bool - flag to decide whether to write as binary or not
	*/
	public function writeString(value:Dynamic, ?binary:Bool=true):Void
	{
		if(isDirectory)
		{
			throw new FileException("Cannot write string to a file object.", this);
		}
		
		if(!parent.exists) parent.createDirectory(true);
		
		
		if(isUnknown)
		{
			setInternalPath(raw, FileType.FILE);
		}
	
		var out = sys.io.File.write(nativePath, binary);
		out.writeString(Std.string(value));
		out.flush();
		out.close();
	}
	
	/**
	*  Reads the contents of a file as a string
	*/
	public function readString():String
	{
		if(!exists && isFile)
		{
			return null;
			//throw new FileException("File doesn't exist.", this);
		}
		
		if(!exists || !isFile)
		{
			throw new FileException("File isn't of type file. Cannot load string content.", this);
		}
		

		try
		{
			return sys.io.File.getContent(nativePath);
		}
		catch(e:Dynamic)
		{
			throw new FileException("Unknown error (" + e + ")", this);
		}
		
	
	}
	

	/**
	*  returns an list of files and subdirectories in the current directory.
	*/
	public function getDirectoryListing(?filter:EReg=null, ?exclude:Bool=false):Array<File>
	{
		if(!isDirectory)
		{
			throw new FileException("Cannot get directory listing for a file object.", this);
		}
		if(!exists)
		{
			return [];
		}

		var paths:Array<String> = FileSys.readDirectory(nativePath);
		var files:Array<File> = [];	
			
			
		if(filter == null) filter = ~/./;	
		var include:Bool;
		for(p in paths)
		{
			include = filter.match(p);
			if(exclude) include = !include;
			
			if(include)
			{
				files.push(resolvePath(p));		
			}
		}
		
		return files;
	}
	
	/**
	*  returns an list of files and subdirectories. This method is recursive.
	*  @param filter:EReg - optional filter for directory contents (if no filter is set it wil exclude .svn and .DS_STORE by default);
	*  @param exclude:Bool - flag whether or not filter is used to include or exclude files
	*  @param orderDirectoriesBeforeFiles:Bool - flag whether or not to list sub directories before or after their children.
	*         This is useful to get directories after when deleting and before when copying
	*  @param rootDir - used to run regex filter based on relative paths from a specified directory
	*/
	public function getRecursiveDirectoryListing(?filter:EReg=null, ?exclude:Bool=false, ?orderDirectoriesBeforeFiles:Bool=false, ?rootDir:File=null):Array<File>
	{
		var files:Array<File> = [];
		var localFiles:Array<File> = getDirectoryListing();
		var includeInFiles:Bool;
		
		if(filter == null) filter = ~/./;
		
		if(rootDir == null) rootDir = this;
		
		for(file in localFiles)
		{
			includeInFiles = filter.match(rootDir.getRelativePath(file));
			if(exclude) includeInFiles = !includeInFiles;
			

			if(file.isDirectory)
			{
				if(orderDirectoriesBeforeFiles && includeInFiles) files.push(file);
				
				files = files.concat(file.getRecursiveDirectoryListing(filter, exclude, orderDirectoriesBeforeFiles, rootDir));
				
				if(!orderDirectoriesBeforeFiles && includeInFiles) files.push(file);
			}
			else if(includeInFiles)
			{
				files.push(file);
			}
			
			

		}
		return files;
	}
	
	
	//////// PRIVATE /////////////
	
	private function get_exists():Bool
	{
		if(FileSys.isWindows && isDirectory)
		{
			return FileSys.exists(nativePath.substr(0,-1));
		}	
		return FileSys.exists(nativePath);
	}
	
	
	private function get_isDirectory():Bool
	{
		return type == FileType.DIRECTORY;
		
	}
	
	
	private function get_isNativeDirectory():Bool
	{
		if(exists)
		{	
			return FileSys.isDirectory(nativePath);
		}	
	
		return false;
	}
	
	private function get_isFile():Bool
	{
		return type == FileType.FILE;
	}
	
	private function get_isUnknown():Bool
	{
		return type == FileType.UNKNOWN;
	}

	
	private function get_name():String
	{
		switch(type)
		{
			case DIRECTORY: return path.dir.split(seperator).pop();
			case FILE: return path.file;
			case UNKNOWN: return path.toString().split(seperator).pop();
		}
		
		return null;
	
	}
	
	private function get_fileName():String
	{
		var r = switch(type)
		{
			case DIRECTORY: null;
			case FILE: name + (extension != null ? "." + extension : "");
			case UNKNOWN: name;
		}
		return r;
	}
	
	
	private function get_extension():String
	{
		var r = switch(type)
		{
			case FILE: return path.ext;
			default: return null;
		}
		return r;
	}
	
	private function get_nativePath():String
	{
		var p:String =  path.toString();
		return p;
	}
	
	
	private function get_parent():File
	{
		if(isDirectory)
		{
			var a:Array<String> = path.dir.split(seperator);
			a.pop();
			
			if(a.length > 0)
			{
				return new File(a.join(seperator));
			}	
		}
		else
		{
			return  new File(path.dir);
		}
		
		return null;
	}
	
	/**
	*  returns an list of files and subdirectories in the current directory.
	*/
	private function get_isEmpty():Bool
	{
		if(!exists) return false;
		if(!isDirectory) return true;
		
		var paths:Array<String> = FileSys.readDirectory(nativePath);
		if(paths == null || paths.length == 0)
		{
			return true;
		}
		return false;
	}
	
	
	
	public function toDebugString():String
	{
		var s:String = "";
		s += "\n   " + toString();
		s += "\n   fileName: " + fileName;
		s += "\n   exists: " + exists;
		s += "\n   type: " + type;
		return s;

	}
}


enum FileType {
	DIRECTORY;
	FILE;
	UNKNOWN;
}
