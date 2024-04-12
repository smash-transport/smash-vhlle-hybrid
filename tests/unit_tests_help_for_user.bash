#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__give-requested-help()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'command_line_parsers/allowed_options.bash'
        'command_line_parsers/helper.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    HYBRID_configuration_file='./config.yaml'
    HYBRID_output_directory='.'
    HYBRID_run_id='Cool_run'
}

function __static__Run_Helper_Expecting_Success()
{
    Call_Codebase_Function_In_Subshell Give_Required_Help
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
