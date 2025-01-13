# Adding a new module

Although the SMASH-vHLLE-hybrid, as implied in the name, was built with a defined set of software modules, it is designed to be easily extensible with new modules. 
This allows, amongst other things, to test new algorithms and study model dependency.

!!! tip "Take inspiration from the existing modules"
    The first alternative module to be implemented was the FIST sampler, which shares many similarities with the SMASH sampler.
    The implementation of the FIST sampler can be used as a reference for the implementation of new modules.

Adding a new module to the SMASH-vHLLE-hybrid is a straightforward process. 
The following steps serve as a guidance and will probably be needed. Let's assume we want to add `MUSIC` as an alternative for the hydrodynamic stage:

* In case the stage has no other modules, add a field to the `HYBRID_module` array in the :material-file:`global_variables.bash` script for the respective stage (here `Hydro`). 

``` {.bash .no-copy title=global_variables.bash}
 declare -gA HYBRID_module=(
        [Sampler]="${HYBRID_default_sampler_module}"
        [Hydro]="${HYBRID_default_hydro_module}"
    )
```
At the same place, add alternative base config files for the stages named `${STAGE_NAME}_${MODULE_NAME}` and add `[Module]` to the valid keys of the stage.
``` {.bash .no-copy title=global_variables.bash}
    declare -rgA HYBRID_hydro_valid_keys=(
        [Executable]='HYBRID_software_executable[Hydro]'
        [Config_file]='HYBRID_software_base_config_file[Hydro]'
        [Input_file]='HYBRID_software_user_custom_input_file[Hydro]'
        [Module]='HYBRID_module[Hydro]'
        [Scan_parameters]='HYBRID_scan_parameters[Hydro]'
        [Software_keys]='HYBRID_software_new_input_keys[Hydro]'
    )

        declare -gA HYBRID_software_base_config_file=(
        [IC]="${HYBRID_default_configurations_folder}/smash_initial_conditions.yaml"
        [Hydro]=""
        [Sampler]=""
        [Afterburner]="${HYBRID_default_configurations_folder}/smash_afterburner.yaml"
        [Sampler_SMASH]="${HYBRID_default_configurations_folder}/hadron_sampler"
        [Sampler_FIST]="${HYBRID_default_configurations_folder}/fist_config"
        [Hydro_vHLLE]="${HYBRID_default_configurations_folder}/vhlle_hydro"
        [Hydro_MUSIC]="${HYBRID_default_configurations_folder}/music_hydro"
    )
```

* Add a base configuration in the `configs` folder for the new module.
* Adapt the check for valid modules in the :material-file:`sanity_checks.bash` script, and add a function to choose the base configuration file dependent on the module.
``` {.bash .no-copy title=global_variables.bash}
    function __static__Choose_Base_Configuration_File_For_Sampler()
    {
        if [[ "${HYBRID_software_base_config_file[Hydro]}" = '' ]]; then
            local -r hydro_key="Hydro_${HYBRID_module[Hydro]}"
            HYBRID_software_base_config_file[Hydro]="${HYBRID_software_base_config_file[${hydro_key}]}"
        fi
    }
```

* Add versions of the affected stage functionality script for the new module.
Shared logic stays in the common functionality script, whereas module-specific logic is implemented in the module-specific script.
The module dependent logic is implemented in functions with the suffix `_${MODULE_NAME}`. Therefore, if-clauses in the main stage script can be avoided.
* Don't forget to source the new files!
* Add a mock for the new module in the mocks folder.
