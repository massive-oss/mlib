#!/bin/bash
cd haxe
haxelib run munit test -browser FireFox
cd ../neko
haxelib run munit test -neko -browser FireFox
cd ../