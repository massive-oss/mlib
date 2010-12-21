Massive Lib
====================

Summary
---------------------

Massive Interactive public haXe libraries containing utilities and tools for developing simple command line driven neko and haxelib tools.

mlib provides a lightweight command based structure for rapidly developing command line tools in neko. It's used to to develop and deploy various haxelib projects including mlib.


### Installing

	haxelib install mlib

### Core Libraries

Mlib includes several haxe and neko src packages
* massive.haxe (cross platform haxe APIs)
* massive.neko (neko specific APIs for file access, command line, haxe and haxelib integration)
* massive.mlib (command line tool (mlib) for managing development and deployment of haxelib projects)


### Some features

* expanded File APIs beyond those available in neko.io. See [massive.neko.io.File](https://github.com/massiveinteractive/MassiveLib/blob/master/neko/src/massive/neko/io/File.hx)
** recursive dir copy/move/delete
** platform safe resolution of file paths
* Simplified access to command line (see [massive.neko.cmd.Console](https://github.com/massiveinteractive/MassiveLib/blob/master/neko/src/massive/neko/cmd/Console.hx))
** separation of raw system arg into arguments ('foo') and options (-foo bar)
** automatic detection and updating of working directory when running in haxelib libraries
** convenience methods for prompting user input
* Command line tool runner (see [massive.neko.cmd.CommandLineRunner](https://github.com/massiveinteractive/MassiveLib/blob/master/neko/src/massive/neko/cmd/CommandLineRunner.hx))
** lightweight interface for mapping command line arguments to Command classes
** automatic generation of command line *help* and command and  
** enabling of logging through -debug option



Using the mlib tool
--------------------


mlib is also a command line tool provided for working with haxelib projects built on top of mlib.

To see a full list of available commands run mlib from the command line:

	haxelib run mlib
	
It provides utility functions for the following:
* Incrementing haxelib lib version
* Packaging and installing to local haxelib library
* Packaging and submitting project to haxelib server
* Updating copyright/license information across all code files


More documentation to come...