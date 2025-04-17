#===================================================
#
#    Copyright (c) 2023-2025
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
    __static__Abort_With_Descriptive_Report_If_YAML_Replacement_Is_Not_Possible
    # If replacement is possible, use yq to merge the two "files" into the first one
    yq --inplace eval-all '. as $item ireduce ({}; . * $item)' \
        "${base_input_file}" \
        <(printf "${keys_to_be_replaced}\n")
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

#===================================================================================================

function __static__Abort_With_Descriptive_Report_If_YAML_Replacement_Is_Not_Possible()
{
    Ensure_That_Given_Variables_Are_Set base_input_file keys_to_be_replaced
    # Here the basic idea is to go through the YAML tree and create complete
    # paths to the values concatenating all keys with a period. Array indices
    # are replaced by "[]" as we are not interested at tracking them (a key
    # having an array value can be substituted by another array).
    #
    # NOTE: One might think that working with "properties"
    #         -> https://mikefarah.gitbook.io/yq/usage/properties
    #       might be simpler. Actually, using -o=props it is not possible
    #       to distinguish in the output between numeric keys and array
    #       indices. Hence we did not work with properties.
    #
    # NOTE: If a key contains a period, the used method should work, but the
    #       error message is not totally transparent. We do not want to
    #       improve on this case for the moment.
    local base_input_file_as_properties keys_to_be_replaced_as_properties
    base_input_file_as_properties=$(
        yq '.. |
            select(tag != "!!map" and tag != "!!seq") |
            path |
            with(.[]; select(tag == "!!int") |= "[]") |
            join(".")' "${base_input_file}"
    )
    keys_to_be_replaced_as_properties=$(
        yq '.. |
            select(tag != "!!map" and tag != "!!seq") |
            path |
            with(.[]; select(tag == "!!int") |= "[]") |
            join(".")' <(printf "${keys_to_be_replaced}\n")
    )
    # Get list of keys into bash arrays. Since before we replaced array indices
    # by [], there might be duplicate here, which we remove. We also use sed to
    # replace any ".[]" by simply "[]". This makes a possible error message more
    # readable. ASSUMPTION: No space in the keys -> word splitting does the job.
    local list_of_base_keys list_of_keys_to_be_found key
    list_of_base_keys=(
        $(sed -r 's/\.(\[\])/\1/g' <<< "${base_input_file_as_properties}" | sort -u)
    )
    list_of_keys_to_be_found=(
        $(sed -r 's/\.(\[\])/\1/g' <<< "${keys_to_be_replaced_as_properties}" | sort -u)
    )
    # Final search and report
    local list_of_faulty_keys=()
    for key in "${list_of_keys_to_be_found[@]}"; do
        if ! Element_In_Array_Equals_To "${key}" "${list_of_base_keys[@]}"; then
            list_of_faulty_keys+=("${key}")
        fi
    done
    if [[ ${#list_of_faulty_keys[@]} -ne 0 ]]; then
        # If this function was called from a TXT replacement, drop YAML hint for user
        local yaml_description=' (YAML map keys concatenated by "." and arrays denoted by "[]")'
        if [[ ${FUNCNAME[2]-} = *Txt* ]]; then
            yaml_description=''
        fi
        Print_Error -- \
            'One or more provided software input keys were not found to be replaced' \
            'in the ' --emph "${base_input_file}" ' file.' \
            "List of faulty keys${yaml_description}:"
        for key in "${list_of_faulty_keys[@]}"; do
            Print_Error -l -- ' - ' --emph "${key}"
        done
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit -- \
            'Unable to continue. Please, check your configuration file.'
    fi
}

Make_Functions_Defined_In_This_File_Readonly
