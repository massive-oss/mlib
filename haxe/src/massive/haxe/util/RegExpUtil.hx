package massive.haxe.util;

class RegExpUtil
{
	public static var SVN_REGEX:EReg = ~/\.svn/;
	public static var DS_STORE:EReg = ~/\.DS_Store$/;
	public static var HIDDEN_FILES:EReg = 	~/\.(svn)|(DS_Store)|(\.tmbuild)/;
}
