#!/bin/bash
set -e

cd haxe
haxelib run munit test -coverage
cd ../neko
haxelib run munit test -neko -coverage