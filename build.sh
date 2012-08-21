#!/bin/bash
set -e

mkdir -p bin

#build tool
echo ' build tool src'
cd tool
haxe build.hxml
cd ../

#neko mlib.n license

#update allClasses imports
neko mlib.n allClasses

#compile libraries
echo ' build haxe src'
cd haxe
haxe build.hxml

echo ' build neko src'
cd ../neko
haxe build.hxml

cd ../

#run tests
bash test.sh

#package up and install over current version
neko mlib.n install

#neko mlib.n submit