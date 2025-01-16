# Adding a new module

Although the SMASH-vHLLE-hybrid, as implied in the name, was built with a defined set of software modules, it is designed to be easily extensible with new modules.
This allows, amongst other things, to test new algorithms and study model dependency.

!!! tip "Take inspiration from the existing modules"

    The first alternative module to be implemented was the FIST sampler, which shares many similarities with the SMASH sampler.
    The implementation of the FIST sampler can be used as a reference for the implementation of new modules.

!!! warning "Take the following instructions with a pinch of salt"

    Giving coding instructions in documentation has always the drawback that these might get outdated or simply become wrong with the evolution of the codebase.
    In this case the mentioned snippets of code are unlikely to be invalid at some point, but you should keep in mind that something might have to be done in a slightly different way.
    If so, you can take the opportunity to refine these instructions. :wink:

Adding a new module to the SMASH-vHLLE-hybrid is a straightforward process.
The following steps serve as a guidance and will probably be needed. Let's assume we want to add [MUSIC](https://github.com/MUSIC-fluid/MUSIC) as an alternative for the hydrodynamic stage:

* In case the stage has no other modules, add a field to the `HYBRID_module` array in the :material-file: *global_variables.bash* script for the respective stage :material-information-outline:{ title="Here <mark style='background-color: #F0F0F0;'><tt>Hydro</tt></mark>"}.

      ``` {.bash .no-copy title=global_variables.bash hl_lines=3}
      declare -gA HYBRID_module=(
          [Sampler]="${HYBRID_default_sampler_module}"
          [Hydro]="${HYBRID_default_hydro_module}"
      )
      ```
      where the `HYBRID_default_hydro_module` has to be defined above in the same file.

* At the same place, add alternative base configuration files for the stages named `<STAGE_NAME>_<MODULE_NAME>` :material-information-outline:{ title="Here <mark style='background-color: #F0F0F0;'><tt>Hydro_MUSIC</tt></mark>"} and add   `[Module]` to the valid keys of the stage.

    ``` {.bash .no-copy title=global_variables.bash hl_lines="5 11 16-17"}
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

    ??? question "Why are `[Hydro]` and `[Sampler]` set to empty strings?"

        In this function, called *very* early in the main script, only global variables are declared and not all the information is available.
        In particular, it is not yet known which software will be chosen by the user (e.g. vHLLE or MUSIC).
        Such a variable will be set after having parsed the handler configuration file and it will be used in the actual implementation of the stage-specific operations.


* Add a base configuration in the :file_folder: **configs** folder for the new module.

* Adapt the check for valid modules in the :material-file: *sanity_checks.bash* script by modifying the `if`-clause as below and adding a new version of each function for the new stage.

    ``` {.bash .no-copy title=sanity_checks.bash}
    if [[ "${key}" =~ ^(Hydro|Sampler)$ ]]; then
        __static__Ensure_Valid_Module_Given_For_${key}
        __static__Choose_Base_Configuration_File_For_${key}
        __static__Ensure_Additional_Paths_Given_For_${key}
        __static__Set_${key}_Input_Key_Paths
    fi
    ```

* Add versions of the affected stage functionality script for the new module.
  Shared logic stays in the common functionality script, whereas module-specific logic is implemented in the module-specific script.
  The module dependent logic is implemented in functions with the suffix `_${MODULE_NAME}` :material-information-outline:{ title="Here <mark style='background-color: #F0F0F0;'><tt>MUSIC</tt></mark>"}.
  Therefore, `if`-clauses in the main stage script can be avoided.

* Add new behavior to the black-box script for the new module in the :file_folder: **tests/mocks** folder.
  The switch should be possible to be done via an environment variable as done for the hadron sampler.

* Don't forget to source the new files! :sweat_smile:
