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

package massive.sys.cmd;

import massive.sys.io.File;
import massive.sys.io.FileException;
import massive.sys.io.FileSys;
import sys.FileSystem;
import neko.vm.Thread;
import Sys;
import massive.haxe.log.Log;
import sys.io.Process;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>;
#end
/**
*  Command Line Interface
*  
*  API for managing command line options passed to a neko program.
*  
*  Currently supports the following usages:
*  
*  foo bar				sequential arguments 'foo' and 'bar'
*  -foo					non-sequential options (value will be set to 'true')
*  -foo bar				non-sequential options with custom value
*  
*  For haxelib applications it automatically detects the final argument as a file path
*  and updates the working directory ('dir') accordingly 
*  
*  */
class Console
{
	public var systemArgs(get_systemArgs, null):Array<String>;
	
	/** directory where tool was called from (defaults to haxelib lib path) **/
	public var originalDir(default, null):File;

	/** 
	* Directory where haxelib was called from (for haxelib tools only)
	* Defaults to same as originalDir if not run from haxelib
	**/
	
	public var dir(default, null):File;
	
	/** Map of all command line arguments starting with a dash (e.g. '-foo bar') **/
	public var options:StringMap<String>;


	/** Array of all command line arguments not starting with a dash **/
	public var args:Array<String>;

	/** current index with the args array. Used to ensure that a single argument is only returned once **/
	private var currentArg:Int;
	
	/** 
	* Neko files launched via haxelib (e.g. haxelib run mcmd) include the original calling directory as the last argument
	* By default Console finds and sets this as the current directory when isHaxelib = true
	*  */
	private var isHaxelib:Bool;
	
	public function new(?isHaxelib:Bool = true):Void
	{
		this.isHaxelib = isHaxelib;
		originalDir = File.current;
		
		systemArgs = Sys.args().concat([]);
		Log.debug("systemArgs: " + systemArgs);
		
		init();
	}
	
	private function init():Void
	{
		dir = null;
		args = [];
		options = new StringMap();
		currentArg = 0;
		
		parseArguments(systemArgs);
		
		if(dir != null)
		{
			FileSys.setCwd(dir.nativePath);
		}
	}
	
	
	private function get_systemArgs():Array<String>
	{
		return systemArgs.concat([]);
	}
	/**
	*  Re-initialisises all arguments from the original Sys.args()
	**/
	public function flush(?isHaxelib:Bool = true):Void
	{
		this.isHaxelib = isHaxelib;
		init();
	}

	/**
	*  retrieve a command line option in the format -foo [bar]
	*  @param key - the name of the option (without the "-" infront of it)
	*  @param ?promptMsg - an optional prompt message to request value from user if option doesn't exist
	*  @return the value of the option or null. An option without a value argument will return 'true'
	*  */
	public function getOption(key:String, ?promptMsg:String=null):String
	{
		var str:String = null;
		
		if(key.indexOf("-") == 0) key = key.substr(1);
		
		if(options.exists(key))
		{
			str = options.get(key);
		}
		else if (promptMsg!= null)
		{
			str = prompt(promptMsg);
		}
		return str;
	}
	
	/**
	* Override the existing value of an option (or create a new one)
	* Useful when chaining together commands and pushing new option args to the console.
	* @param key - the name of the option
	* @param value - the value of the key
	*/
	public function setOption(key:String, value:Dynamic):Void
	{
		if(key.indexOf("-") == 0) key = key.substr(1);
		options.set(key, Std.string(value));
	}

	/**
	*  returns the next command line arg that isnt an option
	*  @param promptMsg - optional prompt message to request a value from the user if no arguments remain.
	*  @return the next argument or null (in no arguments remaining)
	*  */
	
	public function getNextArg(?promptMsg:String=null):String
	{
		var str:String = null;
		
		if(args.length > currentArg)
		{
			str = args[currentArg++];
		}
		else if(promptMsg != null)
		{
			str = prompt(promptMsg);
		}
		
		return str;
	}

	/**
	*  prompt the user for input from the command line
	*  @param promptMsg the message to display as a prompt
	*  @param rpad an optional padding value before the ':' character
	*  */
	public function prompt(promptMsg:String, rpad:Int=0):String
	{
		Sys.print(StringTools.rpad(promptMsg + " ", " ", rpad) + ": ");
		
		#if haxe_209
			var str:String = Sys.stdin().readLine();
		#else
			var str:String = Sys.stdin().readLine();
		#end
		
		if(str.length == 0)
		{
			str = null;
		}
	
		return str;
	}	

	
	/**
	*  Strips the dir path from the end of the args array.
	*  This is the path from where haxelib was called
	*  */
	private function getCurrentDirectoryPathFromArgs(a:Array<String>):File
	{
		var path:String = a[a.length-1];
		var file:File = null;
	
		try
		{
			file = File.create(path);
		}
		catch(e:FileException)
		{
			//Log.info(e + "\n" + a);
		}
	
		if(file != null)
		{
			Log.debug(file.toDebugString());
		}
		
		
		if(file != null && file.exists && file.isDirectory)
		{
			a.pop();
			return file;
		}
		return null;
	}
	
	
	/**
	*  seperates command line arguments into options (e.g. '-foo') and args (e.g. 'bar' )
	*  An option can have a single optional argument (e.g. -foo blah), otherwise the value will be a string 'true'
	*  
	*  */
	private function parseArguments(a:Array<String>):Void
	{
		args = [];
		
		if(a == null || a.length == 0)
		{
			dir = originalDir;
			return;
		}
		
		if(isHaxelib)
		{
			dir = getCurrentDirectoryPathFromArgs(a);
		}
		
		if(dir == null)
		{
			dir = originalDir;
		}
		
		options = new StringMap();
	
		
		var option:String = null;
		var optionArgs:String = "";
		for(arg in a)
		{
			if(option != null)
			{
				if(arg.charAt(0) == "-")
				{
					//this is another -x flag so set existing -x to true
					if(optionArgs == "")
					{
						options.set(option, "true");
					}
					else
					{
						if(optionArgs.indexOf("'") == 0 && optionArgs.lastIndexOf("'") == optionArgs.length-1)
						{
							optionArgs = optionArgs.substr(1, optionArgs.length-2);
						}
						options.set(option, optionArgs);
					}
					option = arg.substr(1);
					optionArgs = "";
				}
				else
				{	
					if(optionArgs.length > 0) optionArgs += " ";
					optionArgs += arg;
					
				}				
			}
			else if(arg.charAt(0) == "-")
			{
				option = arg.substr(1);
				optionArgs = "";
			}
			else
			{
				args.push(arg);
			}
		}

		if(option != null)
		{
			if(optionArgs == "")
			{
				options.set(option, "true");
			}
			else
			{
				if(optionArgs.indexOf("'") == 0 && optionArgs.lastIndexOf("'") == optionArgs.length-1)
				{
					optionArgs = optionArgs.substr(1, optionArgs.length-2);
				}
				options.set(option, optionArgs);
			}
		}
	}
}
