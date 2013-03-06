#!/bin/bash
set -e

## clear bin directory
mkdir -p bin

## build tool
haxe build.hxml

## copy runner into src directory
cp mlib.n src/run.n

## run tests
bash test.sh

## package up and install over current version
neko mlib.n install


haxelib run mlib help

## submit to haxelib
#neko mlib.n submit