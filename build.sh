#!/bin/bash
set -e
LLVM_BIN=~/chromium/src/third_party/llvm-build/Release+Asserts/bin
rm -Rf out
mkdir out
echo "#include <stdio.h>" > out/a.c
echo "void do_thing() { printf(\"Hello, world\\n\"); }" >> out/a.c
echo "void do_thing(); int main() { do_thing(); return 0; }" > out/main.c
$LLVM_BIN/clang  -flto=thin -O2 -c -o out/a.o out/a.c
pushd out
$LLVM_BIN/llvm-ar r a.a a.o
popd
$LLVM_BIN/clang  -flto=thin -O2 -c -o out/main.o out/main.c
$LLVM_BIN/clang  -flto=thin -fuse-ld=lld -O2 -Wl,-plugin-opt=thinlto-index-only=out/index.rsp -o out/wholething out/main.o out/a.a
$LLVM_BIN/clang  -flto=thin -fuse-ld=lld -O2 @out/index.rsp -o out/wholething out/main.o out/a.a

