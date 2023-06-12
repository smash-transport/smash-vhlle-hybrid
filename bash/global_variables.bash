#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Define_Further_Global_Variables()
{
    # Constant information
    readonly HYBRID_valid_software_configuration_sections=(
        'IC'
        'Hydro'
        'Sampler'
        'Afterburner'
    )
    readonly HYBRID_valid_auxiliary_configuration_sections=(
        'Hybrid-handler'
    )
    readonly HYBRID_valid_common_software_keys=(
        'Executable'
        'Input_file'
        'Software_keys'
    )
    readonly HYBRID_hybrid_handler_valid_keys=()
    readonly HYBRID_ic_valid_keys=()
    readonly HYBRID_hydro_valid_keys=()
    readonly HYBRID_sampler_valid_keys=()
    readonly HYBRID_afterburner_valid_keys=()
    readonly HYBRID_default_configurations_folder="${HYBRID_repository_global_path}/configs"
    # Variables to be set from command line
    HYBRID_execution_mode='help'
    HYBRID_configuration_file='./config.yaml'
    HYBRID_output_directory='.'
    # Variables to be set from configuration/setup
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
}
