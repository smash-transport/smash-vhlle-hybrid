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
        local -r \
            timestamp=$(date +'%d-%m-%Y  %H:%M:%S') \
            width=80
        {
            printf '\n\n\n'
            Print_Line_of_Equals ${width}
            Print_Centered_Line 'NEW RUN OUTPUT' ${width} '' '='
            Print_Centered_Line "${timestamp}" ${width} '' '='
            Print_Line_of_Equals ${width}
            printf '\n\n'
        } >> "${HYBRID_software_output_directory[$1]}/${HYBRID_terminal_output[$1]}"
    fi
}

function Report_About_Software_Failure_For()
{
    exit_code=${HYBRID_fatal_software_failed} Print_Fatal_And_Exit \
        '\n' --emph "$1" ' run failed.'
}

function Ensure_Input_File_Exists_And_Alert_If_Unfinished()
{
    # NOTE: 'input_file' variables follow symbolic links
    #       'realpath -m' is used to accept non existing paths
    local -r \
        input_file="$(realpath -m "$1")" \
        input_file_unfinished="$(realpath -m "${1}.unfinished")"
    if [[ ! -f "${input_file}" ]]; then
        if [[ -f "${input_file_unfinished}" ]]; then
            Ensure_Given_Files_Exist \
                "Instead of the correct input file, a different file was found:\n - " \
                --emph "${input_file_unfinished}" \
                "\nIt is possible the previous stage of the simulation failed." \
                -- "${input_file}"
        else
            Ensure_Given_Files_Exist "${input_file}"
        fi
    fi
}
