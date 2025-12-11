#===================================================
#
#    Copyright (c) 2023-2025
#      Hybrid-handler Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Format_Codebase()
{
    local bash_formatter_found='TRUE'
    local python_formatter_found='TRUE'
    local bash_format_succeeded='FALSE'
    local python_format_succeeded='FALSE'
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_top_level_path
    if ! hash shfmt &> /dev/null; then
        Print_Error \
            'Command ' --emph 'shfmt' ' not available. Please install it (https://github.com/mvdan/sh#shfmt)' \
            'to format the ' --emph 'Bash' ' files of the codebase.\n'
        bash_formatter_found='FALSE'
    else
        shfmt -w -ln bash -i 4 -bn -ci -sr -fn "${HYBRID_top_level_path}" &> /dev/null \
            || Print_Internal_And_Exit 'Bash formatter ' --emph 'shfmt' ' unexpectedly failed.'
    fi
    if ! hash autopep8 &> /dev/null; then
        Print_Error \
            'Command ' --emph 'autopep8' ' not available. Please install it (https://pypi.org/project/autopep8)' \
            'to format the ' --emph 'Python' ' files of the codebase.\n'
        python_formatter_found='FALSE'
    else
        # Ignoring rule E265, i.e. not enforcing a single whitespace after the # of block comments
        autopep8 --ignore "E265" --max-line-length 119 -i "${HYBRID_top_level_path}/"{python,tests}/**/*.py \
            &> /dev/null || Print_Internal_And_Exit 'Python formatter ' --emph 'autopep8' ' unexpectedly failed.'
        python_format_succeeded='TRUE'
    fi
    if [[ ${bash_formatter_found} = 'FALSE' ]] && [[ ${python_formatter_found} = 'FALSE' ]]; then
        Print_Fatal_And_Exit 'Unable to format the codebase. Please install the missing requirements ' \
            'and run the formatting again.'
    elif [[ ${bash_formatter_found} = 'TRUE' ]]; then
        # NOTE: The Bash unit test is run since it does an additonal line length check on top of what the formatter
        #       does. The Python unit test will not fail after formatting, so it is redundant to run it.
        if __static__Run_Bash_Formatting_Unit_Test; then
            bash_format_succeeded='TRUE'
        else
            Print_Info -l -- ''
        fi
    fi
    if [[ ${bash_format_succeeded} = 'TRUE' ]] && [[ ${python_format_succeeded} = 'TRUE' ]]; then
        Print_Info 'The codebase was correctly formatted and the ' --emph 'Bash' ' formatting test passes.'
    elif [[ ${bash_format_succeeded} = 'FALSE' ]] && [[ ${python_format_succeeded} = 'TRUE' ]]; then
        Print_Info 'The ' --emph 'Python' ' files of the codebase have been properly formatted.'
    elif [[ ${bash_format_succeeded} = 'TRUE' ]] && [[ ${python_format_succeeded} = 'FALSE' ]]; then
        Print_Info 'The ' --emph 'Bash' ' files of the codebase were correctly formatted and the ' --emph 'Bash' \
            ' formatting test passes.'
    else
        Print_Internal_And_Exit 'The codebase was not correctly formatted.'
    fi
}

function __static__Run_Bash_Formatting_Unit_Test()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_top_level_path
    source "${HYBRID_top_level_path}/tests/unit_tests_formatting.bash" || exit ${HYBRID_fatal_builtin}
    # The following variable definition is just a patch to be able to reuse the test code from here
    HYBRIDT_repository_top_level_path="${HYBRID_top_level_path}"
    if ! Unit_Test__codebase-formatting-Bash; then
        return 1
    fi
}

Make_Functions_Defined_In_This_File_Readonly
