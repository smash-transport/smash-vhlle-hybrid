#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__parse-execution-mode()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'command_line_parsers/main_parser.bash'
        'global_variables.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success()
(
    local expected_option=$1\
          expected_size=$2\
          first_option="${HYBRID_command_line_options_to_parse[0]}"
    Parse_Execution_Mode
    if [[ $? -ne 0 ]] ||\
       [[ "${HYBRID_execution_mode}" != "${expected_option}" ]] ||\
       [[ ${#HYBRID_command_line_options_to_parse[@]} -ne "${expected_size}" ]]; then
        Print_Error "Parsing of valid execution mode '${first_option}' failed."
        return 1
    fi
)

function Unit_Test__parse-execution-mode()
{
    HYBRID_command_line_options_to_parse=()
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'help' 0 || return 1
    HYBRID_command_line_options_to_parse=( 'help' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'help' 0 || return 1
    HYBRID_command_line_options_to_parse=( '--help' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'help' 0 || return 1
    HYBRID_command_line_options_to_parse=( 'version' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'version' 0 || return 1
    HYBRID_command_line_options_to_parse=( '--version' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'version' 0 || return 1
    HYBRID_command_line_options_to_parse=( 'help' 'with-invalid' 'irrelevant-options' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'help' 0 || return 1
    HYBRID_command_line_options_to_parse=( 'version' 'with-invalid' 'irrelevant-options' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'version' 0 || return 1
    HYBRID_command_line_options_to_parse=( 'do' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'do' 0 || return 1
    HYBRID_command_line_options_to_parse=( 'do' '-o' '/path/to/folder' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'do' 2 || return 1
    HYBRID_command_line_options_to_parse=( 'do' '-o' '/path/to/folder' '--help' )
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'do-help' 0 || return 1
    HYBRID_command_line_options_to_parse=( 'invalid-mode' )
    ( Parse_Execution_Mode )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Parsing of invalid execution mode succeeded.'
        return 1
    fi
}

function Unit_Test__parse-command-line-options()
{
    return 0
}
