package massive.haxe.util;

class TemplateUtil
{
	public function new():Void{}
	
	static public function getTemplate(id:String, ?properties:Dynamic):String
	{
		var resource = haxe.Resource.getString(id);
		var template = new haxe.Template(resource);
		return template.execute(properties);
	}
}