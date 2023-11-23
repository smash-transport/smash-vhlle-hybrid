#===================================================
#
#    Copyright (c) 2023
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

Make_Functions_Defined_In_This_File_Readonly
