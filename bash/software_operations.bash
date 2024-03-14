#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Copy_Hybrid_Handler_Config_Section()
{
    local -r \
        section=$1 \
        output_file="$2/${HYBRID_handler_config_section_filename[$1]}" \
        executable_folder=$3
    if [[ -f "${output_file}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'The config copy ' --emph "${output_file}" ' already exists.'
    fi
    local executable_metadata handler_metadata try_extract_section
    # NOTE: Using command substitution $(...) directly in printf arguments invalidates the error on
    #       exit behavior and let the script continue even if functions have non-zero exit code.
    #       Therefore we temporary store the resulting string in local variables.
    executable_metadata=$(__static__Get_Repository_State "${executable_folder}")
    handler_metadata=$(__static__Get_Repository_State "${HYBRID_top_level_path}")
    try_extract_section=$(__static__Extract_Sections_From_Configuration_File "${section}")
    printf '%s\n\n' \
        "# Git describe of executable folder: ${executable_metadata}" \
        "# Git describe of handler folder: ${handler_metadata}" \
        "${try_extract_section}" > "${output_file}"
}

function __static__Extract_Sections_From_Configuration_File()
{
    local section code=0
    section=$(
        yq "
            with_entries(select(.key | test(\"(Hybrid_handler|${1})\")))
            | .Hybrid_handler.Run_ID = \"${HYBRID_run_id}\"
        " "${HYBRID_configuration_file}"
    ) || code=$?
    if [[ ${code} -ne 0 ]]; then
        Print_Internal_And_Exit 'Failure extracting sections from configuration file for reproducibility.'
    else
        printf '%s' "${section}"
    fi
}

function __static__Get_Repository_State()
{
    local git_call code=0
    git_call=$(git -C "${1}" describe --long --always --all 2> /dev/null) || code=$?
    if [[ ${code} -ne 0 ]]; then
        printf 'Not a Git repository'
    else
        printf "%s" ${git_call}
    fi
}

Make_Functions_Defined_In_This_File_Readonly
