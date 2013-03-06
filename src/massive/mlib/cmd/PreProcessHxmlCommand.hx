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

package massive.mlib.cmd;

import massive.sys.haxelib.Haxelib;
import massive.sys.io.File;
import massive.haxe.log.Log;

import massive.haxe.util.RegExpUtil;


class PreProcessHxmlCommand extends MlibCommand
{
	private var hxml:File;
	private var resourceDir:File;
	private var specificTargets:Array<String>;
	
	public function new():Void
	{
		super();
		requiresHaxelib = false;
	}
	
	override public function initialise():Void
	{
		var hxmlPath:String = console.getNextArg();
		
		if(hxmlPath == null) 
		{
			error("No hxml path specified");
		}
		
		hxml = File.create(hxmlPath, console.dir);
		
		
		//one or more resource paths
		var resourcePath:String = console.getOption("resource");
		
		if(resourcePath != null)
		{
			resourceDir = File.create(resourcePath, console.dir);
			
			if(!resourceDir.exists)
			{
				error("resource path doesn't exist " + resourcePath);
			}
		}
		
		var targetTypes:String = console.getOption("target");
		
		if(targetTypes != null && targetTypes != "true")
		{
			specificTargets = targetTypes.split(",");
		}
		else
		{
			specificTargets = new Array();
		}

	
	}

	override public function execute():Void
	{
		var contents:String = hxml.exists ? hxml.readString() : "";
		
		var targets:Array<HxmlTarget> = []; 

		if(contents != "")
		{
			targets = splitHxmlIntoSeperateTargets(contents);
		}
		
		
		var selectedTargets:Array<HxmlTarget> = [];
		
		for(target in targets)
		{
			if(target.preProcess) selectedTargets.push(target);

		}
		
		
		if(resourceDir != null)
		{
			updateResources(selectedTargets);
		}
		
		
		var newContents:String = "";
		
		for(target in targets)
		{
			if(newContents != "")
			{
				newContents += "\n--next\n";
			}
			newContents += target.lines.join("\n");
		}

		if(newContents != contents)
		{
			hxml.writeString(newContents);
		}
		
		
		
	}
	
	private function splitHxmlIntoSeperateTargets(contents:String):Array<HxmlTarget>
	{

		var lines:Array<String> = contents.split("\n");
		var target:HxmlTarget = new HxmlTarget();

		var targets:Array<HxmlTarget> = [];
		
		

		for(line in lines)
		{
			if(line.indexOf("--next") == 0)
			{
				targets.push(target);
				target = new HxmlTarget();
				continue;
			}
			
			line = StringTools.trim(line);
			
			target.lines.push(line);
			
			if(specificTargets.length == 0)
			{
				target.preProcess = true;
			}
			
			if(target.type == null)
			{
				for(type in specificTargets)
				{
					if(line.indexOf("-" + type) == 0)
					{
						target.type = type;
						target.preProcess = true;
						continue;
					}
				}		
			}
		}
		
		targets.push(target);
		
		
		return targets;
	}
	
	
	private function updateResources(selectedTargets:Array<HxmlTarget>):Void
	{
		//determine resources
		var resourceFiles:Array<File> = resourceDir.getRecursiveDirectoryListing(RegExpUtil.HIDDEN_FILES, true);
		var resources:Array<String> = [];


		//1. generate resource flags
		for (file in resourceFiles)
		{
			if(!file.isDirectory)
			{
				resources.push("-resource " + hxml.parent.getRelativePath(file) + "@" + file.name);	
			}
		}

		for(target in selectedTargets)
		{

			var i:Int = target.lines.length-1;
			
			while(i >= 0)
			{
				var line:String = target.lines[i];
				if(line.indexOf("-resource ") == 0 )
				{
					target.lines.splice(i, 1);
				}
				
				i--;	
			}
			
			for(resource in resources)
			{
				target.lines.push(resource);
			}
			
		}
			
	}

}


class HxmlTarget
{
	public var lines:Array<String>;
	public var type:String;
	public var preProcess:Bool;
	public function new():Void
	{
		lines = [];
		preProcess = false;
	}
}