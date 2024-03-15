

# Simulation software

| Software | Required version |
| :------: | :--------------: |
| [SMASH](https://github.com/smash-transport/smash) | 3.1 or higher[^1] |
| [vHLLE](https://github.com/yukarpenko/vhlle) | - |
| [vHLLE parameters](https://github.com/yukarpenko/vhlle_params) | - |
| [Hadron sampler](https://github.com/smash-transport/smash-hadron-sampler) | 1.0 or higher |
| [Python](https://www.python.org) | 3.0  or higher |

[^1]: Version `3.1` is only needed for the afterburner functionality. Otherwise version `1.8` is sufficient.

Instructions on how to compile or install the software above can be found at the provided links either in the official documentation or in the corresponding README files.

!!! warning "Be consistent about dependencies"
    The above prerequisites have in general additional dependencies and it is important to be consistent in compiler options when compiling these and the software itself.
    We particularly highlight that the newer versions of ROOT require C++17 bindings or higher, which calls for proper treatment of compiler options in SMASH and the hadron sampler.
    It is also recommended to start from a clean build directory whenever changing the compiler or linking to external libraries that were compiled with different compiler flags.

---

# Unix system requirements

The hybrid handler makes use of many tools which are usually installed on Unix systems.
For some of them a minimum version is required and for the others their availability is enough.
However, in some cases, the GNU version is required and on some Linux distribution or on Apple machines the default installation might not be suitable.
To check out what is required and what is available on your system, simply run the `Hybrid-handler` executable without options: An overview of the main functionality as well as a system requirements overview will be produced.

!!! tip "Use `brew` to install needed GNU utilities on Apple machines"
    Often macOS is shipped with the BSD implementation of tools like `awk`, `sed`, `wc`, `sort` and many others.
    Since the GNU version of some tools offers more functionality, it has been decided in few cases to prefer these, especially since most supercomputers in the scientific field have such a version installed by default.
    However, on Apple machines, the [`brew` package manager](https://brew.sh) can be easily used to install the possibly missing utilities.

    Please, note that the needed commands must be available and automatically findable by your bash shell.
    For example, installing GNU AWK via `brew install gawk` is not enough as, by default, it only provides the `gawk` command and the hybrid handler needs `awk` instead.
    You then need to adjust the `PATH` environment variable as suggested by `brew` itself:
    ```bash
    export PATH="${HOMEBREW_PREFIX}/opt/gawk/libexec/gnubin:${PATH}"
    ```
    Unfortunately, there is no standard way to figure out which implementation a command offers.
    However, all GNU commands support the `--version` command line option and their output contains the `GNU` word.
    This allows to understand if the needed GNU version is available or if the commands refers to something else.
