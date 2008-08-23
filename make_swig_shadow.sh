#!/bin/bash

swig -c++ -python -shadow BlobResult.i
swig -c++ -python -shadow Blob.i
gcc -c -fPIC BlobResult.cpp BlobResult_wrap.cxx BlobExtraction.cpp Blob.cpp Blob_wrap.cxx -I/usr/include/python2.5 `pkg-config --cflags opencv`
ld -shared Blob.o Blob_wrap.o -o _Blob.so `pkg-config --libs opencv`
ld -shared BlobResult.o BlobResult_wrap.o BlobExtraction.o Blob.o -o _BlobResult.so `pkg-config --libs opencv`

