# The hybrid handler

To run any of the different stages of the model, the :simple-gnubash: `Hybrid-handler` executable should be used.
Such an executable has different execution modes and each of these can be invoked with the `--help` option to get specific documentation of such a mode.

``` title="Example about getting help for a given mode"
./Hybrid-handler do --help
```

If the executable is run without any execution mode (or simply with `--help`), an overview of its features is given.

Each run of the hybrid handler makes use of a configuration file and it is the user responsibility to provide one.
Few further customizations are possible using command line options, which are documented in the helper of each execution mode.

## The general behavior

The main `do` execution mode of the handler runs stages of the model and it will create a given output tree at the specified output directory (by default this is the folder from where the handler is run, but it can customized using the `-o` or `--output-directory` command line option).
Assuming all stages are run, this is what the user will obtain.
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
