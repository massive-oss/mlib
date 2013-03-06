import massive.munit.TestSuite;

import ExampleTest;
import massive.sys.cmd.CommandLineRunnerTest;
import massive.sys.cmd.CommandTest;
import massive.sys.cmd.ConsoleTest;
import massive.sys.io.FileTest;
import massive.sys.util.PathUtilTest;
import massive.sys.util.ZipUtilTest;

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
		add(massive.sys.cmd.CommandLineRunnerTest);
		add(massive.sys.cmd.CommandTest);
		add(massive.sys.cmd.ConsoleTest);
		add(massive.sys.io.FileTest);
		add(massive.sys.util.PathUtilTest);
		add(massive.sys.util.ZipUtilTest);
	}
}
