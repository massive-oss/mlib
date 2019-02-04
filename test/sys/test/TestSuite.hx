import massive.munit.TestSuite;

import ExampleTest;
import massive.sys.cmd.CommandTest;
import massive.sys.cmd.ConsoleTest;
import massive.sys.cmd.CommandLineRunnerTest;
import massive.sys.haxelib.HaxelibTest;
import massive.sys.util.ZipUtilTest;
import massive.sys.util.PathUtilTest;
import massive.sys.io.FileTest;

/**
 * Auto generated Test Suite for MassiveUnit.
 * Refer to munit command line tool for more information (haxelib run munit)
 */

class TestSuite extends massive.munit.TestSuite
{		

	public function new()
	{
		super();

		add(ExampleTest);
		add(massive.sys.cmd.CommandTest);
		add(massive.sys.cmd.ConsoleTest);
		add(massive.sys.cmd.CommandLineRunnerTest);
		add(massive.sys.haxelib.HaxelibTest);
		add(massive.sys.util.ZipUtilTest);
		add(massive.sys.util.PathUtilTest);
		add(massive.sys.io.FileTest);
	}
}
