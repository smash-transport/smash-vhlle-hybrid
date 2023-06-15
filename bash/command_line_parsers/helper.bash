#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Give_Required_Help()
{
    case "${HYBRID_execution_mode}" in
        help )
            __static__Print_Main_Help_Message
            ;;
        do-help )
            __static__Print_Do_Help_Message
            ;;
        * )
            Print_Internal_And_Exit\
                'Unexpected value of HYBRID_execution_mode=${HYBRID_execution_mode} in ${FUNCNAME}'
            ;;
    esac

}

function __static__Print_Main_Help_Message()
{
    declare -A section_headers auxiliary_modes_description execution_modes_description
    section_headers=(
        [auxiliary_modes_description]='Auxiliary modes for help, information or setup'
        [execution_modes_description]='Prepare needed files and folders and/or submit/run new simulation(s)'
    )
    auxiliary_modes_description=(
        [help]='Display this help message'
        [version]='Get information about the version in use'
    )
    execution_modes_description=(
        [do]='Do everything is necessary to run the workflow given in the configuration file'
    )
    __static__Print_Handler_Header_And_Usage_Synopsis
    __static__Print_Modes_Description
    Check_System_Requirements_And_Make_Report 2> /dev/null || true
}

function __static__Print_Do_Help_Message()
{
    printf '\e[38;5;38m  %s \e[38;5;85m%s \e[38;5;38m%s\e[0m\n'\
           'You can specify the following command line options to the' 'do' 'execution mode:'
    __static__Print_Command_Line_Option_Help\
        '-o | --output-directory' "${HYBRID_output_directory}"\
        "Directory where the run folder(s) will be created."
    __static__Print_Command_Line_Option_Help\
        '-c | --configuration-file' "${HYBRID_configuration_file}"\
        "YAML configuration file to be used by the handler."
}

function __static__Print_Handler_Header_And_Usage_Synopsis()
{
    printf '\e[96m%s\e[0m\n'\
           ' #----------------------------------------------------------------------------#'\
           ' #     __  __      __         _     __   __  __                ____           #'\
           ' #    / / / /_  __/ /_  _____(_)___/ /  / / / /___ _____  ____/ / /__  _____  #'\
           ' #   / /_/ / / / / __ \/ ___/ / __  /  / /_/ / __ `/ __ \/ __  / / _ \/ ___/  #'\
           ' #  / __  / /_/ / /_/ / /  / / /_/ /  / __  / /_/ / / / / /_/ / /  __/ /      #'\
           ' # /_/ /_/\__, /_.___/_/  /_/\__,_/  /_/ /_/\__,_/_/ /_/\__,_/_/\___/_/       #'\
           ' #       /____/                                                               #'\
           ' #                                                                            #'\
           ' #----------------------------------------------------------------------------#'
    printf '\n'
    printf '\e[38;5;85m%s\e[0m\n'\
           '           USAGE:   Hybrid-handler [--help] [--version]'\
           '                                   <execution-mode> [<options>...]'
    printf '\n'
}

function __static__Print_Modes_Description()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty section_headers "${!section_headers[@]}"
    local section mode
    printf '\e[38;5;38m  %s\e[0m\n\n'\
           'Here in the following you find an overview of the existing execution modes.'
    for section in "${!section_headers[@]}"; do
        printf "\n  \e[93m${section_headers[${section}]}\e[0m\n"
        declare -n list_of_modes="${section}"
        for mode in "${!list_of_modes[@]}"; do
            printf '\e[38;5;85m%15s   \e[96m%s\e[0m\n'\
                   "${mode}"\
                   "${list_of_modes[${mode}]}"
        done | sort --ignore-leading-blanks
    done
    printf '\n\e[38;5;38m  %s \e[38;5;85m%s \e[38;5;38m%s\n\n'\
           'Use' '--help' 'after each non auxiliary mode to get further information about it.'
}

function __static__Print_Command_Line_Option_Help()
{
    local -r length_option=30\
             indentation='    '\
             column_sep='  '\
             options_color='\e[38;5;85m'\
             text_color='\e[96m'\
             default_value_color='\e[93m'\
             default_text='\e[0m'
    local name default_value description left_column left_column_length
    name=$1
    default_value=$2
    description=$3
    shift 3
    printf -v left_column "${indentation}${options_color}%*s${column_sep}" ${length_option} "${name}"
    left_column_length=$(( ${#indentation} + ${length_option} + ${#column_sep} ))
    printf "\n${left_column}${text_color}%s${default_text}\n" "${description}"
    while [[ $# -gt 0 ]]; do
        printf "%${left_column_length}s${text_color}%s${default_text}\n" '' "$1"
        shift
    done
    printf "%${left_column_length}sDefault: ${default_value_color}${default_value}${default_text}\n" ''
}
