package massive.mlib.cmd;

import massive.neko.haxelib.Haxelib;
import massive.neko.io.File;
import massive.haxe.log.Log;

class IncrementHaxelibVersionCommand extends MlibCommand
{
	public function new():Void
	{
		super();
	}
	
	override public function initialise():Void
	{
		
	}

	override public function execute():Void
	{
		
		var type:String = console.getNextArg();
		if(type == null) type = "build";
	
		
		haxelib.incrementVersion(type);
		haxelib.save();	

		Log.console("Updating " + haxelib.name + " haxelib.xml version to " + haxelib.version);
	}
	

}