#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: No need to source utility functions code, as the test runner uses them!

function Unit_Test__utility-has-YAML-string-given-key()
{
    ( Has_YAML_String_Given_Key &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Wrong call to function succeeded."
        return 1
    fi
    ( Has_YAML_String_Given_Key $'Scalar\nKey: Value\n' 'Key' &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Function called on invalid YAML succeeded."
        return 1
    fi
    ( Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' 'b' 'c' &> /dev/null )
    if [[ $? -ne 0 ]] ; then
        Print_Error 'Existing key ' --emph '{a: {b: {c:}}}' ' not found.'
        return 1
    fi
    ( Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' 'b' &> /dev/null )
    if [[ $? -ne 0 ]] ; then
        Print_Error 'Existing key ' --emph '{a: {b:}}' ' not found.'
        return 1
    fi
    ( Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' &> /dev/null )
    if [[ $? -ne 0 ]] ; then
        Print_Error 'Existing key ' --emph '{a:}' ' not found.'
        return 1
    fi
    ( Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' 'b' 'nope' &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Not existing key found."
        return 1
    fi
}

function Unit_Test__utility-read-from-YAML-string-given-key()
{
    ( Read_From_YAML_String_Given_Key &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Wrong call to function succeeded."
        return 1
    fi
    ( Read_From_YAML_String_Given_Key $'Scalar\nKey: Value\n' 'Key' &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Function called on invalid YAML succeeded."
        return 1
    fi
    ( Read_From_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'nope' &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Not existing key successfully read."
        return 1
    fi
    local result
    result=$(Read_From_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' 'b' 'c')
    if [[ ${result} -ne 42 ]] ; then
        Print_Error "Reading scalar key failed."
        return 1
    fi
    result=$(Read_From_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' 'b')
    if [[ "${result}" != 'c: 42' ]] ; then
        Print_Error "Reading map key failed."
        return 1
    fi
}

function Unit_Test__utility-print-YAML-string-without-given-key()
{
    ( Print_YAML_String_Without_Given_Key &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Wrong call to function succeeded."
        return 1
    fi
    ( Print_YAML_String_Without_Given_Key $'Scalar\nKey: Value\n' 'Key' &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Function called on invalid YAML succeeded."
        return 1
    fi
    ( Print_YAML_String_Without_Given_Key $'a:\n  b: 42\n' 'nope' &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Not existing key successfully deleted."
        return 1
    fi
    local result
    result=$(Print_YAML_String_Without_Given_Key $'a: 42\nb: 17\n' 'b')
    if [[ "${result}" != 'a: 42' ]] ; then
        Print_Error "Deleting scalar key failed."
        return 1
    fi
    result=$(Print_YAML_String_Without_Given_Key $'a:\n  b:\n    c: 17\n' 'a' 'b')
    if [[ "${result}" != 'a: {}' ]] ; then
        Print_Error "Deleting map key failed."
        return 1
    fi
    result=$(Print_YAML_String_Without_Given_Key $'a: 42\n' 'a')
    if [[ "${result}" != '{}' ]] ; then
        Print_Error "Deleting only existing key failed."
        return 1
    fi
}

function Unit_Test__utility-remove-comments-in-existing-file()
{
    local number_of_lines
    cd "${HYBRIDT_folder_to_run_tests}"
    # Test case 0
    ( Remove_Comments_In_Existing_File 'not_existing_file.txt' &> /dev/null )
    if [[ $? -eq 0 ]] ; then
        Print_Error "Remove comments on not existent file did not fail."
        return 1
    fi
    # Test case 1
    local -r file_containing_one_commented_line_only=${FUNCNAME}_1.txt
    printf '   # Comment\n' > "${file_containing_one_commented_line_only}"
    Remove_Comments_In_File "${file_containing_one_commented_line_only}"
    if [[ -s "${file_containing_one_commented_line_only}" ]]; then
        Print_Error 'File ' --emph "${file_containing_one_commented_line_only}" ' not empty.'
        return 1
    fi
    rm "${file_containing_one_commented_line_only}"
    # Test case 2
    local -r file_containing_no_comments=${FUNCNAME}_2.txt
    printf $'No comment\nin any\nline\n' > "${file_containing_no_comments}"
    number_of_lines=$(wc -l < "${file_containing_no_comments}")
    Remove_Comments_In_File "${file_containing_no_comments}"
    if [[ $(wc -l < "${file_containing_no_comments}") -ne ${number_of_lines} ]]; then
        Print_Error 'Removing comments in ' --emph "${file_containing_no_comments}" ' file failed.'
        return 1
    fi
    rm "${file_containing_no_comments}"
    # Test case 3
    local -r file_containing_three_commented_lines=${FUNCNAME}_3.txt
    printf $'Some\n #comment\ntext\n#comment\namong\n#comment\ncomments\n' > "${file_containing_three_commented_lines}"
    number_of_lines=$(wc -l < "${file_containing_three_commented_lines}")
    Remove_Comments_In_File "${file_containing_three_commented_lines}"
    if (( $(wc -l < "${file_containing_three_commented_lines}") != number_of_lines - 3 )); then
        Print_Error 'Removing comments in ' --emph "${file_containing_three_commented_lines}" ' file failed.'
        return 1
    fi
    rm "${file_containing_three_commented_lines}"
    # Test case 4
    local -r file_containing_one_line_with_an_inline_comment=${FUNCNAME}_4.txt
    printf 'Hello   %% Comment\n' > "${file_containing_one_line_with_an_inline_comment}"
    Remove_Comments_In_File "${file_containing_one_line_with_an_inline_comment}" '%'
    if [[ $(cat "${file_containing_one_line_with_an_inline_comment}") != 'Hello' ]]; then
        Print_Error 'Removing comments in ' --emph "${file_containing_one_line_with_an_inline_comment}" ' file failed.'
        return 1
    fi
    rm "${file_containing_one_line_with_an_inline_comment}"
}

function Unit_Test__utility-check-shell-variables-set()
{
    ( Ensure_That_Given_Variables_Are_Set foo &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking unset variable succeeded.'
        return 1
    fi
    local foo
    ( Ensure_That_Given_Variables_Are_Set foo &> /dev/null )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set but unassigned variable failed.'
        return 1
    fi
    foo=''
    ( Ensure_That_Given_Variables_Are_Set foo &> /dev/null )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set but empty variable failed.'
        return 1
    fi
    foo='bar'
    ( Ensure_That_Given_Variables_Are_Set foo )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set and not empty string-variable failed.'
        return 1
    fi
    foo=()
    ( Ensure_That_Given_Variables_Are_Set foo )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking empty array variable failed.'
        return 1
    fi
    foo=( '' )
    ( Ensure_That_Given_Variables_Are_Set foo )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking array variable set to one empty entry failed.'
        return 1
    fi
    declare -A bar=([Hi]='')
    ( Ensure_That_Given_Variables_Are_Set bar )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking associative array variable set to one empty entry failed.'
        return 1
    fi
    ( Ensure_That_Given_Variables_Are_Set bar[Hi] )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking associative array entry set to one empty entry failed.'
        return 1
    fi
}

function Unit_Test__utility-check-shell-variables-set-not-empty()
{
    local foo
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking set but unassigned variable succeeded.'
        return 1
    fi
    foo=''
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking set but empty variable succeeded.'
        return 1
    fi
    foo='bar'
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set and not empty variable failed.'
        return 1
    fi
    foo=()
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo &> /dev/null)
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking empty array variable succeeded.'
        return 1
    fi
    foo=( '' )
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking array variable set to one empty entry failed.'
        return 1
    fi
    declare -A bar
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty bar &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking set but unassigned associative array succeeded.'
        return 1
    fi
    bar['key']=''
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty bar )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set associative array failed.'
        return 1
    fi
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty bar[key] &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking empty associative array entry succeeded.'
        return 1
    fi
    bar['key']='something'
    ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty bar[key] )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set associative array entry failed.'
        return 1
    fi
}

function __static__Test_ANSI_Code_Removal()
{
    Ensure_That_Given_Variables_Are_Set output
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty input expected_output
    output=$(Strip_ANSI_Color_Codes_From_String "${input}")
    if [[ "${output}" != "${expected_output}" ]]; then
        Print_Error 'Removing format code from ' --emph "${expected_output}" ' failed.'
        return 1
    fi
}

function Unit_Test__utility-strip-ANSI-codes()
{
    local input output expected_output
    input=$(printf '\e[1mBold\e[22m text\e[0m')
    expected_output='Bold text'
    __static__Test_ANSI_Code_Removal || return 1
    input=$(printf '\e[1;96mBold color text\e[0m')
    expected_output='Bold color text'
    __static__Test_ANSI_Code_Removal || return 1
    input=$(printf '\e[38;5;202mComplex color text\e[0m')
    expected_output='Complex color text'
    __static__Test_ANSI_Code_Removal || return 1
    input=$(printf '\e[1;38;5;202mComplex bold-color text\e[0m')
    expected_output='Complex bold-color text'
    __static__Test_ANSI_Code_Removal || return 1
}
