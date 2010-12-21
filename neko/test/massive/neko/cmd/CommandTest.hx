package massive.neko.cmd;

import massive.munit.Assert;

class CommandTest 
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
	
	//-------- methods
	
	@Test
	public function testConstructor():Void
	{
		var cmd:Command = new CommandMock();
		
		Assert.isNotNull(cmd.beforeCommands);
		Assert.isNotNull(cmd.afterCommands);
		
		
	}
	
	
	@Test
	public function testInitialise():Void
	{
		var cmd:CommandMock = new CommandMock();
		cmd.initialise();
		Assert.isTrue(cmd.isInitialised);	
	}
	
	@Test
	public function testExecute():Void
	{
		var cmd:CommandMock = new CommandMock();
		cmd.execute();
		Assert.isTrue(cmd.isExecuted);	
	}
}