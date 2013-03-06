package massive.sys.cmd;

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
		
		Assert.isNotNull(cmd.preRequisites);
		Assert.isNotNull(cmd.postRequisites);
		
		
	}
	
	
	@Test
	public function testSetData():Void
	{
		var cmd:CommandMock = new CommandMock();
		cmd.setData("hello");
		Assert.areEqual("hello", Std.string(cmd.data));	
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
	
	
	@Test
	public function testAddPreRequisite():Void
	{
		var cmd:CommandMock = new CommandMock();
		Assert.areEqual(0, cmd.preRequisites.length);
	
		cmd.addPreRequisite(CommandMock);
		Assert.areEqual(1, cmd.preRequisites.length);
		Assert.areEqual(CommandMock, cmd.preRequisites[0].commandClass);
		Assert.areEqual(null, cmd.preRequisites[0].data);
		
		cmd.addPreRequisite(CommandMock, "foo");
		Assert.areEqual(2, cmd.preRequisites.length);
		
		Assert.areEqual(CommandMock, cmd.preRequisites[1].commandClass);
		Assert.areEqual("foo", cmd.preRequisites[1].data);
	
	}
	
	@Test
	public function testAddPostRequisite():Void
	{
		var cmd:CommandMock = new CommandMock();
		Assert.areEqual(0, cmd.postRequisites.length);
	
		cmd.addPostRequisite(CommandMock);
		Assert.areEqual(1, cmd.postRequisites.length);
		Assert.areEqual(CommandMock, cmd.postRequisites[0].commandClass);
		Assert.areEqual(null, cmd.postRequisites[0].data);
		
		cmd.addPostRequisite(CommandMock, "foo");
		Assert.areEqual(2, cmd.postRequisites.length);
		
		Assert.areEqual(CommandMock, cmd.postRequisites[1].commandClass);
		Assert.areEqual("foo", cmd.postRequisites[1].data);
	
	}
	
}