package massive.neko.cmd;

import massive.neko.cmd.Console;
import massive.haxe.log.Log;

/**
*  An abstract base class for Commands
*  Includes utility me
*  thods for printing, errors and exiting to the command line
*  */
class Command implements ICommand
{
	public var beforeCommands:Array<Class<ICommand>>;
	public var afterCommands:Array<Class<ICommand>>;
	public var console:Console;

	public function new():Void
	{
		beforeCommands = [];
		afterCommands = [];
	}
	
	/**
	* Called prior to running any dependency tasks.
	*  An opportunity to check/prompt for command line parameters
	*  prior to execute and after mCommand has been set. 
	*/
	public function initialise():Void
	{
		
	}

	/**
	* Called after any dependent tasks have completed.
	* Location of command logic
	**/
	public function execute():Void
	{
	
	}

	private function print(message:Dynamic):Void
	{
		neko.Lib.println(Std.string(message));
	}
	
	private function error(message:Dynamic, ?code:Int=1, ?posInfos:haxe.PosInfos):Void
	{
		print("Error: " + message);
		Log.error(posInfos);
		
		exit(code);
	}
	
	private function exit(?code:Int=0):Void
	{
		neko.Sys.exit(code);
	}

}
