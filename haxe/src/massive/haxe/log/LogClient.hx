package massive.haxe.log;

import massive.haxe.log.Log;

class LogClient implements ILogClient
{
	public function new():Void
	{
		
	}
	
	public function print(message:String, level:LogLevel):Void
	{	
		var msg:String;
		if(level == LogLevel.console)
		{
			msg = message;
		}
		else
		{
			msg = Std.string(level) + ": " + message;
		}
		
		#if neko
		neko.Lib.println(msg);
		#else
		trace(msg);
		#end
		
		
		
	}
}