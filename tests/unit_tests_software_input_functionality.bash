#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__replace-in-software-input-YAML()
{
    source "${HYBRIDT_repository_top_level_path}"/bash/software_input_functionality.bash\
    || exit "${HYBRID_fatal_builtin}"
}

function Unit_Test__replace-in-software-input-YAML()
{
    local base_input_file keys_to_be_replaced expected_result
    base_input_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    # Test case 1:
    printf 'Scalar\nKey: Value\n' > "${base_input_file}"
    ( __static__Replace_Keys_Into_YAML_File &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'YAML replacement in invalid file succeeded'
        return 1
    fi
    # Test case 2:
    printf 'Key: Value\n' > "${base_input_file}"
    keys_to_be_replaced=$'Invalid\nyaml: syntax'
    ( __static__Replace_Keys_Into_YAML_File &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Invalid YAML replacement in valid file succeeded'
        return 1
    fi
    # Test case 3:
    printf 'Key: Value\n' > "${base_input_file}"
    keys_to_be_replaced='New_key: value'
    ( __static__Replace_Keys_Into_YAML_File &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Valid YAML replacement but with new key in valid file succeeded'
        return 1
    fi
    # Test case 4:
    printf\
    '
    Array:
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
    expected_result='
Array:
  - 5
  - 6
  - 7
Map:
  Key_1: Hi
  Key_2: Bye
Foo: BarBar'
    __static__Replace_Keys_Into_YAML_File
    if [[ "$(cat "${base_input_file}")" != "${expected_result}" ]]; then
        Print_Error "YAML replacement failed!"\
                    '---- OBTAINED: ----' "$(cat "${base_input_file}")"\
                    '---- EXPECTED: ----' "${expected_result}"\
                    '-------------------'
        return 1
    fi
}

function Unit_Test__replace-in-software-input-TXT()
{
    false
}
