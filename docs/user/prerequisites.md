

# Simulation software

| Software | Required version |
| :------: | :--------------: |
| [SMASH](https://github.com/smash-transport/smash) | 1.8 or higher |
| [vHLLE](https://github.com/yukarpenko/vhlle) | - |
| [vHLLE parameters](https://github.com/yukarpenko/vhlle_params) | - |
| [Hadron sampler](https://github.com/smash-transport/smash-hadron-sampler) | 1.0 or higher |
| [Python](https://www.python.org) | 3.0  or higher |

Instructions on how to compile or install the software above can be found at the provided links either in the official documentation or in the corresponding README files.

!!! warning "Be consistent w.r.t dependencies"
    The above prerequisites have in general additional dependencies and it is important to be consistent in compiler options when compiling these and the software itself.
    We particularly highlight that the newer versions of ROOT require C++17 bindings or higher, which calls for proper treatment of compiler options in SMASH and the hadron sampler.
    It is also recommended to start from a clean build directory whenever changing the compiler or linking to external libraries that were compiled with different compiler flags.

# Unix system requirements

The hybrid handler makes use of many tools which are usually installed on Unix systems.
For some of them a minimum version is required and for the others their availability is enough.
However, in some cases, the GNU version is required and on some Linux distribution or on Apple machines the default installation might not be suitable.
To check out what is required and what is available on your system, simply run the `Hybrid-handler` executable without options: An overview of the main functionality as well as a system requirements overview will be produced.
