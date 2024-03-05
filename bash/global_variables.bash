#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# ATTENTION: The top-level section labels (i.e. 'IC', 'Hydro', etc.) are used in variable
#            names as well, although with lower-case letters only. In the codebase it has
#            been exerted leverage on this aspect and at some point the name of variables
#            are built using the section labels transformed into lower-case words. Hence,
#            it is important that section labels do not contain characters that would break
#            this mechanism, like dashes or spaces!
function Define_Further_Global_Variables()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_top_level_path
    # Constant information
    readonly HYBRID_valid_software_configuration_sections=(
        'IC'
        'Hydro'
        'Sampler'
        'Afterburner'
    )
    readonly HYBRID_valid_auxiliary_configuration_sections=(
        'Hybrid_handler'
    )
    readonly HYBRID_default_configurations_folder="${HYBRID_top_level_path}/configs"
    readonly HYBRID_python_folder="${HYBRID_top_level_path}/python"
    readonly HYBRID_afterburner_list_filename="sampled_particles_list.oscar"
    declare -rgA HYBRID_external_python_scripts=(
        [Add_spectators_from_IC]="${HYBRID_python_folder}/add_spectators.py"
    )
    declare -rgA HYBRID_software_default_input_filename=(
        [IC]=''
        [Hydro]="SMASH_IC.dat"
        [Sampler]="freezeout.dat" # Not used at the moment for how the sampler works
        [Spectators]="SMASH_IC.oscar"
        [Afterburner]="particle_lists.oscar"
    )
    declare -rgA HYBRID_software_configuration_filename=(
        [IC]='IC_config.yaml'
        [Hydro]='hydro_config.txt'
        [Sampler]='sampler_config.txt'
        [Afterburner]='afterburner_config.yaml'
    )
    declare -rgA HYBRID_terminal_output=(
        [IC]='IC.log'
        [Hydro]='Hydro.log'
        [Sampler]='Sampler.log'
        [Afterburner]='Afterburner.log'
    )
    declare -rgA HYBRID_handler_config_section_filename=(
        [IC]='Hybrid_handler_IC_config.yaml'
        [Hydro]='Hybrid_handler_Hydro_config.yaml'
        [Sampler]='Hybrid_handler_Sampler_config.yaml'
        [Afterburner]='Hybrid_handler_Afterburner_config.yaml'
    )
    # This array specifies a set of YAML lists of keys that define a valid parameter scan.
    # ATTENTION: The keys inside each YAML list must be alphabetically sorted to allow
    #            the validation mechanism to work!
    readonly HYBRID_valid_scan_specification_keys=(
        '[Range]'
        '[Values]'
    )
    readonly HYBRID_scan_combinations_filename='scan_combinations.dat'
    # The following associative arrays declare maps between valid keys in the handler config
    # file and bash variables in which the input information will be stored once parsed.
    declare -rgA HYBRID_hybrid_handler_valid_keys=(
        [Run_ID]='HYBRID_run_id'
        [Scan_strategy]='HYBRID_scan_strategy'
        [Number_of_Samples]='HYBRID_number_of_samples'
    )
    declare -rgA HYBRID_ic_valid_keys=(
        [Executable]='HYBRID_software_executable[IC]'
        [Config_file]='HYBRID_software_base_config_file[IC]'
        [Scan_parameters]='HYBRID_scan_parameters[IC]'
        [Software_keys]='HYBRID_software_new_input_keys[IC]'
    )
    declare -rgA HYBRID_hydro_valid_keys=(
        [Executable]='HYBRID_software_executable[Hydro]'
        [Config_file]='HYBRID_software_base_config_file[Hydro]'
        [Input_file]='HYBRID_software_user_custom_input_file[Hydro]'
        [Scan_parameters]='HYBRID_scan_parameters[Hydro]'
        [Software_keys]='HYBRID_software_new_input_keys[Hydro]'
    )
    declare -rgA HYBRID_sampler_valid_keys=(
        [Executable]='HYBRID_software_executable[Sampler]'
        [Config_file]='HYBRID_software_base_config_file[Sampler]'
        [Scan_parameters]='HYBRID_scan_parameters[Sampler]'
        [Software_keys]='HYBRID_software_new_input_keys[Sampler]'
    )
    declare -rgA HYBRID_afterburner_valid_keys=(
        [Executable]='HYBRID_software_executable[Afterburner]'
        [Config_file]='HYBRID_software_base_config_file[Afterburner]'
        [Input_file]='HYBRID_software_user_custom_input_file[Afterburner]'
        [Scan_parameters]='HYBRID_scan_parameters[Afterburner]'
        [Software_keys]='HYBRID_software_new_input_keys[Afterburner]'
        [Add_spectators_from_IC]='HYBRID_optional_feature[Add_spectators_from_IC]'
        [Spectators_source]='HYBRID_optional_feature[Spectators_source]'
    )
    # This array declares a list of boolean keys. Here we do not keep track of sections
    # as it would be strange to use the same key name in different sections once as
    # boolean and once as something else.
    declare -rg HYBRID_boolean_keys=(
        'Add_spectators_from_IC'
    )
    # Variables to be set (and possibly made readonly) from command line
    HYBRID_execution_mode='help'
    HYBRID_configuration_file='./config.yaml'
    HYBRID_output_directory="$(realpath './data')"
    HYBRID_scan_directory="${HYBRID_output_directory}/scan"
    # Variables to be set (and possibly made readonly) from configuration/setup
    HYBRID_run_id="Run_$(date +'%Y-%m-%d_%H%M%S')"
    HYBRID_scan_strategy='Combinations'
    HYBRID_number_of_samples=1
    HYBRID_given_software_sections=()
    declare -gA HYBRID_software_executable=(
        [IC]=''
        [Hydro]=''
        [Sampler]=''
        [Afterburner]=''
    )
    declare -gA HYBRID_software_user_custom_input_file=(
        [IC]=''
        [Hydro]=''
        [Sampler]=''
        [Spectators]=''
        [Afterburner]=''
    )
    declare -gA HYBRID_software_base_config_file=(
        [IC]="${HYBRID_default_configurations_folder}/smash_initial_conditions.yaml"
        [Hydro]="${HYBRID_default_configurations_folder}/vhlle_hydro"
        [Sampler]="${HYBRID_default_configurations_folder}/hadron_sampler"
        [Afterburner]="${HYBRID_default_configurations_folder}/smash_afterburner.yaml"
    )
    declare -gA HYBRID_scan_parameters=(
        [IC]=''
        [Hydro]=''
        [Sampler]=''
        [Afterburner]=''
    )
    declare -gA HYBRID_software_new_input_keys=(
        [IC]=''
        [Hydro]=''
        [Sampler]=''
        [Afterburner]=''
    )
    declare -gA HYBRID_optional_feature=(
        [Add_spectators_from_IC]='TRUE'
        [Spectators_source]=''
    )
    # Variables to be set (and possibly made readonly) after all sanity checks on input succeeded
    declare -gA HYBRID_software_output_directory=(
        [IC]=''
        [Hydro]=''
        [Sampler]=''
        [Afterburner]=''
    )
    declare -gA HYBRID_software_configuration_file=(
        [IC]=''
        [Hydro]=''
        [Sampler]=''
        [Afterburner]=''
    )
    declare -gA HYBRID_software_input_file=(
        [Hydro]=''
        [Spectators]=''
        [Afterburner]=''
    )
}

Make_Functions_Defined_In_This_File_Readonly
