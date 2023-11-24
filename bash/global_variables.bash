#===================================================
#
#    Copyright (c) 2023
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
    declare -rgA HYBRID_external_python_scripts=(
        [Add_spectators_from_IC]="${HYBRID_python_folder}/add_spectators.py"
    )
    # The following associative arrays declare maps between valid keys in the handler config
    # file and bash variables in which the input information will be stored once parsed.
    declare -rgA HYBRID_hybrid_handler_valid_keys=()
    declare -rgA HYBRID_ic_valid_keys=(
        [Executable]='HYBRID_software_executable[IC]'
        [Input_file]='HYBRID_software_base_config_file[IC]'
        [Software_keys]='HYBRID_software_new_input_keys[IC]'
    )
    declare -rgA HYBRID_hydro_valid_keys=(
        [Executable]='HYBRID_software_executable[Hydro]'
        [Input_file]='HYBRID_software_base_config_file[Hydro]'
        [Software_keys]='HYBRID_software_new_input_keys[Hydro]'
    )
    declare -rgA HYBRID_sampler_valid_keys=(
        [Executable]='HYBRID_software_executable[Sampler]'
        [Input_file]='HYBRID_software_base_config_file[Sampler]'
        [Software_keys]='HYBRID_software_new_input_keys[Sampler]'
    )
    declare -rgA HYBRID_afterburner_valid_keys=(
        [Executable]='HYBRID_software_executable[Afterburner]'
        [Input_file]='HYBRID_software_base_config_file[Afterburner]'
        [Software_keys]='HYBRID_software_new_input_keys[Afterburner]'
        [Add_spectators_from_IC]='HYBRID_optional_feature[Add_spectators_from_IC]'
    )
    declare -rgA HYBRID_software_input_filename=(
        [IC]='IC_config.yaml'
        [Hydro]='hydro_config.txt'
        [Sampler]='sampler_config.txt'
        [Afterburner]='afterburner_config.yaml'
    )
    # Variables to be set (and possibly made readonly) from command line
    HYBRID_execution_mode='help'
    HYBRID_configuration_file='./config.yaml'
    HYBRID_output_directory="$(realpath .)"
    # Variables to be set (and possibly made readonly) from configuration/setup
    HYBRID_given_software_sections=()
    declare -gA HYBRID_software_executable=(
        [IC]=''
        [Hydro]=''
        [Sampler]=''
        [Afterburner]=''
    )
    declare -gA HYBRID_software_base_config_file=(
        [IC]="${HYBRID_default_configurations_folder}/smash_initial_conditions_AuAu.yaml"
        [Hydro]="${HYBRID_default_configurations_folder}/vhlle_hydro"
        [Sampler]="${HYBRID_default_configurations_folder}/hadron_sampler"
        [Afterburner]="${HYBRID_default_configurations_folder}/smash_afterburner.yaml"
    )
    declare -gA HYBRID_software_new_input_keys=(
        [IC]=''
        [Hydro]=''
        [Sampler]=''
        [Afterburner]=''
    )
    declare -gA HYBRID_optional_feature=(
        [Add_spectators_from_IC]='FALSE'
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
}


Make_Functions_Defined_In_This_File_Readonly
