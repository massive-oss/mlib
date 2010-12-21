package massive.mlib.cmd;
import massive.neko.cmd.Command;
import massive.neko.haxelib.Haxelib;
import massive.mlib.MlibSettings;

class MlibCommand extends Command
{
	public var haxelib:Haxelib;
	public var requiresHaxelib:Bool;
	
	public var settings:MlibSettings;
	
	public function new():Void
	{
		super();
		requiresHaxelib = true;
	}

	override public function initialise():Void
	{
		
	}

	override public function execute():Void
	{
	
	}
}