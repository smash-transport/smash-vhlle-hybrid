#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: It is assumed that '#' is the character to begins comments in input files
function Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File()
{
    local style base_input_file keys_to_be_replaced
    style=$1
    base_input_file=$2
    keys_to_be_replaced=$3
    Remove_Comments_In_File "${base_input_file}" # this checks for existence, too
    case "${style}" in
        YAML)
            __static__Replace_Keys_Into_YAML_File
            ;;
        TXT)
            __static__Replace_Keys_Into_Txt_File
            ;;
        *)
            Print_Internal_And_Exit "Wrong first argument passed to \"${FUNCNAME}\"."
            ;;
    esac
}

function __static__Replace_Keys_Into_YAML_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty base_input_file keys_to_be_replaced
    # Use yq -P to bring all YAML to same format (crucial for later check on number of lines)
    if ! yq -P --inplace "${base_input_file}" 2> /dev/null; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
            'File ' --emph "${base_input_file}" ' does not seem to contain valid YAML syntax. Run' \
            --emph "   yq -P --inplace \"${base_input_file}\"" \
            "\nto have more information about the problem."
    elif ! keys_to_be_replaced=$(yq -P <(printf "${keys_to_be_replaced}\n") 2> /dev/null); then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit \
            'Keys to be replaced do not seem to contain valid YAML syntax.'
    fi
    local initial_number_of_lines
    initial_number_of_lines=$(wc -l < "${base_input_file}")
    # Use yq to merge the two "files" into the first one
    yq --inplace eval-all '. as $item ireduce ({}; . * $item)' \
        "${base_input_file}" \
        <(printf "${keys_to_be_replaced}\n")
    # The merge must not have changed the number of lines of input file. If it did,
    # it means that some key was not present and has been appended => Error!
    if [[ $(wc -l < "${base_input_file}") -ne ${initial_number_of_lines} ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'One or more provided software input keys were not found to be replaced' \
            'in the ' --emph "${base_input_file}" ' file.' 'Please, check your configuration file.'
    fi
}

# NOTE: In this function we might try to keep the empty lines, but the YAML library will
#       strip them anyway and therefore it is convenient to strip them immediately.
function __static__Replace_Keys_Into_Txt_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty base_input_file keys_to_be_replaced
    # Strip lines with space only both in file and in the new keys list
    sed -i '/^[[:space:]]*$/d' "${base_input_file}"
    keys_to_be_replaced="$(sed '/^[[:space:]]*$/d' <(printf "${keys_to_be_replaced}\n"))"
    # Impose that both file and new keys have two entries per line
    if ! awk 'NF!=2 {exit 1}' "${base_input_file}"; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
            'File ' --emph "${base_input_file}" ' does not seem to contain two columns per line only!'
    elif ! awk 'NF!=2 {exit 1}' <(printf "${keys_to_be_replaced}\n"); then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit \
            'Keys to be replaced do not seem to contain valid key-value syntax.'
    fi
    if ! awk '$1 ~ /:$/ {exit 1}' "${base_input_file}"; then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit \
            'File ' --emph "${base_input_file}" ' should not have a colon at the end of keys!'
    fi
    local number_of_fields_per_line
    number_of_fields_per_line=(
        $(awk 'BEGIN{FS=":"}{print NF}' <(printf "${keys_to_be_replaced}\n") | sort -u)
    )
    if [[ ${#number_of_fields_per_line[@]} -gt 1 ]]; then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit \
            'Keys to be replaced do not have consistent colon-terminated keys syntax.'
    elif [[ ${number_of_fields_per_line[0]} -gt 2 ]]; then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit \
            'Keys to be replaced seem to use more than a colon after key(s).'
    fi
    # NOTE: Since the YAML implementation is very general, here we can take advantage of it
    #       on constraint of inserting (if needed) and then removing a ':' after the "key".
    awk -i inplace 'BEGIN{OFS=": "}{print $1, $2}' "${base_input_file}"
    if [[ ${number_of_fields_per_line[0]} -eq 1 ]]; then
        keys_to_be_replaced=$(awk 'BEGIN{OFS=": "}{print $1, $2}' <<< "${keys_to_be_replaced}")
    fi
    __static__Replace_Keys_Into_YAML_File
    # NOTE: Using ':' as field separator, spaces after it will be preserved, hence there
    #       is no worry about having potentially the two fields merged into one in printf.
    awk -i inplace 'BEGIN{FS=":"}{printf("%-20s%s\n", $1, $2)}' "${base_input_file}"
}

function Copy_Hybrid_Handler_Config_Section()
{
    local -r \
        section=$1 \
        output_file="$2/${HYBRID_handler_config_section_filename[$1]}" \
        executable_folder=$3
    if [[ -f "${output_file}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'The config copy ' --emph "${output_file}" \
            ' already exists.'
    fi
    local executable_metadata handler_metadata try_extract_section
    # NOTE: Using command substitution $(...) directly in printf arguments invalidates the error on
    #       exit behavior and let the script continue even if functions have non-zero exit code.
    #       Therefore we temporary store the resulting string in local variables.
    executable_metadata=$(__static__Get_Repository_State "${executable_folder}")
    handler_metadata=$(__static__Get_Repository_State "${HYBRID_top_level_path}")
    try_extract_section="$(__static__Extract_Sections_From_Configuration_File "${section}")"
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
