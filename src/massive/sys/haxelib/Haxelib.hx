/****
* Copyright 2019 Massive Interactive. All rights reserved.
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

package massive.sys.haxelib;

import haxe.Json;
import haxe.xml.Fast;
import massive.sys.io.File;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>;
#end

class Haxelib
{
	public static inline var MAJOR:String = "major";
	public static inline var MINOR:String = "minor";
	public static inline var PATCH:String = "patch";
	public static inline var BUILD:String = "build";

	public var file(default, set_file):File;

	public var name(default, set):String;
	public var url:String;
	public var license(default, set):String;

	public var contributors:Array<String>;

	public var tags:Array<String>;
	public var dependencies:StringMap<String>;

	public var description:String;
	public var version(get, set):String;
	public var versionDescription:String;

	public var versionMajor:Int;
	public var versionMinor:Int;
	public var versionPatch:Int;
	public var versionBuild:Int;

	public function new(?file:File):Void
	{
		this.file = file;

		name = "";
		url = "";
		license = "";

		contributors = [];
		tags = [];

		dependencies = new StringMap();
		description = "";
		versionDescription = "";

		versionMajor = 0;
		versionMinor = 0;
		versionPatch = 0;

		if(file != null && file.exists)
		{
			load();
		}
	}

	public static function fromString(str:String):Haxelib
	{
		return fromJson(str);
	}

	public static function fromJson(json:String):Haxelib
	{
		var haxelib:Haxelib = new Haxelib();
		haxelib.parseFromJson(json);
		return haxelib;
	}

	public function toString():String
	{
		var str:String = "";
		str += "{";
		str += "\n\t\"name\": \"" + name + "\",";
		str += "\n\t\"url\": \"" + url + "\",";
		str += "\n\t\"license\": \"" + license + "\",";
		str += "\n\t\"description\": \"" + description + "\",";
		str += "\n\t\"version\": \"" + version + "\",";
		str += "\n\t\"releasenote\": \"" + versionDescription + "\",";

		str += "\n\t\"tags\": [";
		var first:Bool = true;
		for(tag in tags)
		{
			str += (first) ? "" : ",";
			str += "\"" + tag + "\"";
			first = false;
		}
		str += "],";

		str += "\n\t\"contributors\": [";
		first = true;
		for(contributor in contributors)
		{
			str += (first) ? "" : ",";
			str += "\"" + contributor + "\"";
			first = false;
		}
		str += "],";

		str += "\n\t\"dependencies\":\n\t{";
		first = true;
		for(key in dependencies.keys())
		{
			str += (first) ? "" : ",";
			str += "\n\t\"" + key + "\": " + ((dependencies.get(key) != null) ? "\"" + dependencies.get(key) + "\"" : "\"\"");
			first = false;
		}
		str += "\n\t}";
		str += "\n}";
		return str;
	}

	public function toJson():String
	{
		var str:String = toString();
		var json:String = haxe.Json.stringify(str);
		return json;
	}

	public function incrementVersion(type:String, ?newVersionDescription:String=null):Void
	{
		switch(type)
		{
			case MAJOR:
				versionMajor ++;
				versionMinor = 0;
				versionPatch = 0;
				if(versionBuild != null) {
					versionBuild = 0;
				}
			case MINOR:
				versionMinor ++;
				versionPatch = 0;
				if(versionBuild != null) {
					versionBuild = 0;
				}
			case PATCH:
				versionPatch ++;
			case BUILD:
				if(versionBuild == null) {
					versionBuild = 0;
				}
				versionBuild ++;
			default:
				//do nothing;
		}

		if(newVersionDescription != null)
		{
			versionDescription = newVersionDescription;
		}
	}

	public function setDependency(name:String, ?version:String=null):Void
	{
		dependencies.set(name, version);
	}

	public function removeDependency(name:String):Void
	{
		dependencies.remove(name);
	}

	public function getDependency(name:String):String
	{
		return dependencies.get(name);
	}

	public function save(?newFile=null):Void
	{
		if(newFile != null)
		{
			file = newFile;
		}

		if(file != null)
		{
			file.writeString(toString());
		}
	}

	public function load(?newFile=null):Void
	{
		if(newFile != null)
		{
			file = newFile;

			if(!file.exists) throw "Haxelib file doesn't exist " + file;
		}

		if(file == null || !file.exists) return;

		parseFromJson(file.readString());
	}

	/** parses a haxelib json file into haxelib properties**/
	public function parseFromJson(json:String):Void
	{
		var project = Json.parse(json);

		if(!validateProject(project))
		{
			throw "Invalid haxelib.json file!";
		}

		if(Reflect.hasField(project, "name")) name = Reflect.field(project, "name");
		if(Reflect.hasField(project, "url")) url = Reflect.field(project, "url");
		if(Reflect.hasField(project, "license")) license = Reflect.field(project, "license");
		if(Reflect.hasField(project, "description")) description = Reflect.field(project, "description");
		if(Reflect.hasField(project, "version")) version = Reflect.field(project, "version");
		if(Reflect.hasField(project, "releasenote")) versionDescription = Reflect.field(project, "releasenote");

		if(Reflect.hasField(project, "tags"))
		{
			var tagz:Array<String> = Reflect.field(project, "tags");
			for (item in tagz) {
				tags.push(item);
			}
		}

		if(Reflect.hasField(project, "contributors"))
		{
			var contributorz:Array<String> = Reflect.field(project, "contributors");
			for (contributor in contributorz) {
				contributors.push(contributor);
			}
		}

		if(Reflect.hasField(project, "dependencies"))
		{
			for (dependency in Reflect.fields(project.dependencies))
			{
				var version = Reflect.field(project.dependencies, dependency);
				setDependency(dependency, version);
			}
		}
	}

	/** validate that project data **/
	private function validateProject(projectData:Dynamic):Bool
	{
		var isValid:Bool = true;
		if(projectData == null) {
			isValid = false;
		}
		return isValid;
	}

	/**
	* format 0.0.0.0 (MAJOR.MINOR.PATCH.BUILD)
	*/
	private function set_version(value:String):String
	{
		var a:Array<String> = value.split(".");
		versionMajor = Std.parseInt(a[0]);
		versionMinor = Std.parseInt(a[1]);
		versionPatch = Std.parseInt(a[2]);
		versionBuild = Std.parseInt(a[3]);

		return get_version();
	}

	private function get_version():String
	{
		var output:String = versionMajor + "." + versionMinor + "." + versionPatch;
		if(versionBuild != null) {
			output += "." + versionBuild;
		}
		return output;
	}

	private function set_file(value:File):File
	{
		this.file = value;
		return value;
	}

	private function set_name(value:String):String
	{
		var reg:EReg = ~/[a-zA-Z0-9_-]*/;
		if(reg.match(value))
		{
			name = value;
			return name;
		}
		throw "Invalid project name (" + value + "). Allowed characters are [A-Za-z0-9_-].";

		return name;
	}

	private function set_license(value:String):String
	{
		var types:Array<String> = ["MIT","GPL", "LGPL", "BSD", "Public"];

		for(type in types)
		{
			if(value == type)
			{
				license = value;
			}
		}
		if(license != value) license = "";

		return license;
	}
}

typedef Dependency =
{
	var name:String;
	var version:String;
}