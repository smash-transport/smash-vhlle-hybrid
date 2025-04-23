# Frequently asked questions

### How can I add a software key to a configuration file?

Using the hybrid handler, many different programs are run and each of them needs a configuration file.
The hybrid handler also needs a configuration file and having many of these might lead to some confusion.

All the configuration files of the separate software for each state _can_ be specified by the user, but *do not have to*.
The hybrid handler is using default ones, which are shipped in the :file_folder: **configs** folder.
You can have a look to these files to see which keys are used there.

Since using the `Software_keys` key in the hybrid handler configuration file it is only possible to **change** the value of an existing input key in the software configuration file, it would result in an error to attempt to add a missing one.
Analogously, there is no mechanism to remove keys from the default base software configuration file used by the handler.

Let's see in a concrete example how to proceed if different keys are needed.
Assume we want to run the :fire: afterburner stage asking SMASH not to use the grid for interaction lookup (this might be of course any other key).
The following setup would not work, as the `Use_Grid` key in the `General` section is not provided in the default base configuration file for the afterburner.

=== "Hybrid-handler configuration file"
    ``` {.yaml .annotate}
    Afterburner:
        Executable: "/path/to/smash"
        Software_keys:
            General:
                End_Time: 500
                Nevents: 200
                Use_Grid: False # (1)!
    ```

    1. :warning: This triggers an error as it is missing in the afterburner base configuration file!

=== ":fire: SMASH Afterburner base configuration file"
    ```yaml
    Logging:
        default: INFO

    General:
        Modus:         List
        Time_Step_Mode: None
        Delta_Time:    0.1
        End_Time:      10000.0
        Randomseed:    -1
        Nevents:       1000

    Collision_Term:
        Strings: True
        String_Parameters:
            Use_Monash_Tune: False

    Output:
        Particles:
            Format:          ["Oscar2013"]

    Modi:
        List:
            File_Directory: "."
            Filename: "sampled_particles_list.oscar"
    ```

The correct way to fix the problem is to create a new SMASH afterburner configuration file, having all the keys that need to be modified and then modify them from the hybrid handler configuration file **after having specified that a custom configuration file should be used for the afterburner stage**.

=== "Hybrid-handler configuration file"
    ``` {.yaml .annotate}
    Afterburner:
        Executable: "/path/to/smash"
        Config_file: "/path/to/my/base-config.yaml"
        Software_keys:
            General:
                End_Time: 500
                Nevents: 200
                Use_Grid: False # (1)!
    ```

    1. :white_check_mark: Now this is working, as the key exists in the base configuration file.

=== ":fire: My own SMASH Afterburner base configuration file"
    ```yaml
    Logging:
        default: INFO

    General:
        Modus:         List
        Time_Step_Mode: None
        Delta_Time:    0.1
        End_Time:      10000.0
        Randomseed:    -1
        Nevents:       1000
        Use_Grid:      True

    # [...] <- SAME AS BEFORE!
    ```


!!! tip "A possible way to go in real life"
    <div class="grid" markdown>

    In complex projects it might be handy to prepare base configuration files for the needed stages in the beginning.
    A good idea might be to keep them close to the data in a known, dedicated folder.
    This ensures reproducibility at any point during the project and can be seen as a good data management practice.
    Of course, you will need to point to your custom base configuration files from within the hybrid handler configuration file in the different stages blocks.

    ``` { .bash .no-copy }
    📂 Project-directory
    │
    ├─ 📂 Custom_base_configuration_files
    │   ├─── 🗒️ smash_IC.yaml
    │   ├─── 🗒️ vhlle.txt
    │   └─── ...
    ├─ 📂 IC
    │   └─── ...
    ├─ 📂 Hydro
    │   └─── ...
    └─── ...
    ```

    </div>

!!! danger "Do not edit the shipped base configuration file!"
    Although this might be a quick way to try out something, you should never prefer to change the base configuration files in the hybrid handler repository.
    Your changes might get in conflict with future releases of the software or simply be undone by accident using Git inside the repository.

### Can I collide particles other than nuclei in the IC stage?

You might have tried to use SMASH as initial-conditions software specifying a pion as the projectile via the following configuration file, but this was not accepted by the hybrid handler.

``` {.yaml .annotate title="Hybrid-handler configuration file"}
IC:
    Executable: "/path/to/smash"
    Software_keys:
        Modi:
            Collider:
                Projectile:
                    Particles: {211: 1} # (1)!
```

 1. :warning: This triggers an error as `Particles` is a YAML map and it contains a sub-map.
    Since `211` is a map key, which is not present in the base configuration file, this line triggers an error.

The SMASH :cloud_tornado: `IC` base configuration file is set up to collide nuclei and, therefore, both the projectile and the target are made of protons and neutrons.
These are specified **using PDG codes as YAML map keys** in the configuration file.
Any attempt to use different particles is a try to use a new key in the configuration file, namely one not present in the base configuration file!
If you need to collide particles other than protons and nucleons, you need your own base configuration file.
Check out [this other question](#how-can-i-add-a-software-key-to-a-configuration-file) for detailed instructions.


### How can I repeat the same run in parallel to increase statistics?

The output folder in `do` mode is built by the hybrid handler in a way such that runs with different IDs do not interfere.
Therefore, the same run can be repeated as many times as desired, on constraint that the user specifies a different run ID for each run.
By default, the run ID contain a time stamp and, therefore, waiting at least one second before starting different instances of the same run and using the default run ID should achieve what desired.

The run ID can also be specified on the on the command line via the `--id` option.
This can be exploited to easily start the same run several times with different run IDs and naming these as desired, without necessarily relying on the default timestamp.

=== "Using the default run ID"
    ``` {.bash .annotate}
    cd Project_folder
    for ((index = 0; index < ${SLURM_CPUS_ON_NODE}; index++ )); do # (1)!
        Hybrid_handler do -c experiment.yaml &
        sleep 1
    done
    wait
    ```

    1.  The `SLURM_CPUS_ON_NODE` variable is peculiar to [slurm scheduler](https://slurm.schedmd.com/sbatch.html).
        This `for` loop should submit as many runs as the number of CPUs requested by the job.
        Clearly, it is only a proof of concept and adjustment might be needed.

=== "Specifying the run ID"
    ```bash
    cd Project_folder
    for ((index = 0; index < ${SLURM_CPUS_ON_NODE}; index++ )); do
        Hybrid_handler do \
            -c experiment.yaml \
            --id "Run_$(printf "%0d" ${index})" &
    done
    wait
    ```
