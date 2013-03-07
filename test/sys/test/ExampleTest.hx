package;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

/**
* Auto generated ExampleTest for MassiveUnit. 
* This is an example test class can be used as a template for writing normal and async tests 
* Refer to munit command line tool for more information (haxelib run munit)
*/
class ExampleTest 
{
	private var timer:Timer;
	
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
	public function testExample():Void
	{
		Assert.isTrue(true);
	}
	/*
	@Test("Async")
	public function testAsyncExample(asyncFactory:AsyncFactory):Void
	{
		var handler:Dynamic = asyncFactory.createHandler(this, onTestAsyncExampleComplete, 300);
		timer = Timer.delay(handler, 200);
	}
	*/
	private function onTestAsyncExampleComplete():Void
	{
		Assert.isFalse(false);
	}

}