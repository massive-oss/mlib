package massive.neko.util;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import massive.neko.io.File;
import massive.neko.util.ZipUtil;
import massive.neko.cmd.Console;


class ZipUtilTest 
{
	
	private var current:File;
	private var currentPath:String;

	
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
		var console:Console = new Console();
		current = File.current.resolveDirectory("temp");
		currentPath = current.nativePath;
	}
	
	@After
	public function tearDown():Void
	{
		try
		{
			if(current.exists)
			{
				current.deleteDirectory(true);
			}
		}
		catch(e:Dynamic)
		{
			trace(e + "\n" + current.toDebugString());
		}

	}
	
	@Test
	public function testConvertDirectoryToZipEntries():Void
	{
		var dir:File = current.resolvePath("tmp1");
		var file:File = dir.resolvePath("file.txt", true);
		
		var files:Array<Dynamic> = ZipUtil.convertDirectoryToZipEntries(dir);
		
		Assert.isTrue(files.length == 1);
		
		var entry:Dynamic = files[0];

		Assert.areEqual("file.txt", entry.fileName);
		Assert.isNotNull(entry.data);
		Assert.isNotNull(entry.fileTime);
		
		try
		{
			var zipFile:File = current.resolvePath("tmp.zip");
			var zip = neko.io.File.write(zipFile.nativePath, true);
			neko.zip.Writer.writeZip(zip, files, -1);
			zip.close();
			Assert.isTrue(zipFile.exists);
		}
		catch(e:Dynamic)
		{
			Assert.fail(e);
		}
		
	}
	
	@Test
	public function testZipDirectory():Void
	{
		var dir:File = current.resolvePath("tmp1");
		var file:File = dir.resolvePath("file.txt", true);
		
		var zipFile:File = current.resolvePath("tmp.zip");
		
		ZipUtil.zipDirectory(zipFile, dir);
		
		Assert.isTrue(zipFile.exists);
		
		
	}
}