package massive.sys.cmd;

import haxe.PosInfos;


class CommandMock extends Command
{
	public static var instance:CommandMock;
	
	public var isInitialised:Bool;
	public var isExecuted:Bool;
	
	public function new():Void
	{	
		super();	
		isInitialised = false;
		isExecuted = false;
		instance = this;
	}
	
	

	
	override public function initialise():Void
	{
		isInitialised = true;
	}
	
	override public function execute():Void
	{
		isExecuted = true;
	}

}