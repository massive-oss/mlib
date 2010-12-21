package massive.neko.cmd;

import massive.neko.cmd.Console;
/**
*  A command represents a single action or task in the system. 
*/
interface ICommand
{
	/**
	* An array of prerequisite commands required to be executred prior to the current one
	*/
	var beforeCommands:Array<Class<ICommand>>;
	
	/**
	* An array of commands to execute after the current command
	*/
	var afterCommands:Array<Class<ICommand>>;
	
	/**
	*  rerefence to the command line console. Used to access arguments passed through from the command line and to prompt
	*  the user for properties 
	*/
	var console:Console;

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
