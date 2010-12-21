package massive.mlib.cmd;

import massive.neko.haxelib.Haxelib;
import massive.neko.io.File;
import massive.haxe.log.Log;

class ConfigMlibCommand extends MlibCommand
{
	private var replaceSettings:Bool;
	private var replaceHaxelib:Bool;
	
	public function new():Void
	{
		super();
		requiresHaxelib = false;
	}
	
	override public function initialise():Void
	{
		replaceSettings = (console.getOption("-settings") == "true");
		replaceHaxelib = (console.getOption("-haxelib") == "true");
	}

	override public function execute():Void
	{	
		if(!haxelib.file.exists || replaceHaxelib)
		{
			var name:String = console.prompt("project name");
			haxelib.name = name;
			haxelib.save();	
		}
		
		if(!settings.file.exists || replaceSettings)
		{
			settings.save();
			
			print("mlib settings file created.\n	Modify this file to configure mlib project. \n	" + settings.file);
		}
	
	
	}

}