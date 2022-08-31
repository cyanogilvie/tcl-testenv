# Ubuntu Tcl Test Enviroments

These images are based on the official Ubuntu images, with Tcl and some Tcl extensions built from source with build options appropriate for different development and testing use cases: very optimized for benchmarking, debugging symbols and purify for gdb and leak and memory error checking with valgrind.

## Variants
- -optimized: Intended for benchmarks: -O3, haswell level hardware, link time optimization, profile guided optimization
- -debug: Intended for debugging with gdb / valgrind: -Og, purify, debugging build

## Version Numbers
The version numbers of this image are a combination of the Ubuntu version, the Tcl version and a build of this image, separated by dashes.

## Source
The source code for the images is: https://github.com/cyanogilvie/tcl-testenv

## Docker Image Repository
The images are hosted on Docker hub, as cyanogilvie/ubuntu-tcl:tagname

The tagname is the version, like "22.04-8.7a4-1" with a suffix indicating the variant (see Variants above).

## Included Tcl Packages
- Thread
- Parse_args
- Rl_json
- tcllib
