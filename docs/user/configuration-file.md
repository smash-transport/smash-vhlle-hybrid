# The configuration file

Using YAML syntax it is possible to customize in many different ways which and how different stages of the model are run.
The file must be structured in sections (technically these are YAML maps at the top-level).
Apart from a generic one, a section corresponding to each stage of the model exists.
The presence of any section of this kind implies that the corresponding stage of the model should be run.
Many sanity checks are performed at start-up and in case you violate any rule, a descriptive self-explanatory error will be provided (e.g. the order of the stages matters, no stage can be repeated, and so on).
If you are new to YAML, be reassured, our YAML usage is definitely basic.
Each key has to be followed by a colon and each section content has to be indented in a consistent way.
In the following documentation you will find examples, too, and they are probably enough to understand how to create your configuration file.

## The generic section

There is a generic section that contains general information which is not specific to one stage only.
This is called `Hybrid_handler` and it can contain the following key(s).

???+ config-key "`Run_ID`"

    This is the name used by the handler to create the folder for the actual run in the stage-dedicated directory.
    If this key is not specified, a default name containing the date and time of the run is used (`Run_YYYY-MM-DD_hhmmss`).

```yaml title="Example"
Hybrid_handler:
    Run_ID: Cool_stuff_1
```

## The software sections

Each stage of the model has a dedicated section.
These are (with the corresponding software to be used):

* `IC` for the initial conditions run (SMASH);
* `Hydro` for the viscous hydrodynamics stage (vHLLE);
* `Sampler` to perform particlization (Hadron sampler) and
* `Afterburner` for the last stage (SMASH).

As a general comment, whenever a path has to be specified, both an absolute and a relative one are accepted.
However, **it is strongly encouraged to exclusively use absolute paths** as relative ones should be specified w.r.t. different folders (most of the times relatively to the stage output directory).

## Keys common to all software sections

???+ config-key "`Executable`"

    Path to the executable file of the software to be used.
    This key is **required** for all specified stages.

???+ config-key "`Config_file`"

    Path to the software specific configuration file.
    If not specified, the file shipped in the ***configs*** folder is used.

???+ config-key "`Software_keys`"

    The value of this key is a YAML map and should be used to change values of the software configuration file.
    It is not possible to add or remove keys, but only change already existing ones.
    If you need to add a key to the software default configuration file, you should create a custom one and specify it via the `Config_file` key.
    Depending on your needs, you could also create a more complete configuration file and change the values of some keys in your run(s) via this key.

## The initial conditions section

There is no specific key of the `IC` section and only the generic ones can be used.

```yaml title="Example"
IC:
    Executable: /path/to/smash
    Config_file: /path/to/IC_config.yaml
    Software_keys:
        General:
            End_Time: 100
```

## The hydrodynamics section

???+ config-key "`Input_file`"

    The hydrodynamics simulation needs an additional input file which contains the system's initial conditions.
    This is the main output of the previous stage and, therefore, if not specified, a :material-file: *SMASH_IC.dat* file is expected to exist in the :file_folder: ***IC*** output sub-folder with the same `Run_ID`.
    However, using this key, any file can be specified and used.

```yaml title="Example"
Hydro:
    Executable: /path/to/vHLLE
    Config_file: /path/to/vHLLE_config
    Software_keys:
        etaS: 0.42
    Input_file: /path/to/IC_output.dat
```

## The hadron sampler section

Also the hadron sampler needs in input the freezeout surface file, which is produced at the previous hydrodynamics stage.
However, there is no dedicated `Input_file` key in the hadron sampler section of the hybrid handler configuration file, because the hadron sampler must receive the path to this file in its own configuration file already.
Therefore, the user can set any path to the freezeout surface file by specifying it in the `Software_keys` subsection, as shown in the example below.

By default, if the user does not use a custom configuration file for the hadron sampler and does not specify the path to the freezeout surface file via `Software_keys`, the hybrid handler will use the configuration file for the hadron sampler which is contained in the :file_folder: ***configs*** folder and in which the path to the freezeout surface is set to `=DEFAULT=`.
This will be internally resolved by the hybrid handler to the path of a :material-file: *freezeout.dat* file in the :file_folder: ***Hydro*** output sub-folder with the same `Run_ID`,  which is expected to exist.
A mechanism like this one is technically needed to be able by default to refer to the same run ID and pick up the correct file from the previous stage.
As a side-effect, it is not possible for the user to name the freezeout surface file as `=DEFAULT=`, which anyways would not probably be a very clever choice. :sweat_smile:

```yaml title="Example"
Sampler:
    Executable: /path/to/Hadron-sampler
    Config_file: /path/to/Hadron-sampler_config
    Software_keys:
        surface: /path/to/custom/freezeout.dat
```

## The afterburner section

???+ config-key "`Input_file`"

    As other stages, the afterburner run needs an additional input file as well, one which contains the sampled particles list.
    This is the main output of the previous sampler stage and, therefore, if not specified, a *particle_lists.oscar* file is expected to exist in the ***Sampler*** output sub-folder with the same `Run_ID`.
    However, using this key, any file can be specified and used.

???+ config-key "`Add_spectators_from_IC`"

    Whether spectators from the initial conditions stage should be included or not in the afterburner run can be decided via this boolean key.
    The default value is `true`.

???+ config-key "`Spectators_source`"

    If spectators from the initial conditions stage should be included in the afterburner run, a :material-file: *SMASH_IC.oscar* file is expected to exist in the :file_folder: ***IC*** output sub-folder with the same `Run_ID`.
    However, using this key any file path can be specified.
    This key is ignored if `Add_spectators_from_IC` is set to `false`.

```yaml title="Example"
Afterburner:
    Executable: /path/to/smash
    Config_file: /path/to/Afterburner_config.yaml
    Software_keys:
        General:
            Delta_Time: 0.25
    Add_spectators_from_IC: true
    Spectators_source: /path/to/spectators-file.oscar
```

## An example of a complete hybrid handler configuration file

If you wish to run a simulation of the full model using the default behavior of all the stages of the hybrid handler, then the following configuration file can be used.

```yaml title="Example"
IC:
    Executable: /path/to/smash

Hydro:
    Executable: /path/to/vHLLE

Sampler:
    Executable: /path/to/Hadron-sampler

Afterburner:
    Executable: /path/to/smash
```
**Note:** Such a configuration file will execute all the modules in production mode, involving a fine hydrodynamic grid and a large statistic of sampled events. 
It is therefore better suited to be executed at a computer cluster. To test your set-up locally, we suggest using config_TEST.yaml, for more read the section [Predefined configuration files](predef-configs.md).


??? question "What if I want to omit some stages?"

    Omitting some stages is fine, as long as the omitted one(s) are contiguous from the beginning or from the end.
    If one or more stages are omitted at the beginning of the model, it is understood that these have been previously run, because the later stages will need input from the previous ones.
    In such a case, it will be needed to either explicitly provide the needed input file for the first stage in the run or specify the same `Run_ID` of the simulations already done.
