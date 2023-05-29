#!/bin/bash
set -ex

cpp -P -nostdinc -undef hello.ll build/hello.compiled.ll
pushd build/
llc hello.compiled.ll
gcc -no-pie -o hello hello.compiled.s
popd
./build/hello
