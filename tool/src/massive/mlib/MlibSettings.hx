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

package massive.mlib;

import massive.sys.io.File;
import haxe.xml.Fast;
import massive.sys.util.PathUtil;
import massive.haxe.util.RegExpUtil;
import massive.haxe.Exception;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>;
#end

class MlibSettings
{
	public var file(default, set_file):File;
	public var dir:File;
	
	public var resources:Array<Resource>;
	public var bin:File;
	
	private var resourcesByType:StringMap<Array<Resource>>;
	
	public function new(?file:File):Void
	{
		this.file = file;
		
		resources = new Array();
		resourcesByType = new StringMap();
		
		if(file != null && file.exists)
		{
			load(file);
		}
	}

	private function set_file(value:File):File
	{
		file = value;
		if(file != null)
		{
			dir = file.parent;
			bin = dir.resolveDirectory("bin");
		}
		else 
		{
			dir = null;
			bin = null;	

		}
		
		
		return value;
	}

	public function save(?newFile:File):Void
	{
		if(newFile != null) file = newFile;
		
		var str:String = toXmlString();
		
		trace(str);
		
		if(file != null)
		{
			file.writeString(str);
		}
	}
	
	public function load(?newFile:File):Void
	{
		if(newFile != null) file = newFile;
		
		if(file == null || !file.exists) throw "File doesn't exist " + file;
		
		var str:String = file.readString();
		
		var xml:Xml = Xml.parse(str).firstChild();
		
		fromXmlString(xml);

	}
	
	private function fromXmlString(xml:Xml):Void
	{
		var fast = new haxe.xml.Fast(xml);
		
		if(fast.has.bin)
		{
			bin = dir.resolveDirectory(fast.att.bin);
		}
		else
		{
			bin = dir.resolveDirectory("bin");
		}
		
		if(fast.hasNode.resources && fast.node.resources.hasNode.resource)
		{
			for(r in fast.node.resources.nodes.resource)
			{
				if(r.has.path)
				{
					var path:String = PathUtil.cleanUpPath(r.att.path);
					
					var type:String = r.has.type ? r.att.type : null;
					
					var dest:String = r.has.dest ? r.att.dest : null;
					
					var resourceFile:File = File.create(path, file.parent);
					addResource(new Resource(resourceFile, dest, type, path));	
				}
			}
		}
	}
	
	public function getResourcesByType(type:String):Array<Resource>
	{
		type = Std.string(type);
		if(resourcesByType.exists(type))
		{
			return resourcesByType.get(type);
		}
		return null;
		
	}
	
	public function addResource(resource:Resource):Void
	{
		resources.push(resource);
		
		var type = Std.string(resource.type);
		
		if(!resourcesByType.exists(type))
		{
			resourcesByType.set(type, []);
		}
		
		var a:Array<Resource> = resourcesByType.get(type);
		a.push(resource);
		
	}
	
	public function toXmlString():String
	{
		var str:String = "";
		str += "<mlib bin=\"" + dir.getRelativePath(bin) + "\">";
		str += "\n	<resources>";
		
		
		if(resources != null && resources.length > 0)
		{
			for(resource in resources)
			{
				str += "\n		" + resource.toXmlString(dir);
			}
		}
		else
		{
			str += "\n<!--		<resource type=\"src\" path=\"original/path\" dest=\"relative/path/inside/haxelib/project\" />-->";
		}
		
		str += "\n	</resources>";
		str += "\n</mlib>";
		
		return str;
	}
	
	
}

class Resource
{
	public var file(default, null):File;
	public var dest(default, null):String;
	public var type:String;
	public var originalPath:String;
	public var useChildren(default, null):Bool;
	public var children(default, null):Array<File>;
	
	public function new(file:File, dest:String, type:String, originalPath:String):Void
	{
		this.file = file;
		this.dest = dest;
		this.type = type;
		this.originalPath = originalPath;
		
		
		children = [];
		
		if(PathUtil.lastCharIsSlash(originalPath))
		{
			useChildren = true;
			
			if(!file.isDirectory) throw new Exception("Path is not a directory");
			
			//if path has a ending slash then target the sub files instead
			children = file.getDirectoryListing(RegExpUtil.HIDDEN_FILES, true);	
		}
		else
		{
			useChildren = false;
		}
	}
	
	public function toString():String
	{
		return "[Resource type:" + type + ", dest:" + dest + ", file:" + file.nativePath + "]";
	}
	
	
	public function toXmlString(?relativeDir:File=null):String
	{
		var str:String = "<resource";
		
		if(type != null)
		{
			str += " type=\"" + type + "\"";
		}
		
		
		var path:String;
		if(relativeDir != null)
		{
			path = relativeDir.getRelativePath(file);
		}
		else
		{
			path = file.nativePath;
		}
		
		str += " path=\"" + path + "\"";
		
		if(dest != null)
		{
			str += " dest=\"" + dest + "\"";
		}
		
		str += " />";
		
		return str;
	}
}
