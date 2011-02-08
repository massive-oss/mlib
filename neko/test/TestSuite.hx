import massive.munit.TestSuite;

import ExampleTest;
import massive.neko.cmd.CommandLineRunnerTest;
import massive.neko.cmd.CommandTest;
import massive.neko.cmd.ConsoleTest;
import massive.neko.io.FileTest;
import massive.neko.util.PathUtilTest;
import massive.neko.util.ZipUtilTest;

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
		add(massive.neko.cmd.CommandLineRunnerTest);
		add(massive.neko.cmd.CommandTest);
		add(massive.neko.cmd.ConsoleTest);
		add(massive.neko.io.FileTest);
		add(massive.neko.util.PathUtilTest);
		add(massive.neko.util.ZipUtilTest);
	}
}
