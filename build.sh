#!/bin/bash
set -e

## set dev mode
haxelib dev mlib src

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

## unset dev mode
haxelib dev mlib

## package up and install over current version
cp src/run.n mlib.n
neko mlib.n install


haxelib run mlib help

## submit to haxelib
#neko mlib.n submit