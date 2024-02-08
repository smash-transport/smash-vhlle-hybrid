#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Create_Output_Directory_For()
{
    mkdir -p "${HYBRID_software_output_directory[$1]}" || exit ${HYBRID_fatal_builtin}
}

function Copy_Base_Configuration_To_Output_Folder_For()
{
    cp "${HYBRID_software_base_config_file[$1]}" \
        "${HYBRID_software_configuration_file[$1]}" || exit ${HYBRID_fatal_builtin}
}

function Replace_Keys_In_Configuration_File_If_Needed_For()
{
    local file_type
    case "$1" in
        IC | Afterburner)
            file_type='YAML'
            ;;
        Hydro | Sampler)
            file_type='TXT'
            ;;
        *)
            Print_Internal_And_Exit 'Wrong call of ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
    if [[ "${HYBRID_software_new_input_keys[$1]}" != '' ]]; then
        Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
            "${file_type}" \
            "${HYBRID_software_configuration_file[$1]}" \
            "${HYBRID_software_new_input_keys[$1]}"
    fi
}

function Separate_Terminal_Output_For()
{
    if [[ -e "${HYBRID_software_output_directory[$1]}/${HYBRID_terminal_output[$1]}" ]]; then
        local timestamp=$(date +'%d-%m-%Y %H:%M:%S')
        printf '\n\n\n===== NEW RUN OUTPUT =====\n===== %s =====\n\n\n' "${timestamp}" >> \
            "${HYBRID_software_output_directory[$1]}/${HYBRID_terminal_output[$1]}"
    fi
}
