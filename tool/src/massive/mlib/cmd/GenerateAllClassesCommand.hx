/****
* Copyright 2012 Massive Interactive. All rights reserved.
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

import massive.haxe.util.RegExpUtil;
import massive.neko.io.File;
import massive.haxe.log.Log;
import massive.neko.util.PathUtil;
import massive.mlib.MlibSettings;

class GenerateAllClassesCommand extends MlibCommand
{
	private var directories:Array<File>;
	
	public function new():Void
	{
		super();
		requiresHaxelib = false;
		directories = [];
	}
	
	override public function initialise():Void
	{
		var customSrcPath:String = console.getNextArg();
		
		if(customSrcPath != null)
		{
			var dir = File.create(customSrcPath, console.dir);
			
			if(dir == null || !dir.exists)
			{
				throw "Invalid src path " + customSrcPath;
			}
			
			Log.debug("dir: " + dir);
			directories.push(dir);
			
		}
		else
		{
			//get from .mlib <resources/>
			var resources:Array<Resource> = settings.getResourcesByType("src");
			
			if(resources == null || resources.length == 0)
			{
				error("No resources of type 'src' found in .mlib");
			}
			
			for(resource in resources)
			{
				if(!resource.file.exists)
				{
					throw "Resource path doesn't exist " + resource.file;
				}
				
				
				if(resource.useChildren)
				{
					for (child in resource.children)
					{
						if(child.isDirectory) directories.push(child);
					}
				
				}
				else
				{
					directories.push(resource.file);
				}
				
			}	
		}

	}

	override public function execute():Void
	{
		for(dir in directories)
		{
			//1. determine highest level package

			var files = dir.getDirectoryListing(RegExpUtil.HIDDEN_FILES, true);

			while(files.length == 1 && files[0].isDirectory)
			{
				files = files[0].getDirectoryListing(RegExpUtil.HIDDEN_FILES, true);
			}
			
			if(files.length == 0) continue;
			
			var packagePath = dir.getRelativePath(files[0].parent);
			var packageStr = packagePath.split("/").join(".");

		
			var clsPath:String = packagePath;
			
			if(clsPath != "") clsPath += "/";
			
			clsPath += "AllClasses.hx";
			
			var cls:File = dir.resolveFile(clsPath);
			
			Log.debug("cls: " + cls);
			//2. create AllClasses
			createAllClasses(cls, packageStr, dir);
		}
		
	}
	
	private function createAllClasses(cls:File, pckge:String, dir:File):Void
	{
		var contents:String = "";
		
		
		var classes:Array<File> = cls.parent.getRecursiveDirectoryListing(~/\.hx$/);
	
		contents += "package " + pckge + ";\n\n";
		
		var classFile:File;
		var s:String;
		var a:Array<String>;
		for(i in 0...classes.length)
		{
			classFile = classes[i];

			s = dir.getRelativePath(classFile);

			if(classFile.nativePath == cls.nativePath) continue;
			
		//	trace(s);
			a = s.split("/");

			var clsName = a.pop();

			if(clsName.indexOf("_") > 0)
			{
				//support for ignoring MCore Partials
				var partial = clsName.split("_");
				partial.pop();

				var partialFile = dir.resolveFile(a.join("/") + "/" + partial.join("_") + ".hx");

				if(partialFile.exists) continue;
			}
			
			a.push(clsName);
			
			s = a.join(".").substr(0, -3);
		//	trace("   " + s);
			
			s = "import " + s + ";";
			contents += s + "\n";
		}
		
		contents += "\n@IgnoreCover";
		contents += "\nclass "+ cls.name;
		contents += "\n{";
		contents += "\n@IgnoreCover";
		contents += "\n	public static function main():" + cls.name + " {return new " + cls.name + "();}";
		contents += "\n@IgnoreCover";
		contents += "\n	public function new(){trace('This is a generated main class');}";
		contents += "\n}\n\n";
		
		//Log.debug(contents);
		
		if(!cls.exists || cls.readString() != contents)
		{
			cls.writeString(contents, true);
		}
		
	}
}