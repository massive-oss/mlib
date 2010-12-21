package massive.mlib;

import massive.neko.io.File;
import haxe.xml.Fast;

class MlibSettings
{
	public var file(default, set_file):File;
	public var dir:File;
	
	public var resources:Array<Resource>;
	public var bin:File;
	
	private var resourcesByType:Hash<Array<Resource>>;
	
	public function new(?file:File):Void
	{
		this.file = file;
		
		resources = new Array();
		resourcesByType = new Hash();
		
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
					var path:String = r.att.path;
					
					var type:String = r.has.type ? r.att.type : null;
					
					var dest:String = r.has.dest ? r.att.dest : null;
					
					var resourceFile:File = File.create(path, file.parent);
					addResource(new Resource(resourceFile, dest, type));	
				}
			}
		}
	}
	
	public function getResourcesByType(type:String):Array<Resource>
	{
		if(resourcesByType.exists(type))
		{
			return resourcesByType.get(type);
		}
		return null;
		
	}
	
	public function addResource(resource:Resource):Void
	{
		resources.push(resource);
		
		if(!resourcesByType.exists(resource.type))
		{
			resourcesByType.set(resource.type, []);
		}
		
		var a:Array<Resource> = resourcesByType.get(resource.type);
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
	
	public function new(file:File, dest:String, type:String):Void
	{
		this.file = file;
		this.dest = dest;
		this.type = type;
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
