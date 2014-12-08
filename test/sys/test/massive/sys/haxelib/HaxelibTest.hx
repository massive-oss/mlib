package massive.sys.haxelib;

import haxe.Json;
import massive.sys.io.FileSys;
import massive.sys.haxelib.Haxelib;
import massive.munit.util.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

import massive.sys.cmd.Console;
import massive.sys.io.File;
import massive.sys.io.FileException;

#if haxe3
import haxe.ds.StringMap;
#else
private typedef StringMap<T> = Hash<T>;
#end

class HaxelibTest
{
    var _instance:Haxelib;

    public function new() {}

    @Before
    public function setup():Void
    {
        _instance = new Haxelib();
    }

    @After
    public function tearDown():Void
    {
        _instance = null;
    }

    @Test
    public function testTestJsonExists():Void
    {
        var path:String = FileSys.getCwd();

        Assert.isTrue(FileSys.exists(path));
    }

    @Test
    public function testParseFromJsonShouldParseName():Void
    {
        var expected:String = "mlib";
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.name);
    }

    @Test
    public function testParseFromJsonShouldParseUrl():Void
    {
        var expected:String = "http://github.com/massiveinteractive/MassiveUnit";
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.url);
    }

    @Test
    public function testParseFromJsonShouldParseLicense():Void
    {
        var expected:String = "MIT";
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.license);
    }

    @Test
    public function testParseFromJsonShouldParseDescription():Void
    {
        var expected:String = "A cross platform unit testing framework for Haxe with metadata test markup and tools for generating, compiling and running tests from the command line.";
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.description);
    }

    @Test
    public function testParseFromJsonShouldParseVersionWithoutBuildNumber():Void
    {
        var expected:String = "1.2.3";
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.version);
    }

    @Test
    public function testParseFromJsonShouldParseVersionWithBuildNumber():Void
    {
        var expected:String = "1.2.3.4";
        var testJson:String = createTestJsonWithBuildNumber();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.version);
    }

    @Test
    public function testIncrementVersionShouldUpdateMajorForThreeNumbers():Void
    {
        var expected:String = "2.0.0";
        var testJson:String = createTestJson();
        _instance.parseFromJson(testJson);

        _instance.incrementVersion(Haxelib.MAJOR);

        Assert.areEqual(expected, _instance.version);
    }

    @Test
    public function testIncrementVersionShouldUpdateMinorForThreeNumbers():Void
    {
        var expected:String = "1.3.0";
        var testJson:String = createTestJson();
        _instance.parseFromJson(testJson);

        _instance.incrementVersion(Haxelib.MINOR);

        Assert.areEqual(expected, _instance.version);
    }

    @Test
    public function testIncrementVersionShouldUpdatePatchForThreeNumbers():Void
    {
        var expected:String = "1.2.4";
        var testJson:String = createTestJson();
        _instance.parseFromJson(testJson);

        _instance.incrementVersion(Haxelib.PATCH);

        Assert.areEqual(expected, _instance.version);
    }

    @Test
    public function testIncrementVersionShouldUpdateBuildForThreeNumbers():Void
    {
        var expected:String = "1.2.3.1";
        var testJson:String = createTestJson();
        _instance.parseFromJson(testJson);

        _instance.incrementVersion(Haxelib.BUILD);

        Assert.areEqual(expected, _instance.version);
    }

    @Test
    public function testParseFromJsonShouldParseReleasenote():Void
    {
        var expected:String = "Add haxelib.json ready to release to new haxelib.";
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.versionDescription);
    }

    @Test
    public function testParseFromJsonShouldParseTags():Void
    {
        var expected:Int = 4;
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.tags.length);
        Assert.isTrue(_instance.tags.indexOf("cross") >= 0);
        Assert.isTrue(_instance.tags.indexOf("utility") >= 0);
        Assert.isTrue(_instance.tags.indexOf("tools") >= 0);
        Assert.isTrue(_instance.tags.indexOf("massive") >= 0);
    }

    @Test
    public function testParseFromJsonShouldParseContributors():Void
    {
        var expected:Int = 1;
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, _instance.contributors.length);
        Assert.isTrue(_instance.contributors.indexOf("massive") >= 0);
    }

    @Test
    public function testParseFromJsonShouldParseDependencies():Void
    {
        var expected:Int = 2;
        var testJson:String = createTestJson();

        _instance.parseFromJson(testJson);

        Assert.areEqual(expected, countMap(_instance.dependencies));
        Assert.isTrue(_instance.dependencies.exists("foo"));
        Assert.areEqual("1.2.3", _instance.dependencies.get("foo"));
        Assert.isTrue(_instance.dependencies.exists("bar"));
        Assert.areEqual("", _instance.dependencies.get("bar"));
    }

    private function countMap(map:StringMap<String>):Int {
        var i:Int = 0;
        for (o in map) {
            i++;
        }
        return i;
    }

    private function createTestJson():String {
        return '{
            "name": "mlib",
            "url": "http://github.com/massiveinteractive/MassiveUnit",
            "license": "MIT",
            "description": "A cross platform unit testing framework for Haxe with metadata test markup and tools for generating, compiling and running tests from the command line.",
            "version": "1.2.3",
            "releasenote": "Add haxelib.json ready to release to new haxelib.",
            "tags": ["cross","utility","tools","massive"],
            "contributors": ["massive"],
            "dependencies":
            {
                "foo":"1.2.3",
                "bar":""
            }
        }';
    }

    private function createTestJsonWithBuildNumber():String {
        return '{
            "name": "mlib",
            "url": "http://github.com/massiveinteractive/MassiveUnit",
            "license": "MIT",
            "description": "A cross platform unit testing framework for Haxe with metadata test markup and tools for generating, compiling and running tests from the command line.",
            "version": "1.2.3.4",
            "releasenote": "Add haxelib.json ready to release to new haxelib.",
            "tags": ["cross","utility","tools","massive"],
            "contributors": ["massive"],
            "dependencies":
            {
                "foo":"1.2.3",
                "bar":""
            }
        }';
    }
}
