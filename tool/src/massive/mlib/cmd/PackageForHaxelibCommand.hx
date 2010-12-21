package massive.mlib.cmd;

import massive.neko.haxelib.Haxelib;
import massive.neko.io.File;
import massive.haxe.log.Log;

import massive.neko.util.ZipUtil;
import massive.neko.haxelib.HaxelibTools;
import massive.haxe.util.RegExpUtil;

class PackageForHaxelibCommand extends MlibCommand
{
	private var bin:File;
	private var zip:File;
	
	public function new():Void
	{
		super();
	}
	
	override public function initialise():Void
	{
		bin = settings.bin.resolveDirectory(haxelib.name);
		
		var zipPath:String = console.getOption("zip");
		
		if(zipPath == null) zipPath = haxelib.name + ".zip";
		
		zip = bin.resolveFile(zipPath);
	
	}

	override public function execute():Void
	{
		bin.deleteDirectoryContents();
		
		haxelib.file.copyTo(bin);
		
		for(resource in settings.resources)
		{
			if(!resource.file.exists)
			{
				error("Resource doesn't exist " + resource.file);
				continue;
			}
			
			if(resource.type == "src")
			{
				resource.file.copyTo(bin);
			}
			else if(resource.type == "run")
			{
				resource.file.copyTo(bin.resolveFile("run.n"));
			}
			else if(resource.type == "license")
			{
				
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
				
				resource.file.copyTo(dest);
			}
			
		}


		Log.debug("zipping up directory " + bin + " to " + zip);
		
		ZipUtil.zipDirectory(zip, bin, RegExpUtil.HIDDEN_FILES, true);

		

	}
	

}