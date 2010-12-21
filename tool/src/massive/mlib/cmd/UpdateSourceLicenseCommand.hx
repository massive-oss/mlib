package massive.mlib.cmd;

import massive.neko.haxelib.HaxelibTools;
import massive.neko.io.File;
import massive.haxe.log.Log;
import massive.mlib.MlibSettings;

class UpdateSourceLicenseCommand extends MlibCommand
{
	private var directories:Array<File>;
	private var license:File;
	
	private static var commentOpening:String = "/****";
	private static var commentClosing:String = "****/";
	

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


		var licenses:Array<Resource> = settings.getResourcesByType("license");
		if(licenses == null)
		{
			print("WARNING: No resources of type 'license' found in .mlib");
			exit(0);
		}
		
		license = licenses[0].file;
		
		if(!license.exists)
		{
			throw "License file doesn't exist " + license;	
		}
	}

	override public function execute():Void
	{
		
		var licenseStr:String = license.readString();
		licenseStr = StringTools.replace(licenseStr, "::year::", Std.string(Date.now().getFullYear()));
		
		var codeLicense:String = formatLicenseForCodeFiles(licenseStr);
		
		var files:Array<File> = [];
		for(dir in directories)
		{
			files = files.concat(dir.getRecursiveDirectoryListing(~/\.hx$/));
		}
		
		for(file in files)
		{
			var contents:String = file.readString();
			
			
			if(contents.indexOf(commentOpening) != -1)
			{
				//strip out existing info
				
				var reg:EReg = ~/[commentOpening].*[commentClosing]/;
				
				trace(reg.match(contents));
				
				var lines:Array<String> = contents.split("\n");
				
				var removeLine:Bool = false;
				for(i in lines.length-1...0)
				{
					var line = lines[i];
					
					if(!removeLine && line.indexOf(commentOpening) == 0)
					{
						removeLine = true;	
					}
					
					if(removeLine)
					{
						lines.splice(i, 1);
					}
					
					if(removeLine && line.indexOf(commentClosing)==0)
					{
						removeLine = false;
						break;
					}
				}
				
			}
			
			file.writeString(codeLicense + contents);
			
			
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