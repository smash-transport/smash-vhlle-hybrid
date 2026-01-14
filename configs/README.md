## Folder structure

### Base configuration files

In this folder the base configuration files used by the Hybrid-handler are collected.
For some software, the handler takes care to support different versions and, in order to do so, the following convention is used.
A suffix `__v` is used followed by a version number.
Such version means that this file is compatible with all software versions greater or equal to it, unless another base configuration file with a larger version exists.
Said differently, given a software version, the file with the first version smaller or equal to it should be used.

### The predefined configuration files

In the :file_folder: ***predef_configs*** subdirectory all Hybrid-handler configurations to run some realistic simulations are collected.
There an example run using the dynamic fluidization can be found in the ***dynamic_fluidization*** dedicated folder.
