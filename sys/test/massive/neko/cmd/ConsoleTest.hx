package massive.sys.cmd;

import massive.sys.io.File;
import massive.sys.io.FileSys;
import massive.munit.Assert;

class ConsoleTest 
{
	private var current:File;
	private var console:Console;
	
	public function new() 
	{
		
	}
	
	@BeforeClass
	public function beforeClass():Void
	{
		current = File.current;
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
		FileSys.setCwd(current.nativePath);
	}
	
	//-------- methods
	
	@Test
	public function testConstructorDirectories():Void
	{
		var args:String;
		args = "";
		console = new ConsoleMock(args);
		
		Assert.areEqual(current.toString(), console.originalDir.toString());
		Assert.areEqual(current.toString(), console.dir.toString());
		
		args = current.toString();
		console = new ConsoleMock(args);
		
		Assert.areEqual(current.toString(), console.originalDir.toString());
		Assert.areEqual(current.toString(), console.dir.toString());

		
		args = current.parent.toString();
		console = new ConsoleMock(args);
	
		Assert.areEqual(current.toString(), console.originalDir.toString());
		Assert.areEqual(current.parent.toString(), console.dir.toString());

		
	}
	

	@Test
	public function testGetOption():Void
	{
		var args:String = "cmd arg1 arg2 -option1 -option2 hello world -option3";
		console = new ConsoleMock(args);
		
		Assert.areEqual("true", console.getOption("option1"));
		Assert.areEqual("true", console.getOption("-option1"));
		Assert.isNull(console.getOption("--option1"));
		
		Assert.areEqual("hello world", console.getOption("option2"));
		
		Assert.areEqual("true", console.getOption("option3"));
		
		Assert.isNull(console.getOption("option4"));
		
		var args:String = "-option2 'hello world' -option3 'foo bar'";
		console = new ConsoleMock(args);
		Assert.areEqual("hello world", console.getOption("option2"));
		Assert.areEqual("foo bar", console.getOption("option3"));
		
		var args:String = "foo bar'";
		console = new ConsoleMock(args);
		Assert.isNull(console.getOption("foo"));
	
	}
	
	@Test
	public function testGetOptionPrompt():Void
	{
		var args:String = "";

		var mock:ConsoleMock = new ConsoleMock(args);
		console = mock;
		
	 	var result:String;
	
		result = console.getOption("foo");
		
		Assert.isNull(mock.promptMsg);
		Assert.isNull(result);
		
		
		result = console.getOption("foo", "message");
		
		
		Assert.areEqual("message", mock.promptMsg);
		Assert.areEqual("mock", result);
	}
	
	@Test
	public function testSetOption():Void
	{
		var args:String = "";
		console = new ConsoleMock(args);

		Assert.isNull(console.getOption("foo"));
		console.setOption("foo", "bar");
		Assert.areEqual(console.getOption("foo"), "bar");
		
	}
	
	@Test
	public function testGetNextArg():Void
	{
		var args:String = null;
		console = new ConsoleMock(args);
		
		Assert.isNull(console.getNextArg());
		
		var args:String = "foo bar";
		console = new ConsoleMock(args);
		
		Assert.areEqual("foo", console.getNextArg());
		Assert.areEqual("bar", console.getNextArg());
		Assert.isNull(console.getNextArg());
		
		
		var args:String = "cmd arg1 arg2 -option1 -option2 hello world -option3";
		console = new ConsoleMock(args);
		
		Assert.areEqual("cmd", console.getNextArg());
		Assert.areEqual("arg1", console.getNextArg());
		Assert.areEqual("arg2", console.getNextArg());
		Assert.isNull(console.getNextArg());
		
	}
	
	@Test
	public function testGetNextArgPrompt():Void
	{
		var args:String = "";

		var mock:ConsoleMock = new ConsoleMock(args);
		console = mock;
		
	 	var result:String = console.getNextArg();

		Assert.isNull(mock.promptMsg);
		Assert.isNull(result);

		result = console.getNextArg("message");
		Assert.areEqual("message", mock.promptMsg);
		Assert.areEqual("mock", result);
	}
	
	@Test
	public function prompt():Void
	{
		var mock:ConsoleMock = new ConsoleMock();
		Assert.isNull(mock.promptMsg);
		var result = mock.prompt("message");
		Assert.areEqual("message", mock.promptMsg);
		Assert.areEqual("mock", result);
	
	}
	
	
	//-------- properties
	
	@Test
	public function testOptions():Void
	{
		var args:String = "cmd arg1 arg2 -option1 -option2 hello world -option3";
		console = new ConsoleMock(args);
		
		Assert.areEqual("true", console.options.get("option1"));
		Assert.areEqual("hello world", console.options.get("option2"));
		Assert.areEqual("true", console.options.get("option3"));
		Assert.isNull(console.options.get("option4"));
	
	}
	
	@Test
	public function testArgs():Void
	{
		var args:String = "cmd arg1 arg2 -option1 -option2 hello world -option3";
		console = new ConsoleMock(args);
		
		Assert.areEqual(3, console.args.length);
		Assert.areEqual("cmd", console.args[0]);
		Assert.areEqual("arg1", console.args[1]);
		Assert.areEqual("arg2", console.args[2]);
		
		
		var args:String = null;
		console = new ConsoleMock(args);
		
		Assert.areEqual(0, console.args.length);
	}


}