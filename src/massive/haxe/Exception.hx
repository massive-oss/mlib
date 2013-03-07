/****
* Copyright 2013 Massive Interactive. All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without modification, are
* permitted provided that the following conditions are met:
* 
*    1. Redistributions of source code must retain the above copyright notice, this list of
*       conditions and the following disclaimer.
* 
*    2. Redistributions in binary form must reproduce the above copyright notice, this list
*       of conditions and the following disclaimer in the documentation and/or other materials
*       provided with the distribution.
* 
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE "AS IS" AND ANY EXPRESS OR IMPLIED
* WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
* FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL MASSIVE INTERACTIVE OR
* CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
* SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
* NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
* ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* 
* The views and conclusions contained in the software and documentation are those of the
* authors and should not be interpreted as representing official policies, either expressed
* or implied, of Massive Interactive.
* 
****/

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