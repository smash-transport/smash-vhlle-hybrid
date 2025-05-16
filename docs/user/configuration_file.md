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

    Note that, **if the `--id` command line option is used** when running the handler, **this key will be ignored**, the value specified on the command line will be used and a message printed to standard output.

```yaml title="Example"
Hybrid_handler:
    Run_ID: Cool_stuff_1
```

<i id="LHS-scan"></i>
???+ config-key "`LHS_scan`"

    This key can be provided only in `prepare-scan` execution mode and its presence enables the [Latin Hypercube Sampling](scans_syntax.md#latin-hypercube-sampling) algorithm to generate the combinations of parameters values.
    **Its value** refers to the number of desired samples and it **must be an integer larger than 1**.
    ```yaml title="Example"
    Hybrid_handler:
        LHS_scan: 10
    ```


## The software sections

Each stage of the model has a dedicated section.
These are (with the corresponding software to be used):

:cloud_tornado: &nbsp; `IC` for the initial conditions run (SMASH);

:droplet: &nbsp;  `Hydro` for the viscous hydrodynamics stage (vHLLE);

:seedling: &nbsp; `Sampler` to perform particlization (Hadron sampler) and

:fire: &nbsp; `Afterburner` for the last stage (SMASH).

As a general comment, whenever a path has to be specified, both an absolute and a relative one are accepted.
However, **it is strongly encouraged to exclusively use absolute paths** as relative ones should be specified w.r.t. different folders (most of the times relatively to the stage output directory).

!!! tip "You only need the handler configuration file!"
    Although each software needs a configuration file to be run, you generally do not need to create any.
    The handler uses a default one if none is explicitly provided.
    Keys in each software configuration files can be changed from the handler configuration file, without having to create specific configuration files for each software.
    Refer to the [:material-arrow-right-box: `Software_keys`](configuration_file.md#Software-keys) description for further information.

!!! info "Enforced sanity rules"
    Since the hybrid handler understands which software should be run from the presence of the corresponding section, there are a couple of totally natural rules that are enforced and will make the handler fail if violated.

    1. At least one software section must be present in the configuration file.
    2. Software sections must be specified in order and without gaps.
       This means that it is not possible to e.g. ask the handler to run the initial condition and the sampler stages.

## Keys common to all software sections

???+ config-key "`Executable`"

    Path to the executable file of the software to be used.
    This key is **required** for all specified stages.

<i id="Config-file"></i>
???+ config-key "`Config_file`"

    Path to the software specific configuration file.
    If not specified, the file shipped in the ***configs*** folder is used.

<i id="Software-keys"></i>
???+ config-key "`Software_keys`"

    The value of this key is a YAML map and should be used to change values of the software configuration file.
    It is not possible to add or remove keys, but only change already existing ones.
    If you need to add a key to the software default configuration file, you should create a custom one and specify it via the `Config_file` key.
    Depending on your needs, you could also create a more complete configuration file and change the values of some keys in your run(s) via this key.
    [:material-arrow-right-box: How is this achieved in practice?](FAQ/index.md#how-can-i-add-a-software-key-to-a-configuration-file)

<i id="scan-parameters"></i>
???+ config-key "`Scan_parameters`"

    **This key can only be specified in `prepare-scan` execution mode.**

    List of software input keys whose value is meant to be scanned.
    Each parameter has to be specified concatenating with a period all the keys as they would appear in the `Software_keys` map.
    For example, software keys which read
    ```yaml
    Software_keys:
      foo:
        bar: 42
        baz: 666
    ```
    would be specified in the `Scan_parameters` list as `"foo.bar"` and `"foo.baz"`.
    Such a list is a YAML array and therefore it can be specified both in the compact and extended form.

    === "Compact form"

        ```yaml
        Scan_parameters: ["foo.bar", "foo.baz"]
        ```

    === "Extended form"

        ```yaml
        Scan_parameters:
         - "foo.bar"
         - "foo.baz"
        ```

    ??? warning "Each parameter requires a scan specification"
        Parameters specified in the `Scan_parameters` list need to be accompanied by their scan values to be specified in the `Software_keys` section of the same stage [:material-arrow-right-box: the parameters scan syntax](scans_syntax.md).

## :cloud_tornado: &nbsp; The initial conditions section

There is no specific key of the `IC` section and only the generic ones can be used.

```yaml title="Example"
IC:
    Executable: /path/to/smash
    Config_file: /path/to/IC_config.yaml
    Software_keys:
        General:
            End_Time: 100
```

## :droplet: &nbsp; The hydrodynamics section

???+ config-key "`Input_file`"

    The hydrodynamics simulation needs an additional input file which contains the system's initial conditions.
    This is the main output of the previous stage and, therefore, if not specified, a :material-file: *SMASH_IC.dat* file is expected to exist in the :file_folder: ***IC*** output sub-folder with the same `Run_ID`.

    However, using this key, any file can be specified and used. If the key is a simple file name (without any '/'), the hybrid handler looks for this name in the corresponding :file_folder: ***IC*** output sub-folder, but if it is a specific path (containing '/'), that specific file will be used.

```yaml title="Example"
Hydro:
    Executable: /path/to/vHLLE
    Config_file: /path/to/vHLLE_config
    Software_keys:
        etaS: 0.42
    Input_file: /path/to/IC_output.dat
```

## :seedling: &nbsp; The hadron sampler section

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

For the hadron sampler section, there is the additional option to use an alternative sampling software, the FIST sampler. By default, the SMASH-hadron-sampler is used.
For using the FIST sampler, the additional input key `Module` has to be set to `FIST`.
This allows also two separate keys `Particle_file` and `Decay_file` to be set, which are the paths to the particle and decay list files respectively, which are shipped with Thermal-FIST.
Setting these keys is compulsory. Additionally, using the FIST sampler changes the names of several of the `Software_keys`. Please refer to the default config for the FIST sampler in :file_folder: ***configs***.

???+ config-key "`Module`"

    The hadron sampler software to be used.
    At the moment, only the `SMASH` or `FIST` values are accepted.

???+ config-key "`Particle_file`"

    Path to the particle list file, which is shipped with Thermal-FIST.
    This key is compulsory when `Module` is set to `FIST`.

???+ config-key "`Decays_file `"

    Path to the decay list file, which is shipped with Thermal-FIST.
    This key is compulsory when `Module` is set to `FIST`.

```yaml title="Example"
Sampler:
    Executable: /path/to/FIST-sampler
    Config_file: /path/to/FIST-sampler_config
    Module: FIST
    Particle_file: /path/to/list.dat
    Decays_file: /path/to/decays.dat
    Software_keys:
        hypersurface: /path/to/custom/freezeout.dat
```

## :fire: &nbsp; The afterburner section

???+ config-key "`Input_file`"

    As other stages, the afterburner run needs an additional input file as well, one which contains the sampled particles list.
    This is the main output of the previous sampler stage and, therefore, if not specified, a *particle_lists.oscar* file is expected to exist in the ***Sampler*** output sub-folder with the same `Run_ID`.

    However, using this key, any file can be specified and used. If the key is a simple file name (without any '/'), the hybrid handler looks for this name in the corresponding :file_folder: ***Sampler*** output sub-folder, but if it is a specific path (containing a '/'), that specific file will be used.

    Note that although it is possible to specify the input for the list modus in SMASH via the `Software_keys`, this is not allowed here and will result in an error.
    Always specify the customized input file for the afterburner stage using this key, if needed.

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

!!! warning "This is going to be costly!"
    Such a configuration file will execute all the modules in production mode, involving a fine hydrodynamic grid and a large statistic of sampled events.
    It is therefore better suited to be executed on a computer cluster.
    To test your setup locally, we suggest using the :material-file: *config_TEST.yaml* configuration file :material-arrow-right-box: [Predefined configuration files](predefined_configs.md).


??? question "What if I want to omit some stages?"

    Omitting some stages is fine, as long as the omitted one(s) are contiguous from the beginning or from the end.
    If one or more stages are omitted at the beginning of the model, it is understood that these have been previously run, because the later stages will need input from the previous ones.
    In such a case, it will be needed to either explicitly provide the needed input file for the first stage in the run or specify the same `Run_ID` of the simulations already done.
