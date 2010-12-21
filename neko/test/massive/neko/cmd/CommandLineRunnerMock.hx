package massive.neko.cmd;

import haxe.PosInfos;
import massive.neko.cmd.CommandLineRunner;
import massive.neko.cmd.Console;

class CommandLineRunnerMock extends CommandLineRunner
{
	public var exitCode:Int;
	public var printedHelp:Bool;
	public var printedCommandDef:CommandDef;
	
	public function new(?console:Console=null):Void
	{	
		super();
		printedHelp = false;
		printedCommandDef = null;
		if(console != null)
		{
			this.console = console;
		}	
	}
	
	
	override public function printHelp():Void
	{
		printedHelp = true;
	}
	
	override private function print(message:Dynamic):Void
	{
		//
	}
	
	override private function exit(?code:Int=0):Void
	{
		exitCode = code;
	}
	
	
	
	override private function printCommandDetail(cmd:CommandDef):Void
	{
		super.printCommandDetail(cmd);
		printedCommandDef = cmd;
		
	}




}