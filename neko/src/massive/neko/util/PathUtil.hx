package massive.neko.util;

class PathUtil
{
	public static var DIRECTORY_NAME:EReg = ~/\.?[a-zA-Z0-9\-_ ]*$/;
	public static var HAXE_CLASS_NAME:EReg = ~/[A-Z]([a-zA-Z0-9]+)\.hx/;
	
	public function new():Void
	{
		
	}
	
	public static function isAbsolutePath(path:String):Bool
	{
		if(path.indexOf("/")==0)
		{
			//absolute osx path
			return true;
		}
		else if(path.indexOf("\\") > 0 && path.indexOf(":") == 1)// && path.indexOf("\\") < path.indexOf("/")
		{
			//absolute win path
			return true;
		}
		else
		{
			return false;
		}
	}
	
	static public function cleanUpPath(path:String):String
	{
		var seperator:String = neko.Sys.getCwd().indexOf("\\") > 0 ? "\\" : "/";
			
		if(seperator == "/")
		{
			path = path.split("\\").join(seperator);
		}
		else
		{
			if(isAbsolutePath(path))
			{
				path = path.split("/").join(seperator);
			}
			else
			{
				path = path.split("\\").join(seperator);
			}
		}
		
		return path;
	}
	
	
	public static function isRelativePath(path:String):Bool
	{
		return isAbsolutePath(path) == false;
	}
	
	public static function isValidDirectoryName(path:String):Bool
	{
		return DIRECTORY_NAME.match(path) && DIRECTORY_NAME.matched(0) == path;
	}
	
	public static function isValidHaxeClassName(path:String):Bool
	{
		return HAXE_CLASS_NAME.match(path) && HAXE_CLASS_NAME.matched(0) == path;
	}
	

	

}