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
        'Input_keys'
    )
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
    HYBRID_ic_software_executable=''
    HYBRID_hydro_software_executable=''
    HYBRID_sampler_software_executable=''
    HYBRID_Afterburner_software_executable=''
    HYBRID_given_software_sections=()
    declare -gA HYBRID_software_input=(
        ['IC']=''
        ['Hydro']=''
        ['Sampler']=''
        ['Afterburner']=''
    )
}
