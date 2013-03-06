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

package massive.sys.haxe;

import sys.FileSystem;
import sys.io.File;
import massive.sys.io.File;
import neko.vm.Thread;
import Sys;
import Sys;
import sys.io.Process;

/**
*  This is a simple wrapper for running haxe from within neko
* 
*/
class HaxeWrapper
{
	/*
		Compiles a hxml string using haxe.
		Errors are printed the console.
		@return exit code from haxe compiler - 0 is success, >0 is a fail.
	*/
	static public function compile(hxml:String, ?silent:Bool=false):Int
	{
		var targets = splitHxmlIntoTargets(hxml);
		var exitCode = 0;

		for(target in targets)
		{
			exitCode = compileTarget(target,silent);
			if(exitCode != 0) break;
		}
		return exitCode;
	}

	static function compileTarget(hxml:String, ?silent:Bool=false):Int
	{
		var args = convertHXMLStringToArgs(hxml);

		printIndented("haxe " + StringTools.replace(args, "\\ ", " "));

		try
		{
			var process:Process = new Process("haxe", encodeArgsArray(args));

			try
			{
				while (true)
				{
					Sys.sleep(0.01);
					var output = process.stdout.readLine();
					if (!silent) printIndented(output, "      ");
				}
			}
			catch (e:haxe.io.Eof) {}

			var exitCode = process.exitCode();
			var errString = process.stderr.readAll().toString();
			if (exitCode > 0 || errString.length > 0)
			{
				printIndented(errString, "   ");
			}
			
			return exitCode;
		}	
		catch(e:Dynamic)
		{
			trace(e);
		}
		return 1;
	}
		
	
	static private function readError():Void
	{
		var stderr:haxe.io.Input = Thread.readMessage(true);
		var message:String = null;
		while(message == null)
		{
			try
			{
				var str:String = "";
				//str = stderr.readLine();
				message = Thread.readMessage(false);
				//Sys.println("   " + str);
			}
			catch(e:haxe.io.Eof)
			{

			}
		}
	}

	/**
	* ensures arguments with space characters aren't split incorrectly
	*/
	static function encodeArgsArray(argsString:String)
	{
		var args:Array<String> = [];
	
		argsString = StringTools.replace(argsString, "\\ ", "\n");
		
		var parts = argsString.split(" ");
	
		for(part in parts)
		{
			args.push(StringTools.replace(part, "\n", " "));
		}
		return args;
	}

	static function printIndented(str:String, indent:String="   ")
	{
		str = StringTools.trim(str); 

		Sys.println(indent + str);	

		Sys.stdout().flush();
	}
	
	static public function convertHXMLStringToArgs(hxml:String):String
	{
		var lines:Array<String> = hxml.split("\n");
		var result:String = "";
		
		for(line in lines)
		{
			line = StringTools.trim(line);
			
			if(line != "" && line.indexOf("#") != 0)
			{
				if(result != "") result += " ";

				if(line.lastIndexOf(" ") != line.indexOf(" "))
				{
					var parts = line.split(" ");
					result += parts.shift() + " ";
					result += parts.join("\\ ");
				}
				else
				{
					result += line;
				}
				
			}	
		}
		return result;
	}
	
	static public function convertHxmlStringToArray(hxml:String):Array<String>
	{
		var lines = hxml.split("\n");
		var params:Array<String> = [];

		for (line in lines)
		{
			if (line.length > 0 && line.indexOf("#") != 0)
			{
				params.push(line);
			} 
		}
		
		return params;
	}

	static public function splitHxmlIntoTargets(hxml:String):Array<String>
	{
		return hxml.split("\n--next");
	}
	
}
