package massive.haxe;
import haxe.PosInfos;

import massive.haxe.util.ReflectUtil;

/**
 * Instances of the class Exception and its subclasses, when thrown, provide information about
 * the type and location of erroneous behavior.
 * 
 * An application should lookout for and handle raised exceptions through try/catch blocks located
 * in an appropriate place.
 * 
 * @author Mike Stead
 */
class Exception 
{
	/**
	 * The exception type. 
	 * 
	 * Should be the fully qualified name of the Exception class. e.g. 'massive.io.IOException'
	 */
	public var type(default, null):String;
	
	/**
	 * A description of the exception
	 */
	public var message(default, null):String;
	
	/**
	 * The pos infos from where the exception was created.
	 */
	public var info(default, null):PosInfos;
	
	/**
	 * @param	message			a description of the exception
	 */
	public function new(message:String, ?info:PosInfos) 
	{
		this.message = message;
		this.info = info;
		type = ReflectUtil.here().className;
	}
	
	/**
	 * Returns a string representation of this exception.
	 * 
	 * Format: <type>: <message> at <className>#<methodName> (<lineNumber>)
	 */
	public function toString():String
	{
		var str:String = type + ": " + message;
		if (info != null)
			str += " at " + info.className + "#" + info.methodName + " (" + info.lineNumber + ")";
		return str;
	}
}