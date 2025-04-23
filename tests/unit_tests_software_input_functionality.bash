#===================================================
#
#    Copyright (c) 2023-2025
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
    base_input_file=${PWD}/${FUNCNAME}.yaml
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
    printf 'Key: Value\nFoo:\n  Bar: [0,1,2]\n' > "${base_input_file}"
    keys_to_be_replaced=$'New_key: value\nFoo:\n  Bar: [42, {Map: New}]\n  bar: True\n'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_YAML_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Valid YAML replacement but with non-existent keys in valid file succeeded.'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf 'Key: Value\nFoo:\n  Bar: [0,1,2]\n' > "${base_input_file}"
    keys_to_be_replaced=$'Key: new_value\nFoo:\n  Bar: 42\n'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_YAML_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Valid YAML replacement but changing array value to scalar in valid file succeeded.'
        return 1
    fi
    #---------------------------------------------------------------------------
    printf '0: Zero\nRoman:\n  1: I\n' > "${base_input_file}"
    keys_to_be_replaced=$'0: NULL\nRoman:\n  2: II\n'
    Call_Codebase_Function_In_Subshell __static__Replace_Keys_Into_YAML_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Valid YAML replacement but changing numeric map key in valid file succeeded.'
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
    base_input_file=${PWD}/${FUNCNAME}.yaml
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
