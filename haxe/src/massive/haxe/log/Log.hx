package massive.haxe.log;

class Log
{
	static public var logLevel:LogLevel = LogLevel.console;
	
	static public var logClient:ILogClient = new LogClient();
	
	public function new():Void{}
	
	
	public static function debug(message:Dynamic):Void
	{
		log(message, LogLevel.debug);
	}
	
	public static function info(message:Dynamic):Void
	{
		log(message, LogLevel.info);
	}
	
	public static function warn(message:Dynamic):Void
	{
		log(message, LogLevel.warn);
	}
	
	public static function error(message:Dynamic):Void
	{
		log(message, LogLevel.error);
	}
	
	public static function fatal(message:Dynamic):Void
	{
		log(message, LogLevel.fatal);
	}
	
	public static function console(message:Dynamic):Void
	{
		log(message, LogLevel.console);
	}
	
	public static function log(message:Dynamic, ?level:LogLevel):Void
	{
		if(level == null) level = LogLevel.all;
		
		message = Std.string(message);
		
		var i:Int = convertLogLevelToInt(level);
	
		if(i >= convertLogLevelToInt(logLevel) || level == LogLevel.console)
		{
			logClient.print(message, level);
		}
	
		
	}
	
	public static function convertLogLevelToInt(type:LogLevel):Int
	{
		return switch(type)
		{
			case LogLevel.all:0;
			case LogLevel.debug:1;
			case LogLevel.info:2;
			case LogLevel.warn:3;
			case LogLevel.error:4;
			case LogLevel.fatal:5;
			case LogLevel.console:100;
		}
	}
	
	public static function convertLogLevelToString(type:LogLevel):String
	{
		return switch(type)
		{
			case LogLevel.all:"all";
			case LogLevel.debug:"debug";
			case LogLevel.info:"info";
			case LogLevel.warn:"warn";
			case LogLevel.error:"error";
			case LogLevel.fatal:"fatal";
			case LogLevel.console:"";
		}
	}
	
	public static function setLogLevelFromString(type:String):Void
	{
		logLevel = getLogLevelFromString(type);


	}
	
	
	
	private static function getLogLevelFromString(type:String):LogLevel
	{
		if(type == "all") return LogLevel.all;
		else if(type == "debug") return LogLevel.debug;
		else if(type == "info") return LogLevel.info;
		else if(type == "warn") return LogLevel.warn;
		else if(type == "error") return LogLevel.error;
		else if(type == "fatal") return LogLevel.fatal;
		else return LogLevel.debug;



	}

}


enum LogLevel
{
	all;
	debug;
	info;
	warn;
	error;
	fatal;
	console;
}

