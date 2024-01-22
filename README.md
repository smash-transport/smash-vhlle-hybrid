# SMASH-vHLLE-Hybrid
Event-by-event hybrid model for the description of relativistic heavy-ion collisions in the low and high baryon-density regime.
This model constitutes a chain of different submodules to appropriately describe each phase of the collision with its corresponding degrees of freedom.
It consists of the following modules:
- SMASH hadronic transport approach to provide the initial conditions;
- vHLLE 3+1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball;
- CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE);
- Cooper-Frye sampler to perform particlization of the elements on the freezeout hypersurface;
- SMASH hadronic transport approach to perform the afterburner evolution.

If you are using the SMASH-vHLLE-hybrid, please cite [Eur.Phys.J.A 58(2022)11,230](https://arxiv.org/abs/2112.08724). You may also consult this reference for further details about the hybrid approach.

## Prerequisites

| Software | Required version |
| :------: | :--------------: |
| [CMake](https://cmake.org) | 3.15.4 or higher |
| [SMASH](https://github.com/smash-transport/smash) | 1.8 or higher |
| [vHLLE](https://github.com/yukarpenko/vhlle) | - |
| [vHLLE parameters](https://github.com/yukarpenko/vhlle_params) | - |
| [Hadron sampler](https://github.com/smash-transport/smash-hadron-sampler) | 1.0 or higher |
| [Python](https://www.python.org) | 2.7  or higher |
| [SMASH-analysis](https://github.com/smash-transport/smash-analysis)<sup>*</sup> | 1.7 or higher |

<sup><sup>*</sup> Needed if automatic generation of particle spectra is desired.</sup>

Instructions on how to compile or install the software above can be found at the provided links either in the official documentation or in the corresponding README files.

The newer versions of ROOT require C++17 bindings or higher, so please make sure to compile SMASH, ROOT, and the sampler with the same compiler utilizing the same compiler flags, which can be adjusted in CMakeLists.txt of each submodule.
It is also recommended to start from a clean build directory whenever changing the compiler or linking to external libraries that were compiled with different compiler flags.

### Unix system requirements

The hybrid-handler makes use of many tools which are usually installed on Unix systems.
For some of them a minimum version is required and for the others their availability is enough.
However, in some cases, the GNU version is required and on some Linux distribution or on Apple machines the default installation might not be suitable.
To check out what is required and what is available on your system, simply run the `Hybrid-handler` executable without options: An overview of the main functionality as well as a system requirements overview will be produced.

## The hybrid handler

To run any of the different stages of the model, the `Hybrid-handler` executable should be used.
Such an executable has different execution modes and each of these can be invoked with the `--help` option to get specific documentation of such a mode.
Run `./Hybrid-handler do --help` for an example.
Each run of the hybrid handler makes use of a configuration file and it is the user responsibility to provide one.
Few further customizations are possible using command line options, which are documented in the helper of each execution mode.

### The general behavior

The main `do` execution mode of the handler runs stages of the model and it will create a given output tree at the specified output directory (by default this is the folder from where the handler is run, but it can customized using the `-o` or `--output-directory` command line option).
Assuming all stages are run, this is what the user will obtain.
```
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

### The configuration file

Using YAML syntax it is possible to customize in many different ways which and how different stages of the model are run.
The file must be structured in sections (technically these are YAML maps at the top-level).
Apart from a generic one, a section corresponding to each stage of the model exists.
The presence of any section of this kind implies that the corresponding stage of the model should be run.
Many sanity checks are performed at start-up and in case you violate any rule, a descriptive self-explanatory error will be provided (e.g. the order of the stages matters, no stage can be repeated, and so on).
If you are new to YAML, be reassured, our YAML usage is definitely basic.
Each key has to be followed by a colon and each section content has to be indented in a consistent way.
In the following documentation you will find examples, too, and they are probably enough to understand how to create your configuration file.

#### The generic section

There is a generic section that contains general information which is not specific to one stage only.
This is called `Hybrid_handler` and it can contain the following key(s).

* `Run_ID`<br>
  This is the name used by the handler to create the folder for the actual run in the stage-dedicated directory.
  If this key is not specified, a default name containing the date and time of the run is used (`Run_YYYY-MM-DD_hhmmss`).

##### Example:

```yaml
Hybrid_handler:
    Run_ID: Cool_stuff_1
```

#### The software sections

Each stage of the model has a dedicated section.
These are (with the corresponding software to be used):
* `IC` for the initial conditions run (SMASH);
* `Hydro` for the viscous hydrodynamics stage (vHLLE);
* `Sampler` to perform particlization (Hadron sampler) and
* `Afterburner` for the last stage (SMASH).

As a general comment, whenever a path has to be specified, both an absolute and a relative one are accepted.
However, **it is strongly encouraged to exclusively use absolute paths** as relative ones should be specified w.r.t. different folders (most of the times relatively to the stage output directory).

#### Keys common to all software sections

* `Executable`<br>
  Path to the executable file of the software to be used.
  This key is **required** for all specified stages.
* `Config_file`<br>
  Path to the software specific configuration file.
  If not specified, the file shipped in the ***configs*** folder is used.
* `Software_keys`<br>
  The value of this key is a YAML map and should be used to change values of the software configuration file.
  It is not possible to add or remove keys, but only change already existing ones.
  If you need to add a key to the software default configuration file, you should create a custom one and specify it via the `Config_file` key.
  Depending on your needs, you could also create a more complete configuration file and change the values of some keys in your run(s) via this key.

#### The initial conditions section

There is no specific key of the `IC` section and only the generic ones can be used.

##### Example:

```yaml
IC:
    Executable: /path/to/smash
    Config_file: /path/to/IC_config.yaml
    Software_keys:
        General:
            End_Time: 100
```

#### The hydrodynamics section

* `Input_file`<br>
  The hydrodynamics simulation needs an additional input file which contains the system's initial conditions.
  This is the main output of the previous stage and, therefore, if not specified, a *SMASH_IC.dat* file is expected to exist in the ***IC*** output sub-folder with the same `Run_ID`.
  However, using this key, any file can be specified and used.

##### Example:

```yaml
Hydro:
    Executable: /path/to/vHLLE
    Config_file: /path/to/vHLLE_config
    Software_keys:
        etaS: 0.42
    Input_file: /path/to/IC_output.dat
```

#### The hadron sampler section

Also the hadron sampler needs in input the freezeout surface file, which is produced at the previous hydrodynamics stage.
However, there is no dedicated `Input_file` key in the hadron sampler section of the hybrid handler configuration file, because the hadron sampler must receive the path to this file in its own configuration file already.
Therefore, the user can set any path to the freezeout surface file by specifying it in the `Software_keys` subsection, as shown in the example below.

By default, if the user does not use a custom configuration file for the hadron sampler and does not specify the path to the freezeout surface file via `Software_keys`, the hybrid handler will use the configuration file for the hadron sampler which is contained in the ***configs*** folder and in which the path to the freezeout surface is set to `=DEFAULT=`.
This will be internally resolved by the hybrid handler to the path of a *freezeout.dat* file in the ***Hydro*** output sub-folder with the same `Run_ID`,  which is expected to exist.
A mechanism like this one is technically needed to be able by default to refer to the same run ID and pick up the correct file from the previous stage.
As a side-effect, it is not possible for the user to name the freezeout surface file as _=DEFAULT=_, which anyways would not probably be a very clever choice. :sweat_smile:

##### Example:

```yaml
Sampler:
    Executable: /path/to/Hadron-sampler
    Config_file: /path/to/Hadron-sampler_config
    Software_keys:
        surface: /path/to/custom/freezeout.dat
```

#### The afterburner section

* `Input_file`<br>
  As other stages, the afterburner run needs an additional input file as well, one which contains the sampled particles list.
  This is the main output of the previous sampler stage and, therefore, if not specified, a *particle_lists.oscar* file is expected to exist in the ***Sampler*** output sub-folder with the same `Run_ID`.
  However, using this key, any file can be specified and used.
* `Add_spectators_from_IC`<br>
  Whether spectators from the initial conditions stage should be included or not in the afterburner run can be decided via this boolean key.
  The default value is `false`.
* `Spectators_source`<br>
  If spectators from the initial conditions stage should be included in the afterburner run, a *SMASH_IC.oscar* file is expected to exist in the ***IC*** output sub-folder with the same `Run_ID`.
  However, using this key any file path can be specified.
  This key is ignored, unless `Add_spectators_from_IC` is not set to `true`.

##### Example:

```yaml
Afterburner:
    Executable: /path/to/smash
    Config_file: /path/to/Afterburner_config.yaml
    Software_keys:
        General:
            Delta_Time: 0.25
    Add_spectators_from_IC: true
    Spectators_source: /path/to/spectators-file.oscar
```

### An example of a complete hybrid handler configuration file

If you wish to run a simulation of the full model using the default behavior of all the stages of the hybrid handler, then the following configuration file can be used.

```yaml
IC:
    Executable: /path/to/smash

Hydro:
    Executable: /path/to/vHLLE

Sampler:
    Executable: /path/to/Hadron-sampler

Afterburner:
    Executable: /path/to/smash
```

Omitting some stages is fine, as long as the omitted one(s) are contiguous from the beginning or from the end.
If one or more stages are omitted at the beginning of the model, it is understood that these have been previously run, because the later stages will need input from the previous ones.
In such a case, it will be needed to either explicitly provide the needed input file for the first stage in the run or specify the same `Run_ID` of the simulations already done.
