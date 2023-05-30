#!/bin/bash
set -ex

cpp -P -nostdinc -undef $1.ll build/$1.compiled.ll
pushd build/
llc $1.compiled.ll
gcc -no-pie -o $1 $1.compiled.s
popd
./build/$1
