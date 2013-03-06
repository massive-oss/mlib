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

import massive.sys.cmd.Console;
import massive.haxe.log.Log;
import massive.sys.cmd.ICommand;
/**
*  An abstract base class for Commands
*  Includes utility me
*  thods for printing, errors and exiting to the command line
*  */
class Command implements ICommand
{
	public var preRequisites:Array<CommandInstance>;
	public var postRequisites:Array<CommandInstance>;
	public var console:Console;
	public var data:Dynamic;
	
	public var skip(default, null):Bool;

	public function new():Void
	{
		preRequisites = [];
		postRequisites = [];
		skip = false;
	}
	
	public function setData(?data:Dynamic = null):Void
	{
		this.data = data;
	}
	
	/**
	* Called prior to running any dependency tasks.
	*  An opportunity to check/prompt for command line parameters
	*  prior to execute and after mCommand has been set. 
	*/
	public function initialise():Void
	{
		
	}

	/**
	* Called after any dependent tasks have completed.
	* Location of command logic
	**/
	public function execute():Void
	{
	
	}
	
	
	public function addPreRequisite(commandClass:Class<ICommand>, ?data:Dynamic=null):Void
	{
		preRequisites.push(new CommandInstance(commandClass, data));
	}
	
	public function addPostRequisite(commandClass:Class<ICommand>, ?data:Dynamic=null):Void
	{
		postRequisites.push(new CommandInstance(commandClass, data));
	}

	private function print(message:Dynamic):Void
	{
		Sys.println(Std.string(message));
	}
	
	private function error(message:Dynamic, ?code:Int=1, ?posInfos:haxe.PosInfos):Void
	{
		print("Error: " + message);
		Log.error(posInfos);
		
		exit(code);
	}
	
	private function exit(?code:Int=0):Void
	{
		Sys.exit(code);
	}

}

