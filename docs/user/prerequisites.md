# Simulation software

!!! info "Be aware about the meaning of the version requirements"
    In the following we state a version requirement for the external software needed in the various phases.
    Strictly speaking, this is not a requirement for the hybrid handler, which most likely will correctly work even if different versions of the physics software are used.
    However, the hybrid handler makes use of some default configuration files for each software and this does rely on the version of the given software.
    Said differently, if you e.g. need to use older versions of some software, expect to have to specify a different base configuration for that given software [:material-arrow-right-box: configuration keys documentation](configuration_file.md#Config-file).

<div class="grid" markdown>
<div class="center-table" markdown>

| Physics Software | Suggested version |
| :--------------: | :---------------: |
| [SMASH](https://github.com/smash-transport/smash) | 3.1 or higher[^1] |
| [vHLLE](https://github.com/yukarpenko/vhlle) | Tag `vhlle-smash-hybrid-1` |
| [vHLLE parameters](https://github.com/yukarpenko/vhlle_params) | Tag `vhlle-smash-hybrid-1` |
| [Hadron sampler](https://github.com/smash-transport/smash-hadron-sampler) | Same as SMASH[^2] |

</div>
<div class="center-table" markdown>

| Other software | Required version |
| :------------: | :--------------: |
| [Python](https://www.python.org) | 3.2 or higher |

</div>
</div>

[^1]: Version `3.1` is only needed for the afterburner functionality. Otherwise version `1.8` is sufficient.
[^2]:
    As SMASH is a dependency of the hadron sampler codebase, different versions of the latter have to be compiled with corresponding given versions of SMASH.
    However, if you need to use a different version of the hadron sampler software, this is probably not making a difference from the Hybrid handler perspective and it is likely to work.

Instructions on how to compile or install the software above can be found at the provided links either in the official documentation or in the corresponding README files.

!!! warning "Be consistent about dependencies"
    The above prerequisites have in general additional dependencies and it is important to be consistent in compiler options when compiling these and the software itself.
    We particularly highlight that the newer versions of ROOT require C++17 bindings or higher, which calls for proper treatment of compiler options in SMASH and the hadron sampler.
    It is also recommended to start from a clean build directory whenever changing the compiler or linking to external libraries that were compiled with different compiler flags.

In principle, the Hybrid handler is agnostic to the physics model used in each state, and is built in a way to support different software with minimal efforts. So far, the following choices exist for different stages:

Sampler:
<div class="center-table" markdown>

| Supported Software | Required version |
| :------------: | :--------------: |
| [Hadron sampler](https://github.com/smash-transport/smash-hadron-sampler) | Same as SMASH[^2] |
| [FIST sampler](https://github.com/vlvovch/fist-sampler) | Commit af99229 and later |

</div>
---

## Unix system requirements

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

## Python requirements

!!! warning "You need the Python `packaging` module installed!"
    The handler uses Python itself to check Python requirements and it needs to use the `packaging` module to do so.
    Make sure to have it available before starting, otherwise the handler will produce a non-fatal error mentioning this aspect.

Few standalone Python scripts are used for dedicated tasks and this implies that the hybrid handler will terminate with an error if some of these requirements are missing.
However, since not all requirements are *always* needed, the hybrid handler will only check for some of them on a per-run basis.
In the system overview obtained by running the `Hybrid-handler` executable without options, also Python requirements are listed, each with a short description about when such a requirement is needed.

!!! question "I simply want to install all requirements. What should I do?"
    In the :file_folder: **python** folder, you'll find a :material-file: *requirements.txt* file which you can use to set up a dedicated Python [virtual environment](https://docs.python.org/3/tutorial/venv.html).
    Alternatively, although discouraged, you can simply run (from the repository top-level)
    ```
    pip install --user -r python/requirements.txt
    ```
    to install the requirements globally for your user.
