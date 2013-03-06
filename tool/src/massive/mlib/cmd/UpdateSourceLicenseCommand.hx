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

import massive.sys.haxelib.HaxelibTools;
import massive.sys.io.File;
import massive.haxe.log.Log;
import massive.mlib.MlibSettings;

class UpdateSourceLicenseCommand extends MlibCommand
{
	private var directories:Array<File>;
	private var license:File;

	private var noSourceLicense:Bool;
	
	private static var commentOpening:String = "/" + "****";//broken apart to prevent regex replace issues on comments above
	private static var commentClosing:String = "****" + "/";
	

	public function new():Void
	{
		super();
		directories = [];
		noSourceLicense = false;
	
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


		noSourceLicense = console.getOption("no-source-license") == "true";
	}

	override public function execute():Void
	{
		var licenseStr:String = license.readString();
		licenseStr = StringTools.replace(licenseStr, "::year::", Std.string(Date.now().getFullYear()));

		var file:File = console.dir.resolveFile("LICENSE.txt");
		if(file.readString() != licenseStr)
		{
			file.writeString(licenseStr);
		}

		if(!noSourceLicense)
		{
			updateSourceCodeLicense(licenseStr);
		}

	}

	function updateSourceCodeLicense(licenseStr:String)
	{
		var codeLicense:String = formatLicenseForCodeFiles(licenseStr);
		
		var files:Array<File> = [];
		for(dir in directories)
		{
			files = files.concat(dir.getRecursiveDirectoryListing(~/\.hx$/));
		}
		
		
		var str:String = "\\" + commentOpening.split("").join("\\") + ".*" + "\\" + commentClosing.split("").join("\\");
		str += "[\\n]*";
		var reg:EReg = new EReg(str, "gmis");
		//trace(str);
		
		for(file in files)
		{
			var contents:String = file.readString();

			if(contents.indexOf(commentOpening) != -1)
			{
				//strip out existing info
				contents = reg.replace(contents, "");
			}

			var newContents:String = codeLicense + "\n\n" + contents;
			
			if(newContents != contents)
			{
				file.writeString(newContents);					
			}
		}
	}
	
	private function formatLicenseForCodeFiles(original:String):String
	{
		var str:String = "";

		var lines:Array<String> = original.split("\n");

		str += commentOpening;

		for(line in lines)
		{
			str += "\n* " + line;
		}

		str += "\n" + commentClosing;
		
		return str;
	}


}