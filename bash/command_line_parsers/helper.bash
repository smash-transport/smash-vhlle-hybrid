#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Give_Required_Help()
{
    case "${HYBRID_execution_mode}" in
        help)
            __static__Print_Main_Help_Message
            ;;
        do-help | prepare-scan-help)
            _HYBRID_Declare_Allowed_Command_Line_Options
            __static__Print_Help_Message_For_Given_Mode "${HYBRID_execution_mode%%-help}"
            ;;
        *)
            Print_Internal_And_Exit \
                'Unexpected value of ' --emph "HYBRID_execution_mode=${HYBRID_execution_mode}" \
                ' in ' --emph "${FUNCNAME}"
            ;;
    esac

}

function __static__Print_Main_Help_Message()
{
    # NOTE: This function is thought to be run in ANY user system and it might be
    #       that handler prerequisites are missing. Hence, possibly only bash should be used.
    declare -A section_headers auxiliary_modes_description execution_modes_description
    section_headers=(
        ['auxiliary_modes_description']='Auxiliary modes for help, information or setup'
        ['execution_modes_description']='Prepare needed files and folders and/or submit/run new simulation(s)'
    )
    auxiliary_modes_description=(
        ['help']='Display this help message'
        ['version']='Get information about the version in use'
    )
    execution_modes_description=(
        ['do']='Do everything is necessary to run the workflow given in the configuration file'
        ['prepare-scan']='Prepare configurations files for the handler scanning in the given parameters'
    )
    __static__Print_Handler_Header_And_Usage_Synopsis
    __static__Print_Modes_Description
    Check_System_Requirements_And_Make_Report
}

function __static__Print_Help_Message_For_Given_Mode()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_allowed_command_line_options
    local -r mode="$1"
    __static__Print_Help_Header_For_Given_Mode_Help "${mode}"
    local option
    # Let word splitting split allowed command line options
    for option in ${HYBRID_allowed_command_line_options["${mode}"]}; do
        __static__Print_Given_Command_Line_Option_Help "${option}"
    done
}

function __static__Print_Handler_Header_And_Usage_Synopsis()
{
    printf '\e[96m%s\e[0m\n' \
        ' #----------------------------------------------------------------------------#' \
        ' #     __  __      __         _     __   __  __                ____           #' \
        ' #    / / / /_  __/ /_  _____(_)___/ /  / / / /___ _____  ____/ / /__  _____  #' \
        ' #   / /_/ / / / / __ \/ ___/ / __  /  / /_/ / __ `/ __ \/ __  / / _ \/ ___/  #' \
        ' #  / __  / /_/ / /_/ / /  / / /_/ /  / __  / /_/ / / / / /_/ / /  __/ /      #' \
        ' # /_/ /_/\__, /_.___/_/  /_/\__,_/  /_/ /_/\__,_/_/ /_/\__,_/_/\___/_/       #' \
        ' #       /____/                                                               #' \
        ' #                                                                            #' \
        ' #----------------------------------------------------------------------------#'
    printf '\n'
    printf '\e[38;5;85m%s\e[0m\n' \
        '           USAGE:   Hybrid-handler [--help] [--version]' \
        '                                   <execution-mode> [<options>...]'
    printf '\n'
}

function __static__Print_Modes_Description()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty section_headers "${!section_headers[@]}"
    local section mode section_string
    printf '\e[38;5;38m  %s\e[0m\n' \
        'Here in the following you find an overview of the existing execution modes.'
    for section in "${!section_headers[@]}"; do
        printf "\n  \e[93m${section_headers[${section}]}\e[0m\n"
        declare -n list_of_modes="${section}"
        section_string=''
        for mode in "${!list_of_modes[@]}"; do
            # Remember that $(...) strip trailing '\n' -> Add new-line manually to the string
            section_string+="$(
                printf \
                    '\e[38;5;85m%15s   \e[96m%s\e[0m' \
                    "${mode}" \
                    "${list_of_modes[${mode}]}"
            )"$'\n'
        done
        if hash sort &> /dev/null; then
            # Remember that the 'here-string' adds a newline to the string when
            # feeding it into the command -> get rid of it here
            sort --ignore-leading-blanks <<< "${section_string%?}"
        else
            printf "%s" "${section_string}"
        fi
    done
    printf '\n\e[38;5;38m  %s \e[38;5;85m%s \e[38;5;38m%s\e[0m\n\n' \
        'Use' '--help' 'after each non auxiliary mode to get further information about it.'
}

function __static__Print_Help_Header_For_Given_Mode_Help()
{
    printf '\e[38;5;38m  %s \e[38;5;85m%s \e[38;5;38m%s\e[0m\n' \
        'You can specify the following command line options to the' "$1" 'execution mode:'
}

function __static__Print_Given_Command_Line_Option_Help()
{
    case "$1" in
        --output-directory)
            __static__Print_Command_Line_Option_Help \
                '-o | --output-directory' "${HYBRID_output_directory/${PWD}/.}" \
                'Directory where the output folder(s) will be created.'
            ;;
        --configuration-file)
            __static__Print_Command_Line_Option_Help \
                '-c | --configuration-file' "${HYBRID_configuration_file}" \
                'YAML configuration file to be used by the handler.'
            ;;
        --scan-name)
            __static__Print_Command_Line_Option_Help \
                '-s | --scan-name' "./$(realpath -m --relative-to=. "${HYBRID_scan_directory}")" \
                'Label of the scan used by the handler to produce output.' \
                'The new configuration files will be put in a sub-folder' \
                'of the output directory named using the specified name' \
                'and the configuration files themselves will contain the' \
                'scan name as part of their name.'
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown option ' --emph "$1" ' passed to ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}

function __static__Print_Command_Line_Option_Help()
{
    local -r \
        length_option=30 indentation='    ' \
        column_sep='  ' \
        options_color='\e[38;5;85m' \
        text_color='\e[96m' \
        default_value_color='\e[93m' \
        default_text='\e[0m'
    local name default_value description left_column left_column_length
    name=$1
    default_value=$2
    description=$3
    shift 3
    printf -v left_column "${indentation}${options_color}%*s${column_sep}" ${length_option} "${name}"
    left_column_length=$((${#indentation} + ${length_option} + ${#column_sep}))
    printf "\n${left_column}${text_color}%s${default_text}\n" "${description}"
    while [[ $# -gt 0 ]]; do
        printf "%${left_column_length}s${text_color}%s${default_text}\n" '' "$1"
        shift
    done
    printf "%${left_column_length}sDefault: ${default_value_color}${default_value}${default_text}\n" ''
}

Make_Functions_Defined_In_This_File_Readonly
