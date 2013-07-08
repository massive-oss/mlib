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

package massive.sys.haxelib;

import haxe.xml.Fast;
import massive.sys.io.File;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>;
#end

class Haxelib
{	
	public var file(default, set_file):File;
	
	public var name(default, set_name):String;
	public var url:String;
	public var license(default, set_license):String;
	
	public var user:String;
	
	public var tags:Array<String>;
	public var dependencies:StringMap<String>;
	
	public var description:String;
	public var version(get_version, set_version):String;
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
		
		user = "";
		tags = [];
		dependencies = new StringMap();
		description = "";
		versionDescription = "";
		
		versionMajor = 0;
		versionMinor = 0;
		versionPatch = 0;
		versionBuild = 0;
		
		if(file != null && file.exists)
		{
			load();
		}
	}
	
	
	public static function fromString(str:String):Haxelib
	{
		var xml:Xml = Xml.parse(str).firstChild();
		return fromXml(xml);
	}	

	public static function fromXml(xml:Xml):Haxelib
	{
		var haxelib:Haxelib = new Haxelib();
		haxelib.parseFromXml(xml);
		return haxelib;
	}
	
	
	public function toString():String
	{
		var str:String = "";
		str += "<project name=\"" + name + "\" url=\"" + url + "\" license=\"" + license + "\">";
		str += "\n	<user name=\"" + user + "\"/>";
		
		for(tag in tags)
		{
			str += "\n	<tag v=\"" + tag + "\" />";
		}

		str += "\n	<description>" + description + "</description>";
		str += "\n	<version name=\"" + version + "\">" + versionDescription + "</version>";
		
		for(key in dependencies.keys())
		{		
			str += "\n	<depends name=\"" + key + "\"" + (dependencies.get(key)!=null? " version=\"" + dependencies.get(key) + "\"" : "") +  "/>";
		}
		
		str += "\n</project>";
			
		return str;
	}
	
	public function toXml():Xml
	{
		var str:String = toString();
		var xml:Xml = Xml.parse(str);
		return xml;

	}
	
	public function incrementVersion(type:String, ?newVersionDescription:String=null):Void
	{
		switch(type)
		{
			case "major":
				versionMajor ++;
				versionMinor = 0;
				versionPatch = 0;
				versionBuild = 0;
			case "minor":
				versionMinor ++;
				versionPatch = 0;
				versionBuild = 0;
			case "patch":
				versionPatch ++;
			case "build":
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
		//var xml:Xml = Xml.parse(file.readString()).firstChild();	
		//parseFromXml(xml);
	}

	private function parseFromJson(json : String) : Void
    {
        var data = haxe.Json.parse(json);
        name = data.name;
        url = data.url;
        license = data.license;

        description = data.description;
        version = data.version;
        tags = data.tags;

        dependencies = new StringMap();
        for(libName in Reflect.fields(data.dependencies)){
            var version = Reflect.field(data.dependencies,libName);
            dependencies.set(libName,version);
        }
    }
	
	
	
	/** parses a haxelib xml file into haxelib properties**/ 
	private function parseFromXml(xml:Xml):Void
	{
		var project:Fast = new Fast(xml);
		
		if(project.name != "project")
		{
			throw "Invalid haxelib.xml file!";
		}
		
		if(project.has.name) name = project.att.name;
		if(project.has.url) url = project.att.url;
		if(project.has.license) license = project.att.license;
		
		var node:Fast;
		
		if(project.hasNode.user)
		{
			node = project.node.user;
			if(node.has.name) user = node.att.name;
		}
		
		if(project.hasNode.description)
		{
			description = project.node.description.innerData;
		}
		
		if(project.hasNode.version)
		{
			node = project.node.version;
			if(node.has.name)
			{	
				version = node.att.name;
			}
			
			if(node.innerData != null) versionDescription = node.innerData;
		}	
		
		
		
		if(project.hasNode.tag)
		{
			for(node in project.nodes.tag)
			{
				tags.push(node.att.v);
			}
		}
		
		if(project.hasNode.depends)
		{
			for(node in project.nodes.depends)
			{
				setDependency(node.att.name, node.has.version ? node.att.version : null);
			}
		}

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
		return versionMajor + "." + versionMinor + "." + versionPatch + "." + versionBuild;
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
