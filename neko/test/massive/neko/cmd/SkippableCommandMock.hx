package massive.sys.cmd;

import haxe.PosInfos;


class SkippableCommandMock extends CommandMock
{
	public static var instance:SkippableCommandMock;

	public function new():Void
	{	
		super();	
		instance = this;
	}
	
	override public function initialise():Void
	{
		super.initialise();
		skip = true;
	}
	
	override public function execute():Void
	{
		super.execute();
	}

}