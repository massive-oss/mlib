package massive.neko.io;
import neko.FileSystem;

class FileSys
{
	public static var isWindows(get_isWindows, null):Bool;
	
	private static function get_isWindows():Bool
	{
		if(isWindows == null)
		{
			isWindows = neko.Sys.systemName().indexOf("Win") == 0;
		}
		return isWindows;
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
		var path:String = neko.Sys.getCwd();
		
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
			neko.Sys.setCwd(path);
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
			return neko.FileSystem.exists(path);
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
			return neko.FileSystem.isDirectory(path);
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
			return neko.FileSystem.readDirectory(path);
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
			neko.FileSystem.createDirectory(path);
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
			neko.FileSystem.deleteDirectory(path);
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
			neko.FileSystem.deleteFile(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}
	}
	
	
	public static function stat(path:String):FileStat
	{
		path = safePath(path);
		try
		{
			return neko.FileSystem.stat(path);
		}
		catch(e:Dynamic)
		{
			throw Std.string(e) + "\n" + path;
		}
	}
	
	public function new():Void
	{
		
	}
}