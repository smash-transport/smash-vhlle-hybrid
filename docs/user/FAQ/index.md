# Frequently asked questions

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
    {.annotate}

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
