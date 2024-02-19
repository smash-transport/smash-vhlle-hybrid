#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Parse_Execution_Mode()
{
    if [[ "${#HYBRID_command_line_options_to_parse[@]}" -eq 0 ]]; then
        return 0
    fi
    __static__Replace_Short_Options_With_Long_Ones
    # Locally set function arguments to take advantage of shift
    set -- "${HYBRID_command_line_options_to_parse[@]}"
    case "$1" in
        help | --help)
            HYBRID_execution_mode='help'
            ;;
        version | --version)
            HYBRID_execution_mode='version'
            ;;
        format | --format)
            HYBRID_execution_mode='format'
            ;;
        do)
            HYBRID_execution_mode='do'
            ;;
        prepare-scan)
            HYBRID_execution_mode='prepare-scan'
            ;;
        *)
            exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit \
                'Specified mode ' --emph "$1" ' not valid! Run ' \
                --emph 'Hybrid-handler help' ' to get further information.'
            ;;
    esac
    shift
    # Update the global array with remaining options to be parsed
    HYBRID_command_line_options_to_parse=("$@")
    # Ignore any command line option in some specific cases
    if [[ ${HYBRID_execution_mode} =~ ^(help|version)$ ]]; then
        HYBRID_command_line_options_to_parse=()
    elif Element_In_Array_Equals_To '--help' "${HYBRID_command_line_options_to_parse[@]}"; then
        HYBRID_execution_mode+='-help'
        HYBRID_command_line_options_to_parse=()
    fi
}

# NOTE: The strategy of the following function is to
#         1) validate if command-line options are allowed in given mode;
#         2) parse mode-specific options invoking sub-parser;
#         3) parse remaining options (which are in common to two or more modes) all together.
#       Since options are validated, step number 3 simplifies the implementation
#       without the risk of accepting invalid options.
function Parse_Command_Line_Options()
{
    if [[ ! ${HYBRID_execution_mode} =~ ^(do|prepare-scan)$ ]]; then
        Print_Internal_And_Exit \
            'Function ' --emph "${FUNCNAME}" ' should not be called in ' \
            --emph "${HYBRID_execution_mode}" ' execution mode.'
    fi
    __static__Validate_Command_Line_Options
    Call_Function_If_Existing_Or_No_Op Parse_Specific_Mode_Options_${HYBRID_execution_mode}
    set -- "${HYBRID_command_line_options_to_parse[@]}"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --output-directory)
                if [[ ${2-} =~ ^(-|$) ]]; then
                    Print_Option_Specification_Error_And_Exit "$1"
                else
                    if ! realpath "$2" &> /dev/null; then
                        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
                            'Specified output directory ' --emph "$2" ' not found'
                    fi
                    readonly HYBRID_output_directory="$(realpath "$2")"
                    readonly HYBRID_scan_directory="${HYBRID_output_directory}/$(basename "${HYBRID_scan_directory}")"
                fi
                shift 2
                ;;
            --configuration-file)
                if [[ ${2-} =~ ^(-|$) ]]; then
                    Print_Option_Specification_Error_And_Exit "$1"
                else
                    readonly HYBRID_configuration_file="$(realpath "$2")"
                fi
                shift 2
                ;;
            *)
                exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit \
                    'Invalid option ' --emph "$1" ' specified in ' --emph "${HYBRID_execution_mode}" \
                    ' execution mode!' 'Use the ' --emph '--help' ' option to get further information.'
                ;;
        esac
    done
}

function __static__Replace_Short_Options_With_Long_Ones()
{
    declare -A options_map=(
        ['-c']='--configuration-file'
        ['-h']='--help'
        ['-o']='--output-directory'
        ['-s']='--scan-name'
    )
    set -- "${HYBRID_command_line_options_to_parse[@]}"
    HYBRID_command_line_options_to_parse=()
    local option
    for option in "$@"; do
        if Element_In_Array_Equals_To "${option}" "${!options_map[@]}"; then
            option=${options_map["${option}"]}
        fi
        HYBRID_command_line_options_to_parse+=("${option}")
    done
}

function __static__Validate_Command_Line_Options()
{
    _HYBRID_Declare_Allowed_Command_Line_Options
    # Let word splitting split valid options
    local -r valid_options=(${HYBRID_allowed_command_line_options["${HYBRID_execution_mode}"]})
    local option
    for option in "${HYBRID_command_line_options_to_parse[@]}"; do
        if [[ ${option} =~ ^- ]]; then
            if ! Element_In_Array_Equals_To "${option}" "${valid_options[@]}"; then
                exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit \
                    'Option ' --emph "${option}" ' is not allowed in ' --emph "${HYBRID_execution_mode}" \
                    ' execution mode!' 'Use the ' --emph '--help' ' option to get further information.'
            fi
        fi
    done
}

Make_Functions_Defined_In_This_File_Readonly
