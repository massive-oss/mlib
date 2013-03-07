package massive.sys.io;

import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;


import massive.sys.cmd.Console;
import massive.sys.io.File;
import massive.sys.io.FileException;

/**
* Auto generated ExampleTest for MassiveUnit. 
* This is an example test class can be used as a templa
*  te for writing normal and async tests 
* Refer to munit command line tool for more information (haxelib run munit)
*/
class FileTest 
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
	public function testStaticCurrent():Void
	{
		var path:String = FileSys.getCwd();
		
		
		Assert.areEqual(path, File.current.nativePath);
		Assert.isTrue(FileSys.exists(path));
		
	}

	@Test
	public function testStaticSeperator():Void
	{
		if(FileSys.isWindows)
		{
			Assert.areEqual("\\", File.seperator);
		}
		else
		{
			Assert.areEqual("/", File.seperator);
			}
		
	}

	@Test
	public function testStaticCreate():Void
	{
		var file:File;

		if(FileSys.isWindows)
		{
			file = File.create("C:\\Users\\Public\\");
			Assert.isNotNull(file);
			Assert.isTrue(file.isDirectory);
			
			file = File.create("C:\\Users\\Public\\file.txt");
			Assert.isNotNull(file);
			Assert.isTrue(file.isFile);

			file = File.create("C:\\Users\\Public");
			Assert.isNotNull(file);               			
			Assert.isTrue(file.isDirectory);      

			file = File.create("C:\\Users\\Public\\.svn");
			Assert.isNotNull(file);
			Assert.isTrue(file.isUnknown);
			
			file = File.create("C:\\Users\\Public\\.svn\\tmp");
			Assert.isNotNull(file);
			Assert.isTrue(file.isDirectory);
			
			file = File.create("C:\\Users\\Public\\dir with spaces");
			Assert.isNotNull(file);
			Assert.isTrue(file.isDirectory);	
		}
		else
		{
			file = File.create("/Users/Shared/");
			Assert.isNotNull(file);
			Assert.isTrue(file.isDirectory);
			
			file = File.create("/Users/Shared/file.txt");
			Assert.isNotNull(file);
			Assert.isTrue(file.isFile);
			
			file = File.create("/Users/Shared");
			Assert.isNotNull(file);
			Assert.isTrue(file.isDirectory);
			
			file = File.create("/Users/Shared/.svn");
			Assert.isNotNull(file);
			Assert.isTrue(file.isUnknown);
			
			file = File.create("/Users/Shared/.svn/tmp");
			Assert.isNotNull(file);
			Assert.isTrue(file.isDirectory);	
		}
		
		
		//relative path without a reference path;
		try
		{
			file = File.create("tmp");
			Assert.fail("File.create should throw FileException for a relative path without a reference file");
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("File.create should throw FileException but throw different exception " + e);
		}
		
	
	
		
		//double arg
		
		file = File.create("../", current);
		Assert.isNotNull(file);
		Assert.areEqual(current.parent.nativePath, file.nativePath);
		
		
		file = File.create(".");
		Assert.isNotNull(file);
		Assert.areEqual(File.current.nativePath, file.nativePath);
		
		
		file = File.create(".", current);
		Assert.isNotNull(file);
		Assert.areEqual(current.nativePath, file.nativePath);
		
		

		file = File.create("tmp", current);
		Assert.isNotNull(file);
		Assert.isTrue(file.isDirectory);
		
		file = File.create("tmp/", current);
		Assert.isNotNull(file);
		Assert.isTrue(file.isDirectory);
		
		file = File.create("tmp/sub", current);
		Assert.isNotNull(file);
		Assert.isTrue(file.isDirectory);
		
		file = File.create("tmp/sub/", current);
		Assert.isNotNull(file);
		Assert.isTrue(file.isDirectory);
		
		file = File.create("tmp/file.txt", current);
		Assert.isNotNull(file);
		Assert.isTrue(file.isFile);

		file = File.create("tmp\\file.txt", current);
		Assert.isNotNull(file);
		Assert.isTrue(file.isFile);
	
		file = File.create("tmp/.svn", current);
		Assert.isNotNull(file);
		Assert.isTrue(file.isUnknown);
		
	}

	@Test
	public function testStaticCreateTempFile():Void
	{
		var file:File = File.createTempFile("temp");
		Assert.isTrue(file.isFile);
		Assert.isTrue(file.exists);
		
		var content:String = file.readString();
		Assert.areEqual("temp", content);
	}
	
	@Test
	public function testStaticCreateTempDirectory():Void
	{
		var file:File = File.createTempDirectory();
		Assert.isTrue(file.isDirectory);
		Assert.isTrue(file.exists);
	}
	
	@Test
	public function testStaticDeleteTempFiles():Void
	{
		var file:File = File.createTempFile("temp");
		var dir:File = File.createTempDirectory();
		
		File.deleteTempFiles();
		
		Assert.isFalse(file.exists);
		Assert.isFalse(dir.exists);
	}
	
	
	@Test
	public function testExists():Void
	{
		//new file
		var file:File = current.resolvePath("tmp.txt");
		Assert.isNotNull(file);
		Assert.isFalse(file.exists);
		file.createFile();
		Assert.isTrue(file.exists);
		
		//new file;
		file = current.resolvePath("tmp/dir");
		Assert.isNotNull(file);
		Assert.isFalse(file.exists);
		file.createDirectory();
		Assert.isTrue(file.exists);
	
	
		//existing files
		if(FileSys.isWindows)
		{
			file = File.create("C:\\Users\\Public");
			Assert.isNotNull(file);
			Assert.isTrue(file.exists);
		}
		else
		{
			file = File.create("/Users/Shared/");
			Assert.isNotNull(file);
			Assert.isTrue(file.exists);
		}
	}
	
	@Test
	public function testIsType():Void
	{

		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");
		
		Assert.isFalse(file.isDirectory);
		Assert.isTrue(file.isFile);
		Assert.isFalse(file.isUnknown);
		
		Assert.isTrue(dir.isDirectory);
		Assert.isFalse(dir.isFile);
		Assert.isFalse(dir.isUnknown);
		
		Assert.isFalse(unknown.isDirectory);
		Assert.isFalse(unknown.isFile);
		Assert.isTrue(unknown.isUnknown);
		
		
		unknown.createDirectory();
		Assert.isTrue(unknown.isDirectory);
		Assert.isFalse(unknown.isUnknown);
		Assert.isFalse(unknown.isFile);
		
		unknown.deleteDirectory();
		
		unknown = current.resolvePath(".tmp");
		
		Assert.isFalse(unknown.isDirectory);
		
		unknown.createFile("test");
		
		Assert.isFalse(unknown.isDirectory);
		Assert.isFalse(unknown.isUnknown);
		Assert.isTrue(unknown.isFile);
		
	}
	
	@Test
	public function testIsNativeDirectory():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		
		Assert.isFalse(file.isNativeDirectory);
		Assert.isFalse(dir.isNativeDirectory);
		
		dir.createDirectory();
		Assert.isTrue(dir.isNativeDirectory);
		
		file.createFile();
		Assert.isFalse(file.isNativeDirectory);
	}
	
	@Test
	public function testNativePath():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		
		Assert.areEqual(currentPath + "tmp.txt", file.nativePath);
		Assert.areEqual(currentPath + "tmp" + File.seperator, dir.nativePath);
		
		file.createFile("temp");
		dir.createDirectory();
		
		Assert.isTrue(FileSys.exists(file.nativePath));
		Assert.isTrue(FileSys.exists(dir.nativePath));
		
	}
	
	@Test
	public function testFileName():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");
		
		Assert.areEqual("tmp.txt", file.fileName);
		Assert.isNull(dir.fileName);
		Assert.areEqual(".tmp", unknown.fileName);
	
	}
	
	@Test
	public function testName():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");
		
		Assert.areEqual("tmp", file.name);
		Assert.areEqual("tmp", dir.name);
		Assert.areEqual(".tmp", unknown.name);
	}
	
	
	@Test
	public function testExtension():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");
		
		Assert.areEqual("txt", file.extension);
		Assert.isNull(dir.extension);
		Assert.isNull(unknown.extension);
	}
	
	@Test
	public function testParent():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");
	
		Assert.areEqual(current.nativePath, file.parent.nativePath);
		Assert.areEqual(current.nativePath, dir.parent.nativePath);
		Assert.areEqual(current.nativePath, unknown.parent.nativePath);
	}
	
	@Test
	public function testIsEmpty():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");
			
		Assert.isFalse(file.isEmpty);
		Assert.isFalse(unknown.isEmpty);
		
		dir.createDirectory();
		Assert.isTrue(dir.isEmpty);
		
		dir.resolvePath("sub", true);
		Assert.isFalse(dir.isEmpty);
	}	
	
	@Test
	public function testToString():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");

		Assert.areEqual(currentPath + "tmp.txt", file.toString());
		Assert.areEqual(currentPath + "tmp" + File.seperator, dir.toString());
		Assert.areEqual(currentPath + ".tmp", unknown.toString());
	}
	
	
	
	
	@Test
	public function testResolvePathOneArg():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");

		Assert.isNotNull(file);
		Assert.isNotNull(dir);
		Assert.isNotNull(unknown);
		
		Assert.isFalse(file.exists);
		Assert.isFalse(dir.exists);
		Assert.isFalse(unknown.exists);
		
		Assert.isTrue(file.isFile);	
		Assert.isTrue(dir.isDirectory);
		Assert.isTrue(unknown.isUnknown);
		
		//secondary cases
		var newDir:File;
		var newFile:File;

		newDir = dir.resolvePath("../");
		Assert.areEqual(current.nativePath, newDir.nativePath);
		
		
		newDir = dir.resolvePath(".");
		Assert.areEqual(dir.nativePath, newDir.nativePath);
		
		newDir = dir.resolvePath("./../");
		Assert.areEqual(current.nativePath, newDir.nativePath);
		
		
		newDir = file.resolvePath(".");
		Assert.areEqual(current.nativePath, newDir.nativePath);
		
		
		var file2:File = current.resolvePath("tmp2.txt");
		
		var newFile = file.resolvePath("./tmp2.txt");
		Assert.areEqual(file2.nativePath, newFile.nativePath);
		
		
		newDir = current.resolvePath("tmp/");
		Assert.isTrue(newDir.isDirectory);	
		Assert.areEqual(dir.nativePath, newDir.nativePath);


		newDir = current.resolvePath("tmp/sub");
		Assert.isTrue(newDir.isDirectory);

		newDir = current.resolvePath("tmp\\sub");
		Assert.isTrue(newDir.isDirectory);
		
		
	

		
	}
	
	@Test
	public function testResolvePathTwoArg():Void
	{
		var file:File;
		var dir:File;
		var unknown:File;
		//force creation
		file = current.resolvePath("tmp.txt", true);
		dir = current.resolvePath("tmp", true);
		unknown = current.resolvePath(".tmp", true);

		Assert.isNotNull(file);
		Assert.isNotNull(dir);
		Assert.isNotNull(unknown);

		Assert.isTrue(file.exists);
		Assert.isTrue(dir.exists);
		Assert.isTrue(unknown.exists);
		
		Assert.isTrue(unknown.isFile);
		Assert.isFalse(unknown.isDirectory);
	}
	
	@Test
	public function testResolvePathThreeArg():Void
	{
		var file:File;
		var dir:File;
		var unknown:File;	
		
		//resoolve as current
		file = current.resolvePath("tmp.txt", false, FileType.DIRECTORY);
		unknown = current.resolvePath(".tmp", false,  FileType.DIRECTORY);

		Assert.isTrue(file.isDirectory);
		Assert.isTrue(unknown.isDirectory);
	}
	
	@Test
	public function testResolveDirectory():Void
	{
		var dir:File = current.resolveDirectory("tmp");
		var dir2:File = current.resolveDirectory("tmp/");
		Assert.isTrue(dir.isDirectory);
		Assert.isTrue(dir2.isDirectory);
		Assert.areEqual(dir.nativePath,dir2.nativePath);		
	}
	
	
	@Test
	public function testResolveFile():Void
	{
		var dir1:File = current.resolvePath("tmp1", true);
		var file1:File = dir1.resolvePath("file.txt", true);

		var dir2:File = current.resolvePath("tmp2", true);

		var poorFileName:File = dir1.resolveFile("build", true);
		
		Assert.isTrue(poorFileName.isFile);
		Assert.isTrue(poorFileName.exists);
		
		
		dir1.copyTo(dir2);
		
		var result:File = dir2.resolvePath("build");
	
		Assert.isTrue(result.exists);
		Assert.isTrue(result.isFile);
		
		result = dir1.resolvePath("./file.txt");
		Assert.areEqual(file1.nativePath, result.nativePath);
		
		result = dir2.resolvePath("./../tmp1/file.txt");
		Assert.areEqual(file1.nativePath, result.nativePath);
	}
	
	@Test
	public function testGetRelativePath():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");
		
		Assert.areEqual("tmp.txt", current.getRelativePath(file));
		Assert.areEqual("tmp", current.getRelativePath(dir));
		Assert.areEqual(".tmp", current.getRelativePath(unknown));
		
		Assert.areEqual("./", file.getRelativePath(current));
		Assert.areEqual("../", dir.getRelativePath(current));
		Assert.areEqual("./", unknown.getRelativePath(current));
		
		var temp1:File;
		var temp2:File;
		
		temp1 = current.resolvePath("tmp/a/b");
		temp2 = current.resolvePath("tmp/1/2/3");

		Assert.areEqual("../../1/2/3", temp1.getRelativePath(temp2));
		Assert.areEqual("../../../a/b", temp2.getRelativePath(temp1));
		
		temp1 = current.resolvePath("tmp/a/file.a");
		temp2 = current.resolvePath("tmp/b/sub/file.b");
		
		Assert.areEqual("./../b/sub/file.b", temp1.getRelativePath(temp2));
		Assert.areEqual("./../../a/file.a", temp2.getRelativePath(temp1));
	
		
		temp1 = current.resolvePath("tmp/a/b");
		temp2 = current.resolvePath("tmp/b/sub/file.b");
		
		Assert.areEqual("../../b/sub/file.b", temp1.getRelativePath(temp2));
		Assert.areEqual("./../../a/b", temp2.getRelativePath(temp1));
		


		if(FileSys.isWindows)
		{
			temp1 = File.create("C:\\Users\\Public");
			temp2 = File.create("D:\\Users\\Public");		
			Assert.areEqual(temp2.nativePath, temp1.getRelativePath(temp2));
		}
	}
	
	@Test
	public function testClone():Void
	{
		var file1:File = current.resolvePath("tmp.txt");
		var file2:File = file1.clone();
		
		Assert.areEqual(file1.nativePath, file2.nativePath);
	}

	@Test
	public function testCreateDirectory():Void
	{
		var file:File = current.resolvePath("tmp.txt");
		var dir:File = current.resolvePath("tmp");
		var unknown:File = current.resolvePath(".tmp");

		try
		{
			file.createDirectory();
			Assert.fail("file.createDirectory should throw FileException.");
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("file.createDirectory should throw FileException.");
		}
		
		dir.createDirectory();
		Assert.isTrue(dir.exists);
		
		unknown.createDirectory();
		Assert.isTrue(unknown.exists);
		/*
		var craaaazyDir:File = current.resolveDirectory("`)W*$&08374");
		craaaazyDir.createDirectory();
		
		Assert.isTrue(craaaazyDir.exists);
		Assert.isTrue(craaaazyDir.isNativeDirectory);*/
	}
	
	
	@Test
	public function testDeleteDirectory():Void
	{

		var dir:File = current.resolvePath("tmp");
		var file:File = dir.resolvePath("file.txt");
		
		file.createFile("hello");
		
		Assert.isTrue(dir.exists);
		Assert.isTrue(file.exists);
		
		Assert.isFalse(dir.isEmpty);
		
		dir.deleteDirectory();
		
		Assert.isFalse(dir.exists);
		Assert.isFalse(file.exists);
		
		
		
		var dir:File = current.resolvePath("tmp");
		var file:File = dir.resolvePath("file.txt");
		
		file.createFile("hello");
		
		Assert.isTrue(dir.exists);
		Assert.isTrue(file.exists);
		
		Assert.isFalse(dir.isEmpty);
		
		//set flag to not delete if not empty
		dir.deleteDirectory(false);
		
		Assert.isTrue(dir.exists);
		Assert.isTrue(file.exists);
		
		
		file.deleteFile();
		
		//set flag to not delete if not empty
		dir.deleteDirectory(false);

		Assert.isFalse(dir.exists);
		
		
		file.createFile("hello again");
		
		try
		{
			file.deleteDirectory();
			Assert.fail("deleteDirectory on a file file should throw a FileException " + file.toDebugString());
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("deleteDirectory on a file file should throw a FileException, not a " + e);
		}
		
	
	}
	
	@Test
	public function testDeleteDirectoryContents():Void
	{
		var dir:File = current.resolvePath("tmp");
		var file1:File= dir.resolvePath("file.txt", true);
		var file2:File= dir.resolvePath("file.aaa", true);
		var reg:EReg = ~/\.aaa$/;
	
		Assert.isFalse(dir.isEmpty);
		Assert.isTrue(file1.exists);
		Assert.isTrue(file2.exists);
	
	
		dir.deleteDirectoryContents();
		Assert.isFalse(file1.exists);
		Assert.isFalse(file2.exists);
		Assert.isTrue(dir.isEmpty);
		
		//reset
		file1.createFile("hello");
		file2.createFile("world");
		
	
		dir.deleteDirectoryContents(reg);
		
		Assert.isTrue(file1.exists);
		Assert.isFalse(file2.exists);
		
		
		//reset
		dir.deleteDirectoryContents();
		
		
		file1.createFile("hello");
		file2.createFile("world");
		
		dir.deleteDirectoryContents(reg, true);
		
		Assert.isFalse(file1.exists);
		Assert.isTrue(file2.exists);
	}
	
	@Test
	public function testCreateFile():Void
	{
		var dir:File = current.resolvePath("tmp");
		var file:File = dir.resolvePath("file.txt");
		
		
		Assert.isFalse(file.exists);
		file.createFile("foo");
		Assert.isTrue(file.exists);
		
		Assert.areEqual("foo", file.readString());
		
		try
		{
			file.createFile("foo");
			Assert.fail("Expected FileException because file already existed");
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("Expected FileException but threw " + e);	
		}
		
		
	
		
		try
		{
			dir.createFile("foo");
			Assert.fail("Expected FileException because cannot createFile on a directory");
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("Expected FileException but threw " + e);	
		}
		
	}
	
	@Test
	public function testDeleteFile():Void
	{

		var dir:File = current.resolvePath("tmp", true);
		var file:File = dir.resolvePath("file.txt", true);
		
		
		file.deleteFile();
		
		Assert.isFalse(file.exists);
		file.createFile("foo");
		Assert.isTrue(file.exists);
		
		Assert.areEqual("foo", file.readString());
		
		try
		{
			file.createFile("foo");
			Assert.fail("Expected FileException because file already existed");
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("Expected FileException but threw " + e);	
		}
		
	}
	
	
	@Test
	public function testCopyTo():Void
	{
		var dir1:File = current.resolvePath("tmp1", true);
		var file1:File = dir1.resolvePath("file.txt", true);
		var file2:File= dir1.resolvePath("file.aaa", true);
		
		var dir2:File = current.resolvePath("tmp2", true);
		var reg:EReg = ~/\.aaa$/;
	
		//copying a directory
		
		dir1.copyTo(dir2);
		
		var result:File = dir2.resolvePath("file.txt");
		
		Assert.isTrue(result.exists);
		Assert.isTrue(dir1.exists);
	
		dir2.deleteDirectoryContents();

		
		dir1.copyTo(dir2, true, reg);
		
		result = dir2.resolvePath("file.txt");
		Assert.isFalse(result.exists);
		
		result = dir2.resolvePath("file.aaa");
		Assert.isTrue(result.exists);
		
		dir2.deleteDirectoryContents();
		

		dir1.copyTo(dir2, true, reg, true);
		
		result = dir2.resolvePath("file.txt");
		Assert.isTrue(result.exists);
		
		result = dir2.resolvePath("file.aaa");
		Assert.isFalse(result.exists);
		
		
		//file
		dir2.deleteDirectoryContents();
	
		file1.copyTo(dir2);
		result = dir2.resolvePath("file.txt");
		Assert.isTrue(result.exists);
		
		dir2.deleteDirectoryContents();
	
		file2 = dir2.resolvePath("file_copy.txt");
		file1.copyTo(file2);
		result = dir2.resolvePath("file.txt");
		Assert.isFalse(result.exists);
		result = dir2.resolvePath("file_copy.txt");
		Assert.isTrue(result.exists);
		
		try
		{
			dir2.copyTo(file2);
			Assert.fail("Expected FileException for copying dir to a file");
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("Expected FileException but got " + e);
		}
		
		dir2.deleteDirectoryContents();
	}
		


	
	@Test
	public function testCopyInTo():Void
	{
		var dir1:File = current.resolvePath("tmp1", true);
		var file1:File = dir1.resolvePath("file.txt", true);
		var file2:File= dir1.resolvePath("file.aaa", true);
		
		var dir2:File = current.resolvePath("tmp2", true);
		var reg:EReg = ~/\.aaa$/;
	
		//copying a directory
		
		dir1.copyInto(dir2);
		
		var result:File = dir2.resolvePath("tmp1");
		
		Assert.isTrue(result.exists);
		Assert.isTrue(dir1.exists);
		
		var result:File = dir2.resolvePath("tmp1/file.txt");
		
		Assert.isTrue(result.exists);
		
		
		

	}
	
	
	@Test
	public function testMoveTo():Void
	{
		var dir1:File = current.resolvePath("tmp1", true);
		var file1:File = dir1.resolvePath("file.txt", true);
		var file2:File= dir1.resolvePath("file.aaa", true);
		
		var dir2:File = current.resolvePath("tmp2", true);
		var reg:EReg = ~/\.aaa$/;
	
		//copying a directory
		
		dir1.moveTo(dir2);
		
		var result:File = dir2.resolvePath("file.txt");
		
		Assert.isTrue(result.exists);
		Assert.isFalse(dir1.exists);
	
	
	}
	
	@Test
	public function testMoveInto():Void
	{
		var dir1:File = current.resolvePath("tmp1", true);
		var file1:File = dir1.resolvePath("file.txt", true);
		var file2:File= dir1.resolvePath("file.aaa", true);
		
		var dir2:File = current.resolvePath("tmp2", true);
		var reg:EReg = ~/\.aaa$/;
	
		//copying a directory
		
		dir1.moveInto(dir2);
		
		var result:File = dir2.resolvePath("tmp1");

		Assert.isTrue(result.exists);
		Assert.isFalse(dir1.exists);

		var result:File = dir2.resolvePath("tmp1/file.txt");

		Assert.isTrue(result.exists);
	
	
	}
	
	@Test
	public function testWriteString():Void
	{
		var dir:File = current.resolvePath("tmp1");
		var file:File = dir.resolvePath("file.txt");
		
		file.writeString("hello");
		Assert.areEqual("hello", file.readString());
		
		try
		{
			dir.writeString("bad");
			Assert.fail("Expected FileException writing string to a directory");
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("Expected FileException but got " + e);
		}
	}
	
	@Test
	public function testReadString():Void
	{
		var dir:File = current.resolvePath("tmp1");
		var file:File = dir.resolvePath("file.txt");
		
		
		Assert.isNull(file.readString());
	
		try
		{
			dir.readString();
			Assert.fail("Expected FileException reading string to a directory");
		}
		catch(e:FileException)
		{
			Assert.isTrue(true);
		}
		catch(e:Dynamic)
		{
			Assert.fail("Expected FileException but got " + e);
		}
	}
	
	@Test
	public function TestGetDirectoryListing():Void
	{
		var dir:File = current.resolvePath("tmp1");
		var file:File = dir.resolvePath("file.txt");
		var subDir:File = dir.resolvePath("sub");
		
		var files:Array<File>;
		
		
	
		
		Assert.isTrue(dir.getDirectoryListing().length == 0);
		
		file.createFile("word");
		
		Assert.isTrue(dir.getDirectoryListing().length == 1);
		
		subDir.createDirectory();
		
		
		
		
		files = dir.getDirectoryListing();
		
		Assert.isNotNull(cast(files[0], File));
		
		Assert.isTrue(files.length == 2);
		
		dir.deleteDirectoryContents();
		
		Assert.isTrue(dir.getDirectoryListing().length == 0);
	
	}
	
	@Test
	public function TestGetDirectoryListingWithFilter():Void
	{
		var dir:File = current.resolvePath("tmp1", true);
		var file1:File = dir.resolvePath("file.txt", true);
		var file2:File = dir.resolvePath("file.aaa", true);
		var subDir1:File = dir.resolvePath("sub", true);
		var subDir2:File = dir.resolvePath("aaa", true);
		var reg:EReg = ~/\.aaa$/;
		
		var files:Array<File>;
		
		files = dir.getDirectoryListing();
		Assert.areEqual(4, files.length);
			
		
		files = 	dir.getDirectoryListing(reg);
		Assert.areEqual(1, files.length);
		
		files = 	dir.getDirectoryListing(reg, true);
		Assert.areEqual(3, files.length);
		
	
	}
	
	
	@Test
	public function TestGetRecursiveDirectoryListing():Void
	{
		
		var dir1:File = current.resolvePath("tmp1", true);

		dir1.resolvePath("file.txt", true);
		dir1.resolvePath("file.aaa", true);
		
		dir1.resolvePath("sub/sub.aaa", true);
		dir1.resolvePath("sub/sub.xyz", true);
		
		var reg:EReg = ~/\.aaa$/;

		//copying a directory
		
		
		var files:Array<File>;

		files = dir1.getRecursiveDirectoryListing();
		Assert.isTrue(files.length == 5);
	
		files = dir1.getRecursiveDirectoryListing(reg);
		Assert.isTrue(files.length == 2);

		files = dir1.getRecursiveDirectoryListing(reg, true);
		Assert.isTrue(files.length == 3);
		
		
		files = dir1.getRecursiveDirectoryListing(null, false, true);
		
		Assert.areEqual(files[2].nativePath,  dir1.resolvePath("sub").nativePath);
		
		files = dir1.getRecursiveDirectoryListing(null, false, false);
		Assert.areEqual(files[4].nativePath,  dir1.resolvePath("sub").nativePath);
		
		var reg:EReg = ~/tmp1\/file\.aaa$/;
		
		files = dir1.getRecursiveDirectoryListing(reg, false, false);
		
		Assert.isTrue(files.length == 0);
		
		files = dir1.getRecursiveDirectoryListing(reg, false, false, current);
		Assert.isTrue(files.length == 1);
	
	}
	
}