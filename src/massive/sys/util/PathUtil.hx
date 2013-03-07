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

package massive.sys.util;

class PathUtil
{
	public static var DIRECTORY_NAME:EReg = ~/\.?[a-zA-Z0-9\-_ ]*$/;
	public static var HAXE_CLASS_NAME:EReg = ~/[A-Z]([a-zA-Z0-9]+)\.hx/;
	
	public function new():Void
	{
		
	}
	
	public static function isAbsolutePath(path:String):Bool
	{
		if(path.indexOf("/")==0)
		{
			//absolute osx path
			return true;
		}
		else if(path.indexOf("\\") > 0 && path.indexOf(":") == 1)// && path.indexOf("\\") < path.indexOf("/")
		{
			//absolute win path
			return true;
		}
		else
		{
			return false;
		}
	}
	
	static public function cleanUpPath(path:String):String
	{
		var seperator:String = Sys.getCwd().indexOf("\\") > 0 ? "\\" : "/";
			
		if(seperator == "/")
		{
			path = path.split("\\").join(seperator);
		}
		else
		{
			if(isAbsolutePath(path))
			{
				path = path.split("/").join(seperator);
			}
			else
			{
				path = path.split("\\").join(seperator);
			}
		}
		
		return path;
	}
	
	
	static public function lastCharIsSlash(path:String):Bool
	{
		var l:Int = path.length-1;
		return path.lastIndexOf("/") == l || path.lastIndexOf("\\") == l;
	}
	
	
	public static function isRelativePath(path:String):Bool
	{
		return isAbsolutePath(path) == false;
	}
	
	public static function isValidDirectoryName(path:String):Bool
	{
		return DIRECTORY_NAME.match(path) && DIRECTORY_NAME.matched(0) == path;
	}
	
	public static function isValidHaxeClassName(path:String):Bool
	{
		return HAXE_CLASS_NAME.match(path) && HAXE_CLASS_NAME.matched(0) == path;
	}
	

	

}