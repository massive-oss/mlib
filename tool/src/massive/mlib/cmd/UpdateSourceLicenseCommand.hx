/**************************************** ****************************************
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
 */
package massive.mlib.cmd;

import massive.neko.haxelib.HaxelibTools;
import massive.neko.io.File;
import massive.haxe.log.Log;
import massive.mlib.MlibSettings;

class UpdateSourceLicenseCommand extends MlibCommand
{
	private var directories:Array<File>;
	private var license:File;
	
	private static inline var COMMENT_OPEN:String = "/**************************************** ****************************************";
	private static inline var COMMENT_CLOSE:String = " */";

	public function new():Void
	{
		super();
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
				directories.push(resource.file);
			}	
		}
		
		
		var customLicensePath:String = console.getNextArg();
		
		if(customLicensePath != null)
		{
			license = File.create(customLicensePath, console.dir);
			
			if(license == null || !license.exists)
			{
				throw "Invalid license path " + customLicensePath;
			}
		}
		else
		{
			var licenses:Array<Resource> = settings.getResourcesByType("license");
			if(licenses == null)
			{
				print("WARNING: No resources of type 'license' found in .mlib");
				exit(0);
			}

			license = licenses[0].file;
		}

		if(!license.exists)
		{
			throw "License file doesn't exist " + license;	
		}
	}

	override public function execute():Void
	{
		var license:String = license.readString();
		license = formatLicense(license);
		
		var files:Array<File> = [];
		for(dir in directories)
		{
			files = files.concat(dir.getRecursiveDirectoryListing(~/\.hx$/));
		}
		
		// FIXME: Need to take into account root classes which have no package declaration. ms 24/12/10
		var search:EReg = ~/^\s*package/gm;

		for (file in files)
		{
			var contents:String = file.readString();
		
			if (!search.match(contents)) 
			{
				trace("ERROR: No 'package' declaration found in class: " + file);
				continue;
			}
		
			var prologue = search.matchedLeft();
			var trimmedPrologue = StringTools.trim(prologue);
			var isOurLicense:Bool = (trimmedPrologue.indexOf(COMMENT_OPEN) == 0);						
			
			if (trimmedPrologue == "")
			{
				contents = license + "\n" + trimBody(contents);
				contents = contents.split("\r\n").join("\n");
				file.writeString(contents);
			}
			else if (isOurLicense && trimmedPrologue != license)
			{
				// we don't use StringTools.replace as it looks for all instances. This
				// is dangerous if say the prologues is just '//' or something else common.
				var parts = contents.split(prologue);
				parts.shift(); // remove the old prologue
				contents = parts.join(prologue);
				
				contents = license + "\n" + trimBody(contents);
				contents = contents.split("\r\n").join("\n");
				file.writeString(contents);				
			}
		}
	}

	private function formatLicense(license:String):String
	{
		license = license.split("\r\n").join("\n"); // make sure we're using unix line endings
		license = StringTools.trim(license);
		license = StringTools.replace(license, "::year::", Std.string(Date.now().getFullYear()));
		var lines:Array<String> = license.split("\n");
		
		var formattedLicense = COMMENT_OPEN;
		for (line in lines)	formattedLicense += "\n * " + line;
		formattedLicense += "\n" + COMMENT_CLOSE;
		
		return formattedLicense;
	}
	
	private function trimBody(body:String):String
	{
		body = StringTools.trim(body);
		body += "\n"; // add one new line on end of file
		return body;
	}
}
