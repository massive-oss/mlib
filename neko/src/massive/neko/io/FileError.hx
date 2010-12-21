package massive.neko.io;

import massive.neko.io.File;
import haxe.PosInfos;


class FileError
{
	public var error:String;
	public var message:String;
	public var file:File;
	public var posInfos:PosInfos;
	
	public function new(error:String, file:File, ?message:Dynamic=null, ?posInfos:PosInfos=null):Void
	{
		this.error = error;
		this.file = file;
		this.message = Std.string(message);
		this.posInfos = posInfos;
	}
	
	public function toString():String
	{
		return error + "\n " + (message != null ? "message: " + message + "\n" : "") + (file != null ? file.toDebugString() + "\n" : "" )+ posInfos + "\n" + haxe.Stack.toString(haxe.Stack.callStack());
	}
}

