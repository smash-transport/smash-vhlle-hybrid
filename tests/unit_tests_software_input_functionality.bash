#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__replace-in-software-input-YAML()
{
    source "${HYBRIDT_repository_top_level_path}"/bash/software_input_functionality.bash \
        || exit "${HYBRID_fatal_builtin}"
}

function Unit_Test__replace-in-software-input-YAML()
{
    # NOTE: The following variables must be named exactly so as the are used
    #       by __static__Replace_Keys_Into_YAML_File function
    local base_input_file keys_to_be_replaced expected_result
    base_input_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    #---------------------------------------------------------------------------
    printf 'Scalar\nKey: Value\n' > "${base_input_file}"
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_YAML_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'YAML replacement in invalid file succeeded.'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Key: Value\n' > "${base_input_file}"
    keys_to_be_replaced=$'Invalid\nyaml: syntax'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_YAML_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Invalid YAML replacement in valid file succeeded.'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Key: Value\n' > "${base_input_file}"
    keys_to_be_replaced='New_key: value'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_YAML_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Valid YAML replacement but with non existent key in valid file succeeded.'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Array:
  - 1
  - 2
  - 3

Map:
  Key_1: Hi
  Key_2: Bye
Foo: Bar
    ' > "${base_input_file}"
    keys_to_be_replaced='
    Array: [5,6,7]
    Foo: BarBar
    '
    expected_result='Array:
  - 5
  - 6
  - 7
Map:
  Key_1: Hi
  Key_2: Bye
Foo: BarBar'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_YAML_File
    # yq in v4.30.6 fixed the behavior of keeping leading empty lines
    # so it is important here to have no leading empty lines, otherwise
    # this test would succeed/fail depending on yq version available!
    if [[ "$(< "${base_input_file}")" != "${expected_result}" ]]; then
        Print_Error \
            "YAML replacement failed!" \
            '---- OBTAINED: ----' "$(< "${base_input_file}")" \
            '---- EXPECTED: ----' "${expected_result}" \
            '-------------------'
        return 1
    fi
    rm "${base_input_file}"
}

function Make_Test_Preliminary_Operations__replace-in-software-input-TXT()
{
    Make_Test_Preliminary_Operations__replace-in-software-input-YAML
}

function Unit_Test__replace-in-software-input-TXT()
{
    # NOTE: The following variables must be named exactly so as the are used
    #       by __static__Replace_Keys_Into_Txt_File function
    local base_input_file keys_to_be_replaced expected_result
    base_input_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    #---------------------------------------------------------------------------
    printf 'Key Value Extra-field\n' > "${base_input_file}"
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'TXT replacement in invalid (too many columns) file succeeded.'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Key: Value\n' > "${base_input_file}"
    keys_to_be_replaced='Key: Another_value'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'TXT replacement in invalid file (colon at end of key) succeeded.'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Key: Value\n' > "${base_input_file}"
    keys_to_be_replaced='Invalid txt syntax'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Invalid TXT replacement in valid file succeeded'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Key Value\n' > "${base_input_file}"
    keys_to_be_replaced='New_key value'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Valid TXT replacement but with non existent key in valid file succeeded'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Key Value\n' > "${base_input_file}"
    keys_to_be_replaced=$'New_key: value\nOther_key value'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Invalid TXT replacement with inconsistent colons succeeded'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Key Value\n' > "${base_input_file}"
    keys_to_be_replaced=$'New_key:: value\nOther_key:: value'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Invalid TXT replacement with too many colons succeeded'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'a 0.123\nb 0.456\nc 0.789\n' > "${base_input_file}"
    keys_to_be_replaced=$'a 42\nc 77'
    printf -v expected_result "%-20s %s\n" 'a' '42' 'b' '0.456' 'c' '77'
    expected_result=${expected_result%?} # Get rid of trailing endline
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File
    if [[ "$(< "${base_input_file}")" != "${expected_result}" ]]; then
        Print_Error \
            "YAML replacement failed!" \
            "---- OBTAINED: ----\n$(< "${base_input_file}")" \
            "---- EXPECTED: ----\n${expected_result}" \
            '-------------------'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'a 0.123\n  \nb 0.456\n\nc 0.789\n' > "${base_input_file}"
    keys_to_be_replaced=$'a 42\n   \n\nc 77'
    printf -v expected_result "%-20s %s\n" 'a' '42' 'b' '0.456' 'c' '77'
    expected_result=${expected_result%?} # Get rid of trailing endline
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File
    if [[ "$(< "${base_input_file}")" != "${expected_result}" ]]; then
        Print_Error \
            "YAML replacement failed!" \
            "---- OBTAINED: ----\n$(< "${base_input_file}")" \
            "---- EXPECTED: ----\n${expected_result}" \
            '-------------------'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'a 0.123\nb 0.456\nvery_very_very_long_key 0.789\n' > "${base_input_file}"
    keys_to_be_replaced=$'a: 42\nvery_very_very_long_key: 77'
    printf -v expected_result "%-20s %s\n" 'a' '42' 'b' '0.456' 'very_very_very_long_key' '77'
    expected_result=${expected_result%?} # Get rid of trailing endline
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_Txt_File
    if [[ "$(< "${base_input_file}")" != "${expected_result}" ]]; then
        Print_Error \
            "YAML replacement failed!" \
            "---- OBTAINED: ----\n$(< "${base_input_file}")" \
            "---- EXPECTED: ----\n${expected_result}" \
            '-------------------'
        return 1
    fi
    rm "${base_input_file}"
}

function Make_Test_Preliminary_Operations__copy-hybrid-handler-config-section()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'global_variables.bash'
        'software_input_functionality.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__copy-hybrid-handler-config-section()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    # Avoid empty lines in the beginning in this test as yq behavior
    # might change with different versions (here we compare strings)
    printf '%s\n' \
        'Hybrid_handler:' \
        '  Run_ID: test' \
        'IC:' \
        '  Executable: ex' \
        '  Config_file: conf' \
        'Hydro:' \
        '  Executable: exh' \
        '  Config_file: confh' > "${HYBRID_configuration_file}"
    local -r git_description="$(git -C "${HYBRIDT_folder_to_run_tests}" describe --long --always --all)"
    local folder description
    for folder in "${HYBRIDT_folder_to_run_tests}" ~; do
        Call_Codebase_Function_In_Subshell Copy_Hybrid_Handler_Config_Section 'IC' \
            "${HYBRIDT_folder_to_run_tests}" "${folder}" #&> /dev/null
        if [[ "${folder}" = "${HYBRIDT_folder_to_run_tests}" ]]; then
            description="${git_description}"
        else
            description='Not a Git repository'
        fi
        printf -v expected_result '%b' \
            "# Git describe of executable folder: ${description}\n\n" \
            "# Git describe of handler folder: ${git_description}\n\n" \
            'Hybrid_handler:\n' \
            '  Run_ID: test\n' \
            'IC:\n' \
            '  Executable: ex\n' \
            '  Config_file: conf' # No trailing endline as "$(< ...)" strips them
        if [[ "$(< "${HYBRID_handler_config_section_filename[IC]}")" != "${expected_result}" ]]; then
            Print_Error \
                "Copying of relevant handler config sections failed!" \
                "---- OBTAINED: ----\n$(< "${HYBRID_handler_config_section_filename[IC]}")" \
                "---- EXPECTED: ----\n${expected_result}" \
                '-------------------'
            return 1
        fi
        rm "${HYBRID_handler_config_section_filename[IC]}"
    done
}

function Unit_Test__add-section-terminal-output()
{
    local -r \
        config_filename='IC_config.yaml' \
        run_id='IC_only'
    printf '
    Hybrid_handler:
      Run_ID: %s
    IC:
      Executable: %s/tests/mocks/smash_IC_black-box.py
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    mkdir -p "IC/${run_id}"
    touch "IC/${run_id}/IC.log"
    printf "first line" >> "IC/${run_id}/IC.log"
    Print_Info 'Running Hybrid-handler expecting success'
    ("${HYBRIDT_repository_top_level_path}/Hybrid-handler" 'do' '-c' "${config_filename}")
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    local -r \
        string_to_be_found="first line==========================================" \
        +"======================================" \
        +"================================ NEW RUN OUTPUT ================================"
    string_to_search=$(head -n 5 "IC/${run_id}/IC.log" | tr -d '\n')
    if ! [[ "$string_to_search" == "$string_to_be_found"*"=====" ]]; then
        Print_Error 'Terminal output file not properly separated.'
        return 1
    fi
}
