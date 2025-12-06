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
    if ! hash shfmt &> /dev/null; then
        Print_Error \
            'Command ' --emph 'shfmt' ' not available.' \
            'Please install it (https://github.com/mvdan/sh#shfmt).\n'
        bash_formatter_found='FALSE'
    fi
    if ! hash autopep8 &> /dev/null; then
        Print_Error \
            'Command ' --emph 'autopep8' ' not available.' \
            'Please install it (https://pypi.org/project/autopep8).\n'
        python_formatter_found='FALSE'
    fi
    if [[ "${bash_formatter_found}" = 'TRUE' ]] && [[ "${python_formatter_found}" = 'TRUE' ]]; then
        Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_top_level_path
        shfmt -w -ln bash -i 4 -bn -ci -sr -fn "${HYBRID_top_level_path}"
        local list_of_python_files=(
            "${HYBRID_python_folder}/"*.py
            "${HYBRID_top_level_path}/tests/"**/*.py
        )
        for file in ${list_of_python_files[@]}; do
            # Ignoring rule E26, i.e. not enforcing a single whitespace after the # of inline comments
            autopep8 --ignore "E26" -i "${file}"
        done
    else
        Print_Fatal_And_Exit 'Unable to format the codebase. ' \
            'Please install the missing requirements and run the formatting again.'
    fi
}

function Run_Formatting_Unit_Tests()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_top_level_path
    source "${HYBRID_top_level_path}/tests/unit_tests_formatting.bash" || exit ${HYBRID_fatal_builtin}
    # The following variable definition is just a patch to be able to reuse the test code from here
    HYBRIDT_repository_top_level_path="${HYBRID_top_level_path}"
    local bash_format_correct='FALSE'
    local python_format_correct='FALSE'
    if Unit_Test__codebase-formatting-Bash; then
        bash_format_correct='TRUE'
    else
        printf '\n'
    fi
    if Unit_Test__codebase-formatting-Python; then
        python_format_correct='TRUE'
    fi
    if [[ "${bash_format_correct}" = 'TRUE' ]] && [[ "${python_format_correct}" = 'TRUE' ]]; then
        Print_Info 'The codebase was correctly formatted and the formatting tests pass.'
    fi
}

Make_Functions_Defined_In_This_File_Readonly
