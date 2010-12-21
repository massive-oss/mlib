package massive.mlib.cmd;

import massive.haxe.util.RegExpUtil;
import massive.neko.io.File;
import massive.haxe.log.Log;
import massive.mlib.MlibSettings;

class GenerateAllClassesCommand extends MlibCommand
{
	private var directories:Array<File>;
	
	public function new():Void
	{
		super();
		requiresHaxelib = false;
		directories = [];
	}
	
	override public function initialise():Void
	{
		var customSrcPath:String = console.getNextArg();
		
		if(customSrcPath != null)
		{
			var dir = File.create(customSrcPath, console.dir);
			
			if(dir == null || !dir.exists)
			{
				throw "Invalid src path " + customSrcPath;
			}
			
			Log.debug("dir: " + dir);
			directories.push(dir);
			
		}
		else
		{
			//get from .mlib <resources/>
			var resources:Array<Resource> = settings.getResourcesByType("src");
			
			if(resources == null || resources.length == 0)
			{
				error("No resources of type 'src' found in .mlib");
			}
			
			for(resource in resources)
			{
				if(!resource.file.exists)
				{
					throw "Resource path doesn't exist " + resource.file;
				}	
				directories.push(resource.file);
			}	
		}

	}

	override public function execute():Void
	{
		for(dir in directories)
		{
			//1. determine highest level package

			var files = dir.getDirectoryListing(RegExpUtil.HIDDEN_FILES, true);

			while(files.length == 1 && files[0].isDirectory)
			{
				files = files[0].getDirectoryListing(RegExpUtil.HIDDEN_FILES, true);
			}

			var packagePath = dir.getRelativePath(files[0].parent);
			var packageStr = packagePath.split("/").join(".");

			var cls:File = dir.resolveFile(packagePath + "/AllClasses.hx");

			Log.debug("cls: " + cls);
			//2. create AllClasses
			createAllClasses(cls, packageStr, dir);
		}
		
	}
	
	
	private function createAllClasses(cls:File, pckge:String, dir:File):Void
	{
		var contents:String = "";
		
		var classes:Array<File> = cls.parent.getRecursiveDirectoryListing(~/\.hx$/);
	
		contents += "package " + pckge + ";\n\n";
		
		var classFile:File;
		var s:String;
		var a:Array<String>;
		for(i in 0...classes.length)
		{
			classFile = classes[i];

			s = dir.getRelativePath(classFile);
			
		//	trace(s);
			a = s.split("/");
		
			s = a.join(".").substr(0, -3);
		//	trace("   " + s);
			
			s = "import " + s + ";";
			contents += s + "\n";
		}
		
		contents += "\nclass "+ cls.name;
		contents += "\n{";
		contents += "\n	public static function main():" + cls.name + " {return new " + cls.name + "();}";
		contents += "\n	public function new(){trace('This is a generated main class');}";
		contents += "\n}\n\n";
		
		//Log.debug(contents);
		cls.writeString(contents, true);
	
	}
}