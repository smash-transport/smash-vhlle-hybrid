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
    # check if output directory exists
    local IC_output_directory="${HYBRID_output_directory}/IC"
    if [[ ! -d "${IC_output_directory}" ]]; then
        mkdir "${IC_output_directory}" || exit ${HYBRID_fatal_builtin}
    fi

    # check if config already exists
    local IC_config_name=$(basename "${HYBRID_software_base_config_file[IC]}")
    local IC_input_file_path="${IC_output_directory}/${IC_config_name}"
    if [[ ! -f "${IC_input_file_path}" ]]; then
        cp "${HYBRID_software_base_config_file[IC]}" "${IC_output_directory}" || exit ${HYBRID_fatal_builtin}
        if [[ "${HYBRID_software_new_input_keys[IC]}" != '' ]]; then
            Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File\
                'YAML' "${IC_input_file_path}" "${HYBRID_software_new_input_keys[IC]}"
        fi
    else
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
            "File \"${IC_input_file_path}\" is already there."
    fi
}

function Ensure_All_Needed_Input_Exists_IC()
{
    # check if path exists
    local IC_output_directory="${HYBRID_output_directory}/IC"
    if [[ ! -d "${IC_output_directory}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            "Folder \"${IC_output_directory}\" does not exist."
    fi
    # check if config exists
    local IC_config_name=$(basename "${HYBRID_software_base_config_file[IC]}")
    local IC_input_file_path="${IC_output_directory}/${IC_config_name}"
    if [[ ! -f "${IC_input_file_path}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            "The config \"${IC_input_file_path}\" does not exist."
    fi
}

function Run_Software_IC()
{
    local IC_output_directory="${HYBRID_output_directory}/IC"
    local IC_terminal_output="${HYBRID_output_directory}/IC/Terminal_Output.txt"
    local IC_config_name=$(basename "${HYBRID_software_base_config_file[IC]}")
    local IC_input_file_path="${IC_output_directory}/${IC_config_name}"

    ./"${HYBRID_software_executable[IC]}" \
       '-i' "${IC_input_file_path}" \
       '-o' "${IC_output_directory}" \
       '-n' \
       >> "${IC_terminal_output}"
}
