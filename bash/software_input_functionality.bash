#===================================================
#
#    Copyright (c) 2023
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
    Remove_Comments_In_Existing_File "${base_input_file}"
    case "${style}" in
        YAML )
            __static__Replace_Keys_Into_YAML_File
            ;;
        TXT )
            __static__Replace_Keys_Into_Txt_File
            ;;
        * )
            Print_Internal_And_Exit "Wrong first argument passed to \"${FUNCNAME}\"."
            ;;
    esac
}

# NOTE: The following functions use the local variables of the calling function
function __static__Replace_Keys_Into_YAML_File()
{
    # Use yq -P to bring all YAML to same format (crucial for later check on number of lines)
    if ! yq -P --inplace "${base_input_file}" 2> /dev/null; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
            "File \"${base_input_file}\" does not seem to contain valid YAML syntax."
    elif ! keys_to_be_replaced=$(yq -P <(printf "${keys_to_be_replaced}\n") 2> /dev/null); then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit\
            'Keys to be replaced do not seem to contain valid YAML syntax.'
    fi
    local initial_number_of_lines
    initial_number_of_lines=$(wc -l < "${base_input_file}")
    # Use yq to merge the two "files" into the first one
    yq --inplace eval-all '. as $item ireduce ({}; . * $item)'\
        "${base_input_file}"\
        <(printf "${keys_to_be_replaced}\n")
    # The merge must not have changed the number of lines of input file. If it did,
    # it means that some key was not present and has been appended => Error!
    if [[ $(wc -l < "${base_input_file}") -ne ${initial_number_of_lines} ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
            'One or more provided software input keys were not found to be replaced'\
            "in the \"${base_input_file}\" file." "Please, check your configuration file."
    fi
}

function __static__Replace_Keys_Into_Txt_File()
{
    # Impose that both file and new keys have two entries per line
    if ! awk 'NF != 2 { exit 1 }' "${base_input_file}"; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
            "File \"${base_input_file}\" does not seem to contain two columns per line only!"
    elif ! awk 'NF != 2 { exit 1 }' <(printf "${keys_to_be_replaced}\n"); then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit\
            'Keys to be replaced do not seem to contain valid key-value syntax.'
    fi
    # NOTE: Since the YAML implementation is very general, here we can take advantage of it
    #       on constraint of inserting and then removing a ':' after the "key".
    awk -i inplace 'BEGIN{OFS=": "}{print $1, $2}' "${base_input_file}"
    keys_to_be_replaced=$(awk 'BEGIN{OFS=": "}{print $1, $2}' <<< "${keys_to_be_replaced}")
    __static__Replace_Keys_Into_YAML_File
    awk -i inplace 'BEGIN{FS=": "}{printf "%-20s%s\n", $1, $2}' "${base_input_file}"
}
