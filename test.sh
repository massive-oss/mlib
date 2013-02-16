#!/bin/bash
set -e

cd haxe
haxelib run munit test -coverage
cd ../sys
haxelib run munit test -neko -coverage