#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: No need to source utility functions code, as the test runner uses them!

function Unit_Test__utility-has-YAML-string-given-key()
{
    Call_Codebase_Function_In_Subshell Has_YAML_String_Given_Key &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Wrong call to function succeeded."
        return 1
    fi
    Call_Codebase_Function_In_Subshell Has_YAML_String_Given_Key $'Scalar\nKey: Value\n' 'Key' &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Function called on invalid YAML succeeded."
        return 1
    fi
    Call_Codebase_Function_In_Subshell Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a.b' 'c' &> /dev/null
    if [[ $? -ne 0 ]]; then
        Print_Error 'Existing key ' --emph '{a: {b: {c:}}}' ' not found.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a.b' &> /dev/null
    if [[ $? -ne 0 ]]; then
        Print_Error 'Existing key ' --emph '{a: {b:}}' ' not found.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' &> /dev/null
    if [[ $? -ne 0 ]]; then
        Print_Error 'Existing key ' --emph '{a:}' ' not found.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a.b.nope' &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Not existing key found."
        return 1
    fi
}

function Unit_Test__utility-read-from-YAML-string-given-key()
{
    Call_Codebase_Function_In_Subshell Read_From_YAML_String_Given_Key &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Wrong call to function succeeded."
        return 1
    fi
    Call_Codebase_Function_In_Subshell Read_From_YAML_String_Given_Key $'Scalar\nKey: Value\n' 'Key' &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Function called on invalid YAML succeeded."
        return 1
    fi
    Call_Codebase_Function_In_Subshell Read_From_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'nope' &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Not existing key successfully read."
        return 1
    fi
    local result
    result=$(Call_Codebase_Function Read_From_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a.b' 'c')
    if [[ ${result} -ne 42 ]]; then
        Print_Error "Reading scalar key failed."
        return 1
    fi
    result=$(Call_Codebase_Function Read_From_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a.b')
    if [[ "${result}" != 'c: 42' ]]; then
        Print_Error "Reading map key failed."
        return 1
    fi
}

function Unit_Test__utility-print-YAML-string-without-given-key()
{
    Call_Codebase_Function_In_Subshell Print_YAML_String_Without_Given_Key &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Wrong call to function succeeded."
        return 1
    fi
    Call_Codebase_Function_In_Subshell Print_YAML_String_Without_Given_Key $'Scalar\nKey: Value\n' 'Key' &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Function called on invalid YAML succeeded."
        return 1
    fi
    Call_Codebase_Function_In_Subshell Print_YAML_String_Without_Given_Key $'a:\n  b: 42\n' 'nope' &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Not existing key successfully deleted."
        return 1
    fi
    local result
    result=$(Call_Codebase_Function Print_YAML_String_Without_Given_Key $'a: 42\nb: 17\n' 'b')
    if [[ "${result}" != 'a: 42' ]]; then
        Print_Error "Deleting scalar key failed."
        return 1
    fi
    result=$(Call_Codebase_Function Print_YAML_String_Without_Given_Key $'a:\n  b:\n    c: 17\n' 'a.b')
    if [[ "${result}" != 'a: {}' ]]; then
        Print_Error "Deleting map key failed."
        return 1
    fi
    result=$(Call_Codebase_Function Print_YAML_String_Without_Given_Key $'a: 42\n' 'a')
    if [[ "${result}" != '{}' ]]; then
        Print_Error "Deleting only existing key failed."
        return 1
    fi
}

function Unit_Test__utility-remove-comments-in-existing-file()
{
    local number_of_lines
    cd "${HYBRIDT_folder_to_run_tests}"
    # Test case 0
    Call_Codebase_Function_In_Subshell Remove_Comments_In_Existing_File 'not_existing_file.txt' &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Remove comments on not existent file did not fail."
        return 1
    fi
    # Test case 1
    local -r file_containing_one_commented_line_only=${FUNCNAME}_1.txt
    printf '   # Comment\n' > "${file_containing_one_commented_line_only}"
    Call_Codebase_Function_In_Subshell Remove_Comments_In_File "${file_containing_one_commented_line_only}"
    if [[ -s "${file_containing_one_commented_line_only}" ]]; then
        Print_Error 'File ' --emph "${file_containing_one_commented_line_only}" ' not empty.'
        return 1
    fi
    rm "${file_containing_one_commented_line_only}"
    # Test case 2
    local -r file_containing_no_comments=${FUNCNAME}_2.txt
    printf $'No comment\nin any\nline\n' > "${file_containing_no_comments}"
    number_of_lines=$(wc -l < "${file_containing_no_comments}")
    Call_Codebase_Function_In_Subshell Remove_Comments_In_File "${file_containing_no_comments}"
    if [[ $(wc -l < "${file_containing_no_comments}") -ne ${number_of_lines} ]]; then
        Print_Error 'Removing comments in ' --emph "${file_containing_no_comments}" ' file failed.'
        return 1
    fi
    rm "${file_containing_no_comments}"
    # Test case 3
    local -r file_containing_three_commented_lines=${FUNCNAME}_3.txt
    printf $'Some\n #comment\ntext\n#comment\namong\n#comment\ncomments\n' > "${file_containing_three_commented_lines}"
    number_of_lines=$(wc -l < "${file_containing_three_commented_lines}")
    Call_Codebase_Function_In_Subshell Remove_Comments_In_File "${file_containing_three_commented_lines}"
    if (($(wc -l < "${file_containing_three_commented_lines}") != number_of_lines - 3)); then
        Print_Error 'Removing comments in ' --emph "${file_containing_three_commented_lines}" ' file failed.'
        return 1
    fi
    rm "${file_containing_three_commented_lines}"
    # Test case 4
    local -r file_containing_one_line_with_an_inline_comment=${FUNCNAME}_4.txt
    printf 'Hello   %% Comment\n' > "${file_containing_one_line_with_an_inline_comment}"
    Call_Codebase_Function_In_Subshell Remove_Comments_In_File "${file_containing_one_line_with_an_inline_comment}" '%'
    if [[ $(< "${file_containing_one_line_with_an_inline_comment}") != 'Hello' ]]; then
        Print_Error 'Removing comments in ' --emph "${file_containing_one_line_with_an_inline_comment}" ' file failed.'
        return 1
    fi
    rm "${file_containing_one_line_with_an_inline_comment}"
}

function Unit_Test__utility-check-shell-variables-set()
{
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set foo &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking unset variable succeeded.'
        return 1
    fi
    local foo
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set foo &> /dev/null
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set but unassigned variable failed.'
        return 1
    fi
    foo=''
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set foo &> /dev/null
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set but empty variable failed.'
        return 1
    fi
    foo='bar'
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set foo
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set and not empty string-variable failed.'
        return 1
    fi
    foo=()
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set foo
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking empty array variable failed.'
        return 1
    fi
    foo=('')
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set foo
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking array variable set to one empty entry failed.'
        return 1
    fi
    declare -A bar=([Hi]='')
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set bar
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking associative array variable set to one empty entry failed.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set bar[Hi]
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking associative array entry set to one empty entry failed.'
        return 1
    fi
}

function Unit_Test__utility-check-shell-variables-set-not-empty()
{
    local foo
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking set but unassigned variable succeeded.'
        return 1
    fi
    foo=''
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking set but empty variable succeeded.'
        return 1
    fi
    foo='bar'
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set and not empty variable failed.'
        return 1
    fi
    foo=()
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking empty array variable succeeded.'
        return 1
    fi
    foo=('')
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty foo
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking array variable set to one empty entry failed.'
        return 1
    fi
    declare -A bar
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty bar &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking set but unassigned associative array succeeded.'
        return 1
    fi
    bar['key']=''
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty bar
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set associative array failed.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty bar[key] &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Checking empty associative array entry succeeded.'
        return 1
    fi
    bar['key']='something'
    Call_Codebase_Function_In_Subshell Ensure_That_Given_Variables_Are_Set_And_Not_Empty bar[key]
    if [[ $? -ne 0 ]]; then
        Print_Error 'Checking set associative array entry failed.'
        return 1
    fi
}

function __static__Test_ANSI_Code_Removal()
{
    Ensure_That_Given_Variables_Are_Set output
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty input expected_output
    output=$(Call_Codebase_Function Strip_ANSI_Color_Codes_From_String "${input}")
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

function Unit_Test__utility-files-existence()
{
    Call_Codebase_Function Ensure_Given_Files_Do_Not_Exist 'aaa' 'not-existing' 'xcafblskdfa'
    Call_Codebase_Function_In_Subshell Ensure_Given_Files_Do_Not_Exist "${BASH_SOURCE[@]}" &> /dev/null
    if [[ $? -ne ${HYBRID_fatal_logic_error} ]]; then
        Print_Error 'Function to ensure non existent files did not fail as expected.'
        return 1
    fi
    ln -s "${BASH_SOURCE[0]}" link_test
    Call_Codebase_Function Ensure_Given_Files_Exist 'link_test'
    Call_Codebase_Function_In_Subshell Ensure_Given_Files_Exist 'not-existing-file' &> /dev/null
    if [[ $? -ne ${HYBRID_fatal_file_not_found} ]]; then
        Print_Error 'Function to ensure existent files did not fail as expected.'
        return 1
    fi
    Call_Codebase_Function Ensure_Given_Folders_Exist "${HOME}"
    Call_Codebase_Function_In_Subshell Ensure_Given_Folders_Exist 'not-existing-folder' &> /dev/null
    if [[ $? -ne ${HYBRID_fatal_file_not_found} ]]; then
        Print_Error 'Function to ensure existent folders did not fail as expected.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Ensure_Given_Folders_Exist 'Add-on' 'test' '--' 'link_test' &> /dev/null
    if [[ $? -ne ${HYBRID_fatal_file_not_found} ]]; then
        Print_Error 'Function to ensure existent folders did not fail as expected on a file.'
        return 1
    fi
    Call_Codebase_Function Ensure_Given_Folders_Do_Not_Exist 'not-existing' 'dfadgdsfs'
    Call_Codebase_Function_In_Subshell Ensure_Given_Folders_Do_Not_Exist "${HOME}" &> /dev/null
    if [[ $? -ne ${HYBRID_fatal_logic_error} ]]; then
        Print_Error 'Function to ensure not existent folders did not fail as expected.'
        return 1
    fi
    Call_Codebase_Function Internally_Ensure_Given_Files_Do_Not_Exist 'aaa' 'not-existing' 'xcafblskdfa'
    Call_Codebase_Function_In_Subshell Internally_Ensure_Given_Files_Do_Not_Exist "${BASH_SOURCE[@]}" &> /dev/null
    if [[ $? -ne ${HYBRID_internal_exit_code} ]]; then
        Print_Error 'Function to internally ensure non existent files did not fail as expected.'
        return 1
    fi
    Call_Codebase_Function Internally_Ensure_Given_Files_Exist 'link_test'
    Call_Codebase_Function_In_Subshell Internally_Ensure_Given_Files_Exist 'not-existing-file' &> /dev/null
    if [[ $? -ne ${HYBRID_internal_exit_code} ]]; then
        Print_Error 'Function to internally ensure existent files did not fail as expected.'
        return 1
    fi
    rm 'link_test'
}

function Unit_Test__utility-compare-versions()
{
    local counter=0 args
    local -r test_cases=(
        '1 = 1'
        '1 -eq 1'
        '2.1 < 2.2.0'
        '2.1 -lt 2.2.0'
        '3.0.4.10 > 3.0.4.2'
        '3.0.4.10 -gt 3.0.4.2'
        '4.08 < 4.08.01'
        '4.08 -lt 4.08.01'
        '42.1.999 < 42.2'
        '3.2 < 3.2.0.0.0.1'
        '1.2 < 2.1'
        '2.1 > 1.2'
        '5.6.7 = 5.6.7'
        '1.01.1 == 1.1.1'
        '1.1.1 = 1.01.1'
        '1 = 1.0'
        '1.0.0 = 001'
        '1.0.2.0 != 1.0.2.01'
        '1.0.2.0 -ne 1.0.2.01'
        '1 >= 1.0'
        '1 -ge 1.0'
        '1 <= 1.0'
        '1 -le 1.0'
    )
    for args in "${test_cases[@]}"; do
        Call_Codebase_Function_In_Subshell Is_Version ${args} # Split args using word splitting!
        if [[ $? -ne 0 ]]; then
            Print_Error 'Versions test ' --emph "${args}" ' unexpectedly failed.'
            ((counter++))
        fi
    done
    return ${counter} # Fine as long as we have less than 256 test clauses! ;)
}
