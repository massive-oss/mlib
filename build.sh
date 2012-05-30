#!/bin/bash

#build tool
cd tool
haxe build.hxml
cd ../

#neko mlib.n license

#update allClasses imports
neko mlib.n allClasses

#compile libraries
cd haxe
haxe build.hxml

cd ../neko
haxe build.hxml

cd ../

#run tests
bash test.sh

#package up and install over current version
neko mlib.n install

#neko mlib.n submit