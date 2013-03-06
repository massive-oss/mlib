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

#if haxe_209
import sys.FileSystem;
import sys.FileStat;
#else
import sys.FileSystem;
#end

class FileSys
{
	public static var isWindows(get_isWindows, null):Bool;
	public static var isMac(get_isMac, null):Bool;
	public static var isLinux(get_isLinux, null):Bool;
	
	private static function get_isWindows():Bool
	{
		if(isWindows == null)
		{
			isWindows = Sys.systemName().indexOf("Win") == 0;
		}
		return isWindows;
	}
	
	private static function get_isMac():Bool
	{
		if(isMac == null)
		{
			isMac = Sys.systemName().indexOf("Mac") == 0;
		}
		return isMac;
	}
	
	private static function get_isLinux():Bool
	{
		if(isLinux == null)
		{
			isLinux = Sys.systemName().indexOf("Linux") == 0;
		}
		return isLinux;
	}
	
	
	/**
	*  Fix to remove trailing slash from directories in windows (throws errors on FileSystem methods)
	*  */
	private static function safePath(path:String):String
	{
		if(isWindows)
		{
			var c:String = path.substr(-1);
			if(c == "/" || c == "\\")
			{
				path = path.substr(0, -1);
			}
			
		}
	
		return path;
	}
	
	/**
	*  fix for getCwd returning the wrong slash on a directory in windows
	*/
	public static function getCwd():String
	{
		var path:String = Sys.getCwd();
		
		if(isWindows)
		{
			if(path.substr(-1) == "/")
			{
				path = path.substr(0, -1) + "\\";
			}

		}
		
		return path;

	}
	
	public static function setCwd(path:String):Void
	{
		path = safePath(path);
		try
		{
			Sys.setCwd(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}	
	}
	
	public static function exists(path:String):Bool
	{
		path = safePath(path);
		try
		{
			return sys.FileSystem.exists(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}		
	}
	
	public static function isDirectory(path:String):Bool
	{
		path = safePath(path);
		
		try
		{
			return sys.FileSystem.isDirectory(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}

	}
	
	public static function readDirectory(path:String):Array<String>
	{
		path = safePath(path);
		
		try
		{
			return sys.FileSystem.readDirectory(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}

	}
	
	public static function createDirectory(path:String):Void
	{
		path = safePath(path);
		
		try
		{
			sys.FileSystem.createDirectory(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}

	}
	
	public static function deleteDirectory(path:String):Void
	{
		path = safePath(path);
		
		try
		{
			sys.FileSystem.deleteDirectory(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}
	}
	
	public static function deleteFile(path:String):Void
	{
		path = safePath(path);
		
		try
		{
			sys.FileSystem.deleteFile(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}
	}
	
	#if (haxe_208 || haxe_210)
	public static function stat(path:String):FileStat
	{
		path = safePath(path);
		try
		{
			return sys.FileSystem.stat(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}
	}
	#end
	
	public function new():Void
	{
		
	}
}
