#===================================================
#
#    Copyright (c) 2023-2024
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
    local expected_option=$1 \
        expected_size=$2 \
        first_option="${HYBRID_command_line_options_to_parse[0]-}"
    Call_Codebase_Function Parse_Execution_Mode
    if [[ $? -ne 0 ]] \
        || [[ "${HYBRID_execution_mode}" != "${expected_option}" ]] \
        || [[ ${#HYBRID_command_line_options_to_parse[@]} -ne "${expected_size}" ]]; then
        Print_Error 'Parsing of valid execution mode ' --emph "${first_option}" ' failed.'
        return 1
    fi
)

function Unit_Test__parse-execution-mode()
{
    HYBRID_command_line_options_to_parse=()
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'help' 0 || return 1
    HYBRID_command_line_options_to_parse=('help')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'help' 0 || return 1
    HYBRID_command_line_options_to_parse=('--help')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'help' 0 || return 1
    HYBRID_command_line_options_to_parse=('version')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'version' 0 || return 1
    HYBRID_command_line_options_to_parse=('--version')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'version' 0 || return 1
    HYBRID_command_line_options_to_parse=('help' 'with-invalid' 'irrelevant-options')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'help' 0 || return 1
    HYBRID_command_line_options_to_parse=('version' 'with-invalid' 'irrelevant-options')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'version' 0 || return 1
    HYBRID_command_line_options_to_parse=('do')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'do' 0 || return 1
    HYBRID_command_line_options_to_parse=('do' '-o' '/path/to/folder')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'do' 2 || return 1
    HYBRID_command_line_options_to_parse=('do' '-o' '/path/to/folder' '--help')
    __static__Test_Parsing_Of_Execution_Mode_In_Subshell_Expecting_Success 'do-help' 0 || return 1
    HYBRID_command_line_options_to_parse=('invalid-mode')
    Call_Codebase_Function_In_Subshell Parse_Execution_Mode &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Parsing of invalid execution mode succeeded.'
        return 1
    fi
}

#-------------------------------------------------------------------------------

function Make_Test_Preliminary_Operations__parse-command-line-options()
{
    Make_Test_Preliminary_Operations__parse-execution-mode
}

function __static__Test_CLO_Parsing_Missing_Value()
{
    Call_Codebase_Function_In_Subshell Parse_Command_Line_Options &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Parsing of CLO ' --emph "${HYBRID_command_line_options_to_parse[0]}" \
            ' with missing value succeeded.'
        return 1
    fi
}

function __static__Test_Single_CLO_Parsing_In_Subshell()
(
    Call_Codebase_Function Parse_Command_Line_Options
    if [[ $? -ne 0 ]] || [[ ${!1} != "$2" ]]; then
        Print_Debug --emph "${!1}" ' != ' --emph "$2"
        Print_Error 'Parsing of ' --emph "${HYBRID_command_line_options_to_parse[0]}" ' with valid value failed.'
        return 1
    fi
)

function Unit_Test__parse-command-line-options()
{
    Call_Codebase_Function_In_Subshell Parse_Command_Line_Options &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Parsing of CLO in wrong execution mode succeeded.'
        return 1
    fi
    HYBRID_execution_mode='do'
    HYBRID_command_line_options_to_parse=(--output-directory)
    __static__Test_CLO_Parsing_Missing_Value || return 1
    HYBRID_command_line_options_to_parse=(--configuration-file)
    __static__Test_CLO_Parsing_Missing_Value || return 1
    HYBRID_command_line_options_to_parse=()
    Call_Codebase_Function_In_Subshell Parse_Command_Line_Options
    if [[ $? -ne 0 ]]; then
        Print_Error 'Parsing of CLO with no CLO failed.'
        return 1
    fi
    HYBRID_command_line_options_to_parse=(-o "${HOME}")
    __static__Test_Single_CLO_Parsing_In_Subshell HYBRID_output_directory "${HOME}" || return 1
    HYBRID_command_line_options_to_parse=(-c "${HOME}") # Here it does not matter we use a folder instead of a file
    __static__Test_Single_CLO_Parsing_In_Subshell HYBRID_configuration_file "${HOME}" || return 1
}
