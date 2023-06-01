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
    ( Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' 'b' 'c' &> /dev/null )
    if [[ $? -ne 0 ]] ; then
        Print_Error "Existing key '{a: {b: {c:}}}' not found."
        return 1
    fi
    ( Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' 'b' &> /dev/null )
    if [[ $? -ne 0 ]] ; then
        Print_Error "Existing key '{a: {b:}}' not found."
        return 1
    fi
    ( Has_YAML_String_Given_Key $'a:\n  b:\n    c: 42\n' 'a' &> /dev/null )
    if [[ $? -ne 0 ]] ; then
        Print_Error "Existing key '{a:}' not found."
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
        Print_Error "File \"${file_containing_one_commented_line_only}\" not empty."
        return 1
    fi
    rm "${file_containing_one_commented_line_only}"
    # Test case 2
    local -r file_containing_no_comments=${FUNCNAME}_2.txt
    printf $'No comment\nin any\nline\n' > "${file_containing_no_comments}"
    number_of_lines=$(wc -l < "${file_containing_no_comments}")
    Remove_Comments_In_File "${file_containing_no_comments}"
    if [[ $(wc -l < "${file_containing_no_comments}") -ne ${number_of_lines} ]]; then
        Print_Error "Removing comments in \"${file_containing_no_comments}\" file failed."
        return 1
    fi
    rm "${file_containing_no_comments}"
    # Test case 3
    local -r file_containing_three_commented_lines=${FUNCNAME}_3.txt
    printf $'Some\n #comment\ntext\n#comment\namong\n#comment\ncomments\n' > "${file_containing_three_commented_lines}"
    number_of_lines=$(wc -l < "${file_containing_three_commented_lines}")
    Remove_Comments_In_File "${file_containing_three_commented_lines}"
    if (( $(wc -l < "${file_containing_three_commented_lines}") != number_of_lines - 3 )); then
        Print_Error "Removing comments in \"${file_containing_three_commented_lines}\" file failed."
        return 1
    fi
    rm "${file_containing_three_commented_lines}"
    # Test case 4
    local -r file_containing_one_line_with_an_inline_comment=${FUNCNAME}_4.txt
    printf 'Hello   %% Comment\n' > "${file_containing_one_line_with_an_inline_comment}"
    Remove_Comments_In_File "${file_containing_one_line_with_an_inline_comment}" '%'
    if [[ $(cat "${file_containing_one_line_with_an_inline_comment}") != 'Hello' ]]; then
        Print_Error "Removing comments in \"${file_containing_one_line_with_an_inline_comment}\" file failed."
        return 1
    fi
    rm "${file_containing_one_line_with_an_inline_comment}"
}
