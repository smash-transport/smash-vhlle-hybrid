#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Format_Codebase()
{
    if ! hash shfmt &> /dev/null; then
        Print_Fatal_And_Exit \
            'Command ' --emph 'shfmt' ' not available, unable to format codebase.' \
            'Please, install it (https://github.com/mvdan/sh#shfmt) and run the formatting again.'
    else
        Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_top_level_path
        shfmt -w -ln bash -i 4 -bn -ci -sr -fn "${HYBRID_top_level_path}"
    fi
}

function Run_Formatting_Unit_Test()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_top_level_path
    source "${HYBRID_top_level_path}/tests/unit_tests_formatting.bash" || exit ${HYBRID_fatal_builtin}
    # The following variable definition is just a patch to be able to reuse the test code from here
    HYBRIDT_repository_top_level_path="${HYBRID_top_level_path}"
    if Unit_Test__codebase-formatting; then
        Print_Info 'The codebase was correctly formatted and the formatting test passes.'
    fi
}

Make_Functions_Defined_In_This_File_Readonly
