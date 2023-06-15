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
        help | --help )
            HYBRID_execution_mode='help'
            ;;
        version | --version )
            HYBRID_execution_mode='version'
            ;;
        do )
            HYBRID_execution_mode='do'
            ;;
        * )
            exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit\
                  "Specified mode '$1' not valid! Run 'Hybrid-handler help' to get further information."
    esac
    shift
    # Update the global array with remaining options to be parsed
    HYBRID_command_line_options_to_parse=( "$@" )
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
    Print_Not_Implemented_Function_Error
    return 1
}
