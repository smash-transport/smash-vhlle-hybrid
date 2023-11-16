#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables()
{
    local key base_file
    for key in "${HYBRID_valid_software_configuration_sections[@]}"; do
        # The software output directories are always ALL set, even if not all software is run. This
        # is important as some software might rely on files in directories of other workflow blocks.
        HYBRID_software_output_directory[${key}]="${HYBRID_output_directory}/${key}"
        if Element_In_Array_Equals_To "${key}" "${HYBRID_given_software_sections[@]}"; then
            __static__Ensure_Executable_Exists "${key}"
            base_file=$(basename "${HYBRID_software_base_config_file[${key}]}")
            HYBRID_software_configuration_file[${key}]="${HYBRID_software_output_directory[${key}]}/${base_file}"
        fi
    done
    readonly HYBRID_software_output_directory HYBRID_software_configuration_file 
}

function Perform_Sanity_Checks_On_Existence_Of_External_Python_Scripts()
{
    for external_file in "${HYBRID_external_python_scripts[@]}"; do
        if [[ ! -f "${external_file}" ]]; then
            exit_code=${HYBRID_fatal_file_not_found} Print_Internal_And_Exit\
                'The python script ' --emph "${external_file}" ' was not found.'
        fi
    done 
}

function __static__Ensure_Executable_Exists()
{
    local label=$1 executable
    executable="${HYBRID_software_executable[${label}]}"
    if [[ "${executable}" = '' ]]; then
        exit_code=${HYBRID_fatal_variable_unset} Print_Fatal_And_Exit\
            'Software executable for ' --emph "${label}" ' run was not specified.'
    elif [[ "${executable}" =~ / ]]; then 
        if [[ ! "${executable}" =~ ^[/~] ]]; then
            exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit\
                'The executable file for the ' --emph "${label}" ' should be either a command or a global path.'
        elif [[ ! -f "${executable}" ]]; then
            exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
                'The executable file for the ' --emph "${label}" ' run was not found.'
        elif [[ ! -x "${executable}" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
                'The executable file for the ' --emph "${label}" ' run is not executable.'
        fi
    fi
}


Make_Functions_Defined_In_This_File_Readonly
