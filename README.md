MassiveLib
====================

Summary
---------------------

MLib is a collection of commandline and system utilities for developing simple command line driven neko and haxelib tools.

mlib provides a lightweight command based structure for rapidly developing command line tools in neko. It's used to to develop and deploy various haxelib projects including mlib and munit.

MLib supports Haxe 2.10 and Haxe 3 RC


### Installing

	haxelib install mlib

### Core Libraries

Mlib includes several haxe and neko src packages:

*	massive.haxe (cross platform haxe APIs)
*	massive.sys (neko specific APIs for file access, command line, haxe and haxelib integration)
*	massive.mlib (command line tool (mlib) for managing development and deployment of haxelib projects)


### Feature highlights

**Expanded File APIs**

See [massive.sys.io.File](https://github.com/massiveinteractive/MassiveLib/blob/master/src/massive/sys/io/File.hx)

*	recursive dir copy/move/delete
*	platform safe resolution of file paths


**Simplified access to command line**

See  [massive.sys.cmd.Console](https://github.com/massiveinteractive/MassiveLib/blob/master/src/massive/sys/cmd/Console.hx)

*	separation of raw system arg into arguments ('foo') and options (-foo bar)
*	automatic detection and updating of working directory when running in haxelib libraries
*	convenience methods for prompting user input

**Command line tool runner**
See [massive.sys.cmd.CommandLineRunner](https://github.com/massiveinteractive/MassiveLib/blob/master/src/massive/sys/cmd/CommandLineRunner.hx)

*	lightweight interface for mapping command line arguments to Command classes
*	automatic generation of command line *help* and command and  
*	enabling of logging through -debug option



Using the mlib tool
--------------------


mlib is also a command line tool provided for working with haxelib projects built on top of mlib.

To see a full list of available commands run mlib from the command line:

	haxelib run mlib
	
It provides utility functions for the following:

*	Incrementing haxelib lib version
*	Packaging and installing to local haxelib library
*	Packaging and submitting project to haxelib server
*	Updating copyright/license information across all code files

### Available commands

	config (c) : Creates a .mlib config and haxelib.xml file in the current directory
	license (l) : Replaces the license text in the header of all hx files within a src directory
	incrementVersion (v) : Increments the version number in the haxleib manifest (haxelib.xml)
	package (p) : Packages and zips up the current project for haxelib
	install (i) : Installs local version of project to haxelib
	submit : Submits project to haxelib server

   

### Creating a mlib project.

	haxelib run mlib config
	
This command generates a stub *.mlib* settings file in the current directory (and a haxelib.xml file if it doesn't exist already).

To see an example of the settings file is in this repository [.mlib](https://github.com/massiveinteractive/MassiveLib/blob/master/.mlib) 

The settings file has the following xml format:

	<mlib bin="bin">
		<resources>
			<resource type="src" path="haxe/src" />
			<resource type="src" path="neko/src" />
			<resource type="src" path="tool/src" dest=""/>
			<resource type="run" path="mlib.n" />
			<resource type="license" path="resource/license.mtt" />
			<resource path="file.txt" dest="dir/foo.bar" />
		</resources>	
	</mlib>


mlib **bin** is a mandatory attribute specifying the the relative path to the bin directory (defaults to 'bin'). This is the location where the haxelib project and zip package will be generated.

**Resources** a list of resources to include in the haxelib package

resource **path** is a mandatory attribute specifying the relative or absolute path to a file or directory. Use a trailing slash '/' to target directories within a path (e.g. 'haxe/src/')

resource **dest** is an optional attribute to specify a specific path within the package

resource **type** is an optional attribute to indicate a special type of resource:

*	**src**: a src path to copy to the top level directory of the haxelib package (as recommended in the haxexlib documentation). This type is also used as default locations by the 'license' and 'allClasses' commands  
*	**run**: a neko binary to use as the 'run.n' file within the haxelib package
*	**license**: a text file to use to generate copyright/license info across all classes in src packages. This type is used as the default location by the 'license' command  


## Building From Source


1. run the build.hxml file to compile the test runner
		haxe build.hxml
2. copy mlib.n to src/run.n
		cp mlib src/run.n
3. Set haxelib dev path to src directory
		haxelib dev mlib `pwd`/src


## Changes


### 2.0.0

This release adds support for Haxe 3.

It includes no major feature changes.

Upgrading

- update references to `massive.neko` to `massive.sys`

Change List

- Added Haxe3 support
	- renamed massive.neko to massive.sys
- Reorganised src structure to support haxelib dev path
- Removed allClasses command


