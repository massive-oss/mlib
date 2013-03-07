#!/bin/bash
set -e

## clear bin directory
mkdir -p bin

## build tool
haxe build.hxml

## run tests
cd test/haxe
haxelib run munit test -coverage

cd ../sys
haxelib run munit test -coverage

cd ../../

## package up and install over current version
neko mlib.n install


haxelib run mlib help

## submit to haxelib
#neko mlib.n submit