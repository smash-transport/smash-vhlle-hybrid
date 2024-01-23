#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_IC()
{
    mkdir -p "${HYBRID_software_output_directory[IC]}" || exit ${HYBRID_fatal_builtin}
    if [[ -f "${HYBRID_software_configuration_file[IC]}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'Configuration file ' --emph "${HYBRID_software_configuration_file[IC]}" ' is already existing.'
    elif [[ ! -f "${HYBRID_software_base_config_file[IC]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'Base configuration file ' --emph "${HYBRID_software_base_config_file[IC]}" ' was not found.'
    fi
    cp "${HYBRID_software_base_config_file[IC]}" \
        "${HYBRID_software_configuration_file[IC]}" || exit ${HYBRID_fatal_builtin}
    if [[ "${HYBRID_software_new_input_keys[IC]}" != '' ]]; then
        Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
            'YAML' "${HYBRID_software_configuration_file[IC]}" "${HYBRID_software_new_input_keys[IC]}"
    fi
}

function Ensure_All_Needed_Input_Exists_IC()
{
    if [[ ! -d "${HYBRID_software_output_directory[IC]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'Folder ' --emph "${HYBRID_software_output_directory[IC]}" ' does not exist.'
    fi
    if [[ ! -f "${HYBRID_software_configuration_file[IC]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'The configuration file ' --emph "${HYBRID_software_configuration_file[IC]}" ' was not found.'
    fi
}

function Run_Software_IC()
{
    Copy_Hybrid_Handler_Config_Section "IC" "${HYBRID_software_output_directory[IC]}"
    cd "${HYBRID_software_output_directory[IC]}"
    local ic_terminal_output="${HYBRID_software_output_directory[IC]}/Terminal_Output.txt"
    "${HYBRID_software_executable[IC]}" \
        '-i' "${HYBRID_software_configuration_file[IC]}" \
        '-o' "${HYBRID_software_output_directory[IC]}" \
        '-n' \
        >> "${ic_terminal_output}"
}

Make_Functions_Defined_In_This_File_Readonly
