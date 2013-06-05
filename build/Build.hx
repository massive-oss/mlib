/*
Copyright (c) 2012 Massive Interactive

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all 
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE 
SOFTWARE.
*/

import mtask.target.HaxeLib;

class Build extends mtask.core.BuildBase
{
	public function new()
	{
		super();
	}

	@task function compile()
	{
		mkdir("bin");
		msys.Process.run("haxe", ["build.hxml"]);
	}

	@target function haxelib(t:HaxeLib)
	{
		t.url = "http://github.com/massiveinteractive/MassiveUnit";
		t.username = "massive";
		t.description = "A cross platform unit testing framework for Haxe with metadata test markup and tools for generating, compiling and running tests from the command line.";
		t.versionDescription = "Add haxelib.json ready to release to new haxelib.";
		t.license = MIT;
		
		t.addTag("cross");
		t.addTag("utility");
		t.addTag("tools");
		t.addTag("massive");
		
		t.beforeCompile = function(path)
		{
			rm("src/haxelib.xml");
			cp("src/*", path);
		}

		t.afterCompile = function(path)
		{
			cp("bin/release/haxelib/haxelib.xml", "src/haxelib.xml");
		}

	}

	@task function test()
	{
		mkdir("bin/test");

		msys.FS.cd("test/haxe", function(path){
			trace("testing massive.haxe...");
			cmd("haxelib", ["run", "munit", "test", "-coverage"]);
			cmd("haxelib", ["run", "munit", "report", "teamcity"]);
		});

		msys.FS.cd("test/sys", function(path){
			trace("testing massive.sys...");
			cmd("haxelib", ["run", "munit", "test", "-coverage"]);
			cmd("haxelib", ["run", "munit", "report", "teamcity"]);
		});
		
	}
	
	@task function teamcity()
	{
		invoke("clean");
		invoke("test");

		invoke("compile");
		invoke("build haxelib");
	}
}
