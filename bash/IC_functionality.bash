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
    # check if output directory exists and create it if not
    local IC_output_directory="${HYBRID_output_directory}/IC"
    if [[ ! -d "${IC_output_directory}" ]]; then
        mkdir "${IC_output_directory}" || exit ${HYBRID_fatal_builtin}
    fi

    echo "${HYBRID_default_configurations_folder}"
    # check if config already exists in the output directory, exit if yes
    IC_config_name=$(basename "${HYBRID_software_base_config_file[IC]}")
    IC_input_file_path="${IC_output_directory}/${IC_config_name}"
    if [[ ! -f "${IC_input_file_path}" ]]; then
        cp "${HYBRID_software_base_config_file[IC]}" "${IC_output_directory}" || exit ${HYBRID_fatal_builtin}
        # rewrite stuff
    else
        exit_code=${HYBRID_fatal_builtin} Print_Fatal_And_Exit\
            "File \"${IC_input_file_path}\" is already there."
    fi
}

function Ensure_All_Needed_Input_Exists_IC()
{
    Print_Not_Implemented_Function_Error
}

function Run_Software_IC()
{
    Print_Not_Implemented_Function_Error
}
