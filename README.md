ArrayFire CMake Project Example
=====

This is a base project which demonstrates how to properly configure CMake
to build a project that links with the [ArrayFire](http://arrayfire.com)
high performance parallel computing library. The CMake configuration files
in this directory will automatically find ArrayFire and build CPU, CUDA, and
OpenCL backends if support for all three backends is present on your machine.

## Prerequisites:
* A C++11 compiler, like gcc or clang
* [CMake](http://www.cmake.org) 3.0.0 or newer
* ArrayFire 3.0.1 or newer via. [pre-built binaries](http://arrayfire.com/download) or
  [source](https://github.com/arrayfire/arrayfire)

## Building this project

To build this project simply:

```
git clone https://github.com/bkloppenborg/arrayfire-cmake-example.git
cd arrayfire-cmake-example/build
cmake ..
make
```

NOTE: If you have installed ArrayFire to a non-standard location, you will
need to specify the full pat to the `share/ArrayFire/cmake` directory. For
example, if you have installed ArrayFire to `/opt`, then the `cmake` command
above will be replaced with:

```
cmake -DArrayFire_DIR=/opt/share/ArrayFire/cmake ..
```


