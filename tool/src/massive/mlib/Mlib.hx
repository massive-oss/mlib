/****
* Copyright 2010 Massive Interactive. All rights reserved.
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
* THIS SOFTWARE IS PROVIDED BY MASSIVE INTERACTIVE ``AS IS'' AND ANY EXPRESS OR IMPLIED
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

package massive.mlib;

import massive.haxe.log.Log;
import massive.neko.cmd.CommandLineRunner;
import massive.neko.cmd.Console;
import massive.neko.cmd.ICommand;
import massive.neko.haxelib.Haxelib;
import massive.neko.io.File;

import massive.mlib.cmd.MlibCommand;
import massive.mlib.cmd.ConfigMlibCommand;
import massive.mlib.cmd.UpdateSourceLicenseCommand;
import massive.mlib.cmd.GenerateAllClassesCommand;
import massive.mlib.cmd.IncrementHaxelibVersionCommand;
import massive.mlib.cmd.PackageForHaxelibCommand;
import massive.mlib.cmd.InstallToHaxelibCommand;
import massive.mlib.cmd.SubmitToHaxelibCommand;





class Mlib extends CommandLineRunner
{
	static public function main():Mlib{return new Mlib();}
	
	private var settings:MlibSettings;
	private var haxelib:Haxelib;
	
	public function new():Void
	{
		super();
		
		haxelib = new Haxelib(console.dir.resolveFile("haxelib.xml"));
		settings = new MlibSettings(console.dir.resolveFile(".mlib"));
		
		if(settings.file.exists)
		{
			Log.debug(settings);
		}
	
		mapCommand(ConfigMlibCommand, "config", ["c"], "Creates a .mlib config and haxelib.xml file in the current directory");
		
		mapCommand(UpdateSourceLicenseCommand, "license", ["l"], "Replaces license text in hx files within a source directory");
		mapCommand(GenerateAllClassesCommand, "allClasses", ["all"], "Generates 'AllClasses.hx' importing all classes in a src package");
		mapCommand(IncrementHaxelibVersionCommand, "incrementVersion", ["v"], "Increments the version number in the haxeib manifest");
		
		mapCommand(PackageForHaxelibCommand, "package", ["p"], "Packages up the current project for haxelib");
		
		mapCommand(InstallToHaxelibCommand, "install", ["i"], "Installs local version of project to haxelib");
		mapCommand(SubmitToHaxelibCommand, "submit", [], "Submits project to haxelib server");

		run();
	}
	
	
	override private function createCommandInstance(commandClass:Class<ICommand>):ICommand
	{
		var command:ICommand = super.createCommandInstance(commandClass);
		
		var cmd:MlibCommand = cast(command, MlibCommand);
		
		if(cmd.requiresHaxelib && (!haxelib.file.exists))
		{
			error("Command requires a valid haxelib.xml file in the current directory:\n   " + console.dir);
			
		}
		
		cmd.haxelib = haxelib;
		cmd.settings = settings;
		return cmd;
	}
	
}