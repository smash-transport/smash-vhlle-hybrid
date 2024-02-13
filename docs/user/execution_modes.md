# The hybrid handler

Every operation can be done simply by running the :simple-gnubash: `Hybrid-handler` executable.
This has different execution modes and most of them can be invoked with the `--help` option to get specific documentation of such a mode.

``` title="Example about getting help for a given mode"
./Hybrid-handler do --help
```

Each run of the hybrid handler (apart from auxiliary execution modes) makes use of a configuration file and it is the user responsibility to provide one.
Few further customizations are possible using command line options, which are documented in the helper of each execution mode.

!!! tip "A :fontawesome-brands-square-git: inspired user interface"
    If you are used to [:simple-git: Git](https://git-scm.com), you will immediately recognize the analogy.
    This has been implemented on purpose.
    Different tasks can be achieved using different execution modes which are analogous to Git commands.

## Auxiliary execution modes

=== "Getting help"

    ```
    ./Hybrid-handler help
    ```
    The `help` execution mode is the default one.
    Therefore, if the :simple-gnubash: `Hybrid-handler` executable is run without any command line option, an overview of its features is given.
    This is equivalent to run it with the `--help` command line option.
    To be more user friendly, any additional command line option provided in `help` mode is ignored (even if wrong), and the help message is given.

=== "Obtaining the software version"

    ```
    ./Hybrid-handler version
    ```
    The hybrid handler can be asked to print its version.
    This might be particularly useful to store the handler version as metadata for reproducibility reasons.
    As many Unix OS tools support a `--version` command line option, an alias for this mode has been added and the hybrid handler can be run with the `--version` command line option, too.

    ??? question "Why do I just get a warning when asking the version?"
        If for some reason you are not on tagged version of the codebase (e.g. you checked out a different commit), then you will be warned by the hybrid handler that you are not using an official release.
        This is meant to raise awareness, as it is encouraged to use stable versions only, especially for physics projects.


## The `do` execution mode

The main `do` execution mode runs stages of the model and creates a given output tree at the specified output directory (by default this is a subdirectory of the folder from where the handler is run named :file_folder: ***data***, but it can customized using the `--output-directory` command line option).

Assuming all stages are run, this is the folder tree that the user will obtain.

``` { .bash .no-copy }
📂 Output-directory
│
├─ 📂 IC
│   └─── 📂 Run_ID
│          └─ # output files
│
├─ 📂 Hydro
│   └─── 📂 Run_ID
│          └─ # output files
│
├─ 📂 Sampler
│   └─── 📂 Run_ID
│          └─ # output files
│
└─ 📂 Afterburner
    └─── 📂 Run_ID
           └─ # output files
```

This might differ depending on how the used [handler configuration file](configuration_file.md) has been set up.

## The `prepare-scan` execution mode

This is a different mode, which per se won't run any simulation.
Instead, the hybrid handler will prepare future runs by creating configuration files in a sub-folder of the output folder.
The user can use the `--scan-name` command line option to provide a label to the scan, which will name the output sub-folder and will be used as filename prefix.
For example, using the default generic `scan` name, the user will obtain the following tree folder.
```  { .bash .no-copy }
📂 Output-directory
└─ 📂 scan
    ├─── 🗒️ scan_combinations.dat
    ├─── 🗒️ scan_run_1.yaml
    ├─── 🗒️ scan_run_2.yaml
    └─── 🗒️ ...
```

<div class="grid cards" markdown>

- :material-hammer-wrench: The scan parameters must be properly defined in the hybrid handler configuration file using [a dedicated syntax](scans_syntax.md).

- :material-graph: How the parameters combinations are made is described in the documentation of the different [types of scans](scans_types.md).

</div>

!!! note "Some useful remarks"
    The :material-file: *`scan_combinations.dat`* file will contain a list of all parameters combinations in a easily parsable table.

    The :material-file: *`scan_run_*.yaml`* files are configuration files for the hybrid handler to run physics simulations.
    For reproducibility reasons as well as to keep track that they belong to a scan, the scan name and parameters are printed in the beginning in commented lines.
    These files will have leading zeroes in the run index contained in the filename, depending on the total number of prepared simulations.
    This allows to keep them easily sorted.
