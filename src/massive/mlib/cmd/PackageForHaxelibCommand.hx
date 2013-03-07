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
import massive.haxe.Exception;

import massive.sys.util.ZipUtil;
import massive.sys.haxelib.HaxelibTools;
import massive.haxe.util.RegExpUtil;
import massive.sys.util.PathUtil;

class PackageForHaxelibCommand extends MlibCommand
{
	private var bin:File;
	private var zip:File;
	
	public function new():Void
	{
		super();
		addPreRequisite(UpdateSourceLicenseCommand);
	}
	
	override public function initialise():Void
	{
		bin = settings.bin.resolveDirectory(haxelib.name);
		
		var zipPath:String = console.getOption("zip");
		
		if(zipPath == null) zipPath = haxelib.name + ".zip";
		
		zip = settings.bin.resolveFile(zipPath);
	
	}

	override public function execute():Void
	{
		bin.deleteDirectoryContents();
		
		haxelib.file.copyTo(bin);
		
		var licenseFile:File = haxelib.file.parent.resolveFile("LICENSE.txt");
		if(licenseFile.exists)
		{
			licenseFile.copyTo(bin);
		}
		
		var files:Array<File>;
		
		for(resource in settings.resources)
		{
			if(!resource.file.exists)
			{
				error("Resource doesn't exist " + resource.file);
				continue;
			}
			
			if(resource.useChildren)
			{
				files = resource.children.concat([]);
			}
			else
			{
				files = [resource.file];
			}
			
			
			if(resource.type == "src" && resource.dest == null)
			{
				for(file in files)
				{
					if(file.isDirectory) file.copyTo(bin);
				}	
			}
			else if(resource.type == "run")
			{
				resource.file.copyTo(bin.resolveFile("run.n"));
			}
			else if(resource.type == "license")
			{
				//covered by updateSourceLicenseCommand
			}
			else
			{
				var dest:File;

				if(resource.dest != null && resource.dest != "")
				{
					dest = bin.resolvePath(resource.dest);
					
				}
				else
				{
					dest = bin;
				}
				
				for(file in files)
				{
					file.copyTo(dest);
				}
			}
			
		}


		Log.debug("zipping up directory " + bin + " to " + zip);
		
		ZipUtil.zipDirectory(zip, bin, RegExpUtil.HIDDEN_FILES, true);

		

	}
	

}