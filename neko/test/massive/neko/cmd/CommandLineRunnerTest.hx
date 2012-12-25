package massive.neko.cmd;

import massive.munit.Assert;
import massive.neko.cmd.CommandLineRunner;
import massive.neko.cmd.CommandMock;
import massive.haxe.log.Log;

import massive.neko.cmd.Console;
import massive.neko.cmd.ConsoleMock;

class CommandLineRunnerTest 
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
	
	//-------- properties
	@Test
	public function testSetConsole():Void
	{
		var console:Console = new ConsoleMock("mock");	
		var app:CommandLineRunner = new CommandLineRunnerMock(console);


		Assert.isNotNull(app.console);
		
		Assert.areEqual(Log.logLevel, LogLevel.console);
		
	
		var console:Console = new ConsoleMock("mock -mlib-log");	
		var app:CommandLineRunner = new CommandLineRunnerMock(console);
		
		
		Assert.areEqual(Log.logLevel, LogLevel.debug);
		
		var console:Console = new ConsoleMock("mock -mlib-log info");	
		var app:CommandLineRunner = new CommandLineRunnerMock(console);
		
		Assert.areEqual(Log.logLevel, LogLevel.info);
		
		
		Log.logLevel = LogLevel.console;
		
	
	}
	//-------- methods	
	@Test
	public function testMapCommand():Void
	{
		var app:CommandLineRunner = new CommandLineRunnerMock();
		

		app.mapCommand(CommandMock, "mock");
		
		Assert.areEqual(1, app.commands.length);
		
		var cmdDef:CommandDef = app.commands[0];
		
		Assert.areEqual(CommandMock, cmdDef.command);
		Assert.areEqual("mock", cmdDef.name);
		Assert.isNull(cmdDef.alt);
		Assert.areEqual("", cmdDef.description);
		Assert.isNull(cmdDef.help);
		Assert.isFalse(cmdDef.hidden);

	
		var app:CommandLineRunner = new CommandLineRunnerMock();
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", true);

		Assert.areEqual(1, app.commands.length);

		var cmdDef:CommandDef = app.commands[0];

		Assert.areEqual(CommandMock, cmdDef.command);
		Assert.areEqual("mock", cmdDef.name);
		Assert.areEqual(1, cmdDef.alt.length);
		Assert.areEqual("description", cmdDef.description);
		Assert.areEqual("help", cmdDef.help);
		Assert.isTrue(cmdDef.hidden);

	}
	
	
	@Test
	public function testMapHiddenCommand():Void
	{
		var app:CommandLineRunner = new CommandLineRunnerMock();
		
		app.mapHiddenCommand(CommandMock);
		
		Assert.areEqual(1, app.commands.length);
		
		var cmdDef:CommandDef = app.commands[0];
		
		Assert.areEqual(CommandMock, cmdDef.command);
		Assert.isNull(cmdDef.name);
		Assert.isNull(cmdDef.alt);
		Assert.areEqual("", cmdDef.description);
		Assert.isNull(cmdDef.help);
		Assert.isTrue(cmdDef.hidden);
	
	}
	
	
	@Test
	public function testGetCommandFromString():Void
	{
		var console:Console = new ConsoleMock("mock");
		var app:CommandLineRunner = new CommandLineRunnerMock(console);

		app.mapCommand(CommandMock, "mock", ["m"], "description", "help");
		
		Assert.areEqual(app.getCommandFromString("mock"), CommandMock);
		

	}
	
	@Test
	public function runShouldPrintHelpAndSafeExitWhenNoCommandArg():Void
	{
		//no command
		CommandMock.instance = null;

		var console:Console = new ConsoleMock();
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", false);

		app.run();

		Assert.isNull(CommandMock.instance);
		Assert.isTrue(app.printedHelp);
		Assert.areEqual(0, app.exitCode);
	}
	
	@Test
	public function runShouldExecuteCommandOnValidCommandNameArg():Void
	{
		
		//valid command
		CommandMock.instance = null;
		
		var console:Console = new ConsoleMock("mock");
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", false);
		
		app.run();
		
		Assert.isTrue(CommandMock.instance.isInitialised);
		Assert.isTrue(CommandMock.instance.isExecuted);
		Assert.areEqual(0, app.exitCode);
	}
		
	@Test
	public function runShouldExecuteCommandOnValidCommandShortKeyArg():Void
	{
		//command shortkey
		CommandMock.instance = null;
	
		var console:Console = new ConsoleMock("m");
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", false);

		app.run();

		Assert.isTrue(CommandMock.instance.isInitialised);
		Assert.isTrue(CommandMock.instance.isExecuted);
		Assert.areEqual(0, app.exitCode);
	}
		
	@Test
	public function runShouldPrintHelpAndExitOnInvalidCommandNameArg():Void
	{
		
		
		//invalid command
		CommandMock.instance = null;
		var console:Console = new ConsoleMock("foo");
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", false);

		app.run();
		Assert.isNull(CommandMock.instance);
		Assert.isTrue(app.printedHelp);
		Assert.areEqual(1, app.exitCode);
	}
	
	@Test
	public function runShouldPrintHelpOnHelpArg():Void
	{	
		//general help
		CommandMock.instance = null;
		var console:Console = new ConsoleMock("help");
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", false);

		app.run();
		
		Assert.isTrue(app.printedHelp);
		Assert.areEqual(0, app.exitCode);
	}
	
	@Test
	public function runShouldPrintCommandHelpOnHelpCommandArg():Void
	{

		//command help
		CommandMock.instance = null;
		var console:Console = new ConsoleMock("help mock");
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", false);

		app.run();
		
		Assert.isFalse(app.printedHelp);
		Assert.isNotNull(app.printedCommandDef);
		Assert.areEqual(app.getCommandDefFromString("mock"), app.printedCommandDef);
		Assert.areEqual(0, app.exitCode);
	}
		
	@Test
	public function runShouldPrintHelpAndExitOnInvalidHelpCommandArg():Void
	{
		
		//invalid command help
		CommandMock.instance = null;
		var console:Console = new ConsoleMock("help foo");
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", false);

		app.run();
		Assert.isTrue(app.printedHelp);
		Assert.isNull(app.printedCommandDef);
		Assert.areEqual(1, app.exitCode);
		
	}
	@Test
	public function runShouldPrintCommandHelpOnHiddenHelpCommandArg():Void
	{	
		//hidden command help
		//command help
		CommandMock.instance = null;
		var console:Console = new ConsoleMock("help m");
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(CommandMock, "mock", ["m"], "description", "help", true);

		app.run();
		
		
		Assert.isFalse(app.printedHelp);
		Assert.isNotNull(app.printedCommandDef);
		Assert.areEqual(app.getCommandDefFromString("mock"), app.printedCommandDef);
		Assert.areEqual(0, app.exitCode);

	
	}
	
	
	@Test
	public function runShouldSkipCommandOnValidCommandNameArg():Void
	{
		
		//valid command
		CommandMock.instance = null;
		
		var console:Console = new ConsoleMock("mock");
		var app:CommandLineRunnerMock = new CommandLineRunnerMock(console);
		app.mapCommand(SkippableCommandMock, "mock", ["m"], "description", "help", false);
		
		app.run();
		
		Assert.isTrue(SkippableCommandMock.instance.isInitialised);
		Assert.isTrue(SkippableCommandMock.instance.skip);
		
		Assert.isFalse(SkippableCommandMock.instance.isExecuted);
		
		Assert.areEqual(0, app.exitCode);
	}
	
	

	

}