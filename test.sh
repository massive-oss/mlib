#!/bin/bash
set -e

cd test/haxe
haxelib run munit test -coverage

cd ../sys
haxelib run munit test -coverage

cd ../../