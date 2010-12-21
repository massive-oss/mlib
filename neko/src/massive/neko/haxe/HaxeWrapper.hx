package massive.neko.haxe;

import neko.FileSystem;
import neko.io.File;

import massive.neko.io.File;

import neko.vm.Thread;
import neko.Lib;
import neko.Sys;
import neko.io.Process;



/**
*  This is a simple wrapper for running haxe from within neko
* 
*/
class HaxeWrapper
{

	/*
		Compiles a hxml string using haxe.
		Errors are printed the console.
		
		@return exit code from haxe compiler - 0 is success, >0 is a fail.
		
	*/
	static public function compile(hxml:String):Int
	{
		var path:String = "tmp_build.hxml";
		var out = neko.io.File.write(path, false);
		out.writeString(hxml);
		out.close();
		
		var process:Process = new Process("haxe", [path]);
		
		var stderr:Thread = Thread.create(readError);
		stderr.sendMessage(process.stderr);
		
		var exitCode:Int = 0;
		exitCode = process.exitCode();
	
		if(exitCode > 0)
		{
			Sys.sleep(.1);
			stderr.sendMessage("stop");
		}
		else
		{
			//neko.Lib.println("Build Success!");
		}
		
		
		neko.FileSystem.deleteFile(path);


		return exitCode;
	}
		
	
	static private function readError():Void
	{
		var stderr:haxe.io.Input = Thread.readMessage(true);
		
		var message:String = null;
		
		while(message == null)
		{
			try
			{
				var str:String = "";
				str = stderr.readLine();
				message = Thread.readMessage(false);
				neko.Lib.println(str);
			}
			catch(e:haxe.io.Eof)
			{

			}
		}
	}
	
	
}
