#===================================================
#
#    Copyright (c) 2023
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
    #Locally set function arguments to take advantage of shift
    set -- "${HYBRID_command_line_options_to_parse[@]}"
    case "$1" in
        help | --help)
            HYBRID_execution_mode='help'
            ;;
        version | --version)
            HYBRID_execution_mode='version'
            ;;
        do)
            HYBRID_execution_mode='do'
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
    elif  Element_In_Array_Equals_To '--help' "${HYBRID_command_line_options_to_parse[@]}"; then
        HYBRID_execution_mode+='-help'
        HYBRID_command_line_options_to_parse=()
    fi
}

function Parse_Command_Line_Options()
{
    if [[ ${HYBRID_execution_mode} != 'do' ]]; then
        Print_Internal_And_Exit 'Command line options are allowed only in ' --emph 'do' ' mode for now.'
    fi
    set -- "${HYBRID_command_line_options_to_parse[@]}"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o | --output-directory)
                if [[ ${2-} =~ ^(-|$) ]]; then
                    Print_Option_Specification_Error_And_Exit "$1"
                else
                    if ! realpath "$2" &> /dev/null; then
                        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
                            'Specified output directory ' --emph "$2" ' not found'
                    fi
                    readonly HYBRID_output_directory="$(realpath "$2")"
                fi
                shift 2
                ;;
            -c | --configuration-file)
                if [[ ${2-} =~ ^(-|$) ]]; then
                    Print_Option_Specification_Error_And_Exit "$1"
                else
                    readonly HYBRID_configuration_file=$2
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

Make_Functions_Defined_In_This_File_Readonly
