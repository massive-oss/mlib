/****
* Copyright 2011 Massive Interactive. All rights reserved.
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
