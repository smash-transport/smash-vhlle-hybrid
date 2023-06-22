#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Perform_Sanity_Checks_On_Provided_Input()
{
    local key base_file
    for key in "${HYBRID_valid_software_configuration_sections[@]}"; do
        if Element_In_Array_Equals_To "${key}" "${HYBRID_given_software_sections[@]}"; then
            __static__Ensure_Executable_Exists 'IC'
            HYBRID_software_output_directory[IC]="${HYBRID_output_directory}/${key}"
            base_file=$(basename "${HYBRID_software_base_config_file[${key}]}")
            HYBRID_software_configuration_file[IC]="${HYBRID_software_output_directory[${key}]}/${base_file}"
        fi
    done
    readonly HYBRID_software_output_directory HYBRID_software_configuration_file
}

function __static__Ensure_Executable_Exists()
{
    local label=$1 file_path
    file_path="${HYBRID_software_executable[${label}]}"
    if [[ "${file_path}" = '' ]]; then
        exit_code=${HYBRID_fatal_variable_unset} Print_Fatal_And_Exit\
            "Software executable for '${label}' run was not specified."
    elif [[ ! -f "${file_path}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            "The executable file for the '${label}' run was not found."
    elif [[ ! -x "${file_path}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
            "The executable file for the '${label}' run is not executable."
    fi
}
