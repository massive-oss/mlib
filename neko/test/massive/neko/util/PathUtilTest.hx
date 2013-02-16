package massive.sys.util;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

/**
* Auto generated ExampleTest for MassiveUnit. 
* This is an example test class can be used as a template for writing normal and async tests 
* Refer to munit command line tool for more information (haxelib run munit)
*/
class PathUtilTest 
{
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
	}
	
	@AfterClass
	public function afterClass():Void
	{
	}
	
	@Before
	public function setup():Void
	{
	}
	
	@After
	public function tearDown():Void
	{
	}
	
	
	@Test
	public function testIsAbsolutePath():Void
	{
		Assert.isTrue(PathUtil.isAbsolutePath("/Users/Shared"));
		Assert.isTrue(PathUtil.isAbsolutePath("C:\\Users\\Public"));
		Assert.isTrue(PathUtil.isAbsolutePath("C:\\Users/Public"));
		
		Assert.isFalse(PathUtil.isAbsolutePath("dir"));
		Assert.isFalse(PathUtil.isAbsolutePath("dir/sub"));
		Assert.isFalse(PathUtil.isAbsolutePath("dir/sub"));		
		Assert.isFalse(PathUtil.isAbsolutePath("../sibling/dir/sub"));		
	}
	
	@Test
	public function testIsRelativePath():Void
	{
		Assert.isFalse(PathUtil.isRelativePath("/Users/Shared"));
		Assert.isFalse(PathUtil.isRelativePath("C:\\Users\\Public"));
		Assert.isFalse(PathUtil.isRelativePath("C:\\Users/Public"));
		
		Assert.isTrue(PathUtil.isRelativePath("dir"));
		Assert.isTrue(PathUtil.isRelativePath("dir/sub"));
		Assert.isTrue(PathUtil.isRelativePath("dir/sub"));
		Assert.isTrue(PathUtil.isRelativePath("../sibling/dir/sub"));
		
	}
	
	@Test
	public function testIsValidDirectoryName():Void
	{
		Assert.isTrue(PathUtil.isValidDirectoryName("bin_123-AZ dir"));
		Assert.isTrue(PathUtil.isValidDirectoryName(".svn"));
		Assert.isFalse(PathUtil.isValidDirectoryName("$12z*"));	
	}

	@Test
	public function testIsValidHaxeClassName():Void
	{
		Assert.isTrue(PathUtil.isValidHaxeClassName("ExampleClass.hx"));
		Assert.isTrue(PathUtil.isValidHaxeClassName("Lib.hx"));
		
		Assert.isFalse(PathUtil.isValidHaxeClassName("$12z*"));
		Assert.isFalse(PathUtil.isValidHaxeClassName("NoFileExtension"));
		Assert.isFalse(PathUtil.isValidHaxeClassName("lowerCase.hx"));
		Assert.isFalse(PathUtil.isValidHaxeClassName("Two Words.hx"));
		Assert.isFalse(PathUtil.isValidHaxeClassName("1NumberBefore.hx"));	
		Assert.isFalse(PathUtil.isValidHaxeClassName("Words-With_Dashes.hx"));
	}
}