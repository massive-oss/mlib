package massive.haxe.log;

import massive.haxe.log.Log;

interface ILogClient
{
	function print(message:String, level:LogLevel):Void;
}