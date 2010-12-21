package massive.neko.haxelib;
import neko.io.Process;
import massive.neko.io.File;
import massive.neko.util.ZipUtil;
import massive.haxe.util.RegExpUtil;
class HaxelibTools
{
	function new():Void{}
	
	public static function isLibraryInstalled(name:String, ?minVersion:String=null):Bool
	{
		var path:String = getLibraryPath(name);

		if(path == null) return false;
		
		if(minVersion == null) return true;
		

		//path will be something like /usr/lib/haxe/lib/munit\0,1,0,7\
		var a:Array<String> = path.split(name);
		var s:String = a[a.length-1];
		s = StringTools.replace(s, "/", "");
		s = StringTools.replace(s, "\\", "");
		
		var version:String = s.split(",").join(".");
		
		if(minVersion == version) return true;
		
		//return true if minVersion is greater than installed version
		return getGreaterVersion(minVersion, version) == version;

	}
	
	public static function getLibraryPath(name:String):String
	{
		var process:Process = new Process('haxelib', ["path", name]);
		var path:String = process.stdout.readLine();

		var exitCode:Int = process.exitCode();
		
		if(exitCode > 0) return null;
		
		if(neko.Sys.systemName() == "Windows")
		{
			path = path.split("/").join("\\");
		}

		return path;
		

	}
	/*
	public static function installFromDirectory(dir:File):Void
	{
		if(!dir.exists)
		{
			throw "Directory doens't exist";
		}

		var file:File = dir.resolvePath("haxelib.xml");
		if(!file.exists)
		{
			throw "Directory doens't contain haxelib.xml";
		}
		
		var zip:File = File.current.resolvePath("temp_haxelib.zip");
		
	
		
		
		neko.Lib.println("Zipping up directory...");
		ZipUtil.zipDirectory(zip, dir, RegExpUtil.HIDDEN_FILES, true);
		
		try
		{
			install(zip);
		}
		catch(e:Dynamic)
		{
			//zip.deleteFile();
			throw e;
		}
		
		zip.deleteFile();
		
	}
*/
	
	public static function install(zip:File):Void
	{
		neko.Lib.println("Installing to haxelib...");
		
		if(neko.Sys.command("haxelib test " + zip) > 0)
		{
			throw "Failed to install pacakge to haxelib " + zip;
		}
	}
	
	public static function submit(zip:File):Void
	{
		neko.Lib.println("Submitting to haxelib...");
		
		if(neko.Sys.command("haxelib submit " + zip) > 0)
		{
			throw "Failed to submit package to haxelib " + zip;
		}
	}
	

	
	
	private static function getGreaterVersion(v1:String, v2:String):String
	{
		var a:Array<String>;

		var array1:Array<Int> = [];
		var array2:Array<Int> = [];
		
		a  = v1.split(".");
		for(num in a)
		{
			array1.push(Std.parseInt(num));
		}
		
		a  = v2.split(".");
		for(num in a)
		{
			array2.push(Std.parseInt(num));
		}
		
		
		for(i in 0...array1.length)
		{
			if(array1[i] > array2[i])
			{
				return v1;
			}
		}
		
		return v2;

	}
}