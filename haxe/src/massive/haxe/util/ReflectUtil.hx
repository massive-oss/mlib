package massive.haxe.util;
import haxe.PosInfos;

/**
 * Utility class to help with reflection.
 * 
 * @author Mike Stead
 */
class ReflectUtil 
{
	/**
	 * Return information about the location this method is called.
	 */
	public static function here(?info:PosInfos):PosInfos
	{
		return info;
	}
}