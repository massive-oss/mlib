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
/**
*  A command represents a single action or task in the system. 
*/
interface ICommand
{
	
	/**
	* An array of prerequisite commands required to be executred prior to the current one
	*/
	var preRequisites:Array<CommandInstance>;
	
	/**
	* An array of commands to execute after the current command
	*/
	var postRequisites:Array<CommandInstance>;
	
	
	/*
	* Generic data object for commands. Set via setData()
	*/
	var data:Dynamic;
	
	/**
	*  rerefence to the command line console. Used to access arguments passed through from the command line and to prompt
	*  the user for properties 
	*/
	var console:Console;
	
	
	var skip(default, null):Bool;
	
	
	function setData(?data:Dynamic=null):Void;
	
	/**
	*  Called prior to running any dependency tasks.
	*  An opportunity to check/prompt for command line parameters
	*  prior to execute and after console has been injected.
	*/
	function initialise():Void;


	/**
	* Called after any dependent tasks have completed.
	* Location of command logic
	**/
	function execute():Void;

}


class CommandInstance
{
	public var commandClass:Class<ICommand>;
	public var data:Dynamic;
	
	public function new(cmdClass:Class<ICommand>, ?data:Dynamic = null):Void
	{
		commandClass = cmdClass;
		this.data = data;
		
	}
}
