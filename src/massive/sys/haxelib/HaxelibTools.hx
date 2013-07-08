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

package massive.sys.haxelib;
import sys.io.Process;
import massive.sys.io.File;
import massive.sys.util.ZipUtil;
import massive.haxe.util.RegExpUtil;
class HaxelibTools
{
	function new():Void{}
	
	public static function isLibraryInstalled(name:String, ?minVersion:String=null):Bool
	{
		var path:String = getLibraryPath(name);

		if(path == null) return false;
		
		if(minVersion == null) return true;
		

		//path will be something like /usr/lib/haxe/lib/munit\0,1,0,7\
		var a:Array<String> = path.split(name);
		var s:String = a[a.length-1];
		s = StringTools.replace(s, "/", "");
		s = StringTools.replace(s, "\\", "");
		
		var version:String = s.split(",").join(".");
		
		if(minVersion == version) return true;
		
		//return true if minVersion is greater than installed version
		return getGreaterVersion(minVersion, version) == version;

	}
	
	public static function getLibraryPath(name:String):String
	{
		var process:Process = new Process('haxelib', ["path", name]);
		var path:String = process.stdout.readLine();

		var exitCode:Int = process.exitCode();
		
		if(exitCode > 0) return null;
		
		if(Sys.systemName() == "Windows")
		{
			path = path.split("/").join("\\");
		}

		return path;
		

	}
	public static function install(name:String, ?minVersion:String=null):Bool
	{
		if(isLibraryInstalled(name, minVersion)) return true;
		
		
		var params:Array<String> = [];
		
		params.push("install " + name);
		if(minVersion != null) params.push(minVersion);
		
		
		var process:Process = new Process('haxelib', params);
		var path:String = process.stdout.readLine();

		var exitCode:Int = process.exitCode();
		
		if(exitCode > 0) return false;
		
		return true;
		
	}
	
	public static function installZip(zip:File):Void
	{
		Sys.println("Installing to haxelib...");
		
		if(Sys.command("haxelib local " + zip) > 0)
		{
			throw "Failed to install package to haxelib " + zip;
		}
	}
	
	public static function submit(zip:File):Void
	{
		Sys.println("Submitting to haxelib...");
		
		if(Sys.command("haxelib submit " + zip) > 0)
		{
			throw "Failed to submit package to haxelib " + zip;
		}
	}
	

	
	
	private static function getGreaterVersion(v1:String, v2:String):String
	{
		var a:Array<String>;

		var array1:Array<Int> = [];
		var array2:Array<Int> = [];
		
		a  = v1.split(".");
		for(num in a)
		{
			array1.push(Std.parseInt(num));
		}
		
		a  = v2.split(".");
		for(num in a)
		{
			array2.push(Std.parseInt(num));
		}
		
		
		for(i in 0...array1.length)
		{
			if(array1[i] > array2[i])
			{
				return v1;
			}
		}
		
		return v2;

	}
}
