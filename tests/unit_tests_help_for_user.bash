#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__give-requested-help()
{
    source "${HYBRIDT_repository_top_level_path}/bash/command_line_parsers/helper.bash" || exit ${HYBRID_fatal_builtin}
    HYBRID_configuration_file='./config.yaml'
    HYBRID_output_directory='.'
}

function __static__Run_Helper_Expecting_Success()
{
    ( Give_Required_Help )
    if [[ $? -ne 0 ]]; then
        Print_Error 'Providing help in ' --emph "${HYBRID_execution_mode}" ' execution mode failed.'
        return 1
    fi
}

function Unit_Test__give-requested-help()
{
    HYBRID_execution_mode='help'
    __static__Run_Helper_Expecting_Success || return 1
    printf '\n'
    HYBRID_execution_mode='do-help'
    __static__Run_Helper_Expecting_Success || return 1
}
