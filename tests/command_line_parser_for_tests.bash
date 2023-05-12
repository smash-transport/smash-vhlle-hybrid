#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Parse_Command_Line_Options()
{
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help )
                __static__Print_Helper
                exit ${HYBRID_success_exit_code}
                shift ;;
            -r | --report-level )
                if [[ $2 =~ ^[0-3]$ ]]; then
                    readonly HYBRIDT_report_level=$2
                else
                    __static__Print_Option_Specification_Error_And_Exit $1
                fi
                shift 2 ;;
            -t | --run-tests )
                if [[ ! $2 =~ ^- && "$2" != '' ]]; then
                    if [[ $2 =~ ^[1-9][0-9]*([,\-][1-9][0-9]*)*$ ]]; then
                        exit_code=${HYBRID_fatal_missing_feature} Print_Fatal_And_Exit "-t num option not yet implemented!"
                    elif [[ $2 =~ ^[[:alpha:]*] ]]; then
                        exit_code=${HYBRID_fatal_missing_feature} Print_Fatal_And_Exit "-t str option not yet implemented!"
                    else
                        __static__Print_Option_Specification_Error_And_Exit $2
                    fi
                else
                    __static__Print_List_Of_Tests
                    exit ${HYBRID_success_exit_code}
                fi
                shift 2 ;;
            -k | --keep-tests-folder )
                HYBRIDT_clean_test_folder='FALSE'
                shift ;;
            * )
                exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit\
                    "Invalid option \"$1\" specified! Use the \"--help\" option to get further information."
                ;;
        esac
    done
}

function __static__Print_Helper()
{
    local helper_color normal_color default
    helper_color='\e[92m'
    normal_color='\e[96m'
    default_color='\e[0m'
    printf "\n${helper_color} Execute tests with the following optional arguments:${default_color}\n\n"
    __static__Add_Option_To_Helper "-r | --report-level"\
                                   "Verbosity of test report (default value ${HYBRIDT_report_level})."\
                                   "To be chosen among"\
                                   "  0 = binary, 1 = summary, 2 = short, 3 = detailed."
    __static__Add_Option_To_Helper "-t | --run-tests"\
                                   "Specify which tests have to be run. A comma-separated"\
                                   "list of numbers and/or of intervals (e.g. 1,3-5) or"\
                                   "a string (e.g. 'help*') has to be specified. The string"\
                                   "is matched against test names using bash regular globbing."\
                                   "If no value is specified the available tests list is printed."\
                                   "Without this option all existing tests are run."
    __static__Add_Option_To_Helper "-k | --keep-tests-folder"\
                                   "Leave all the created folders and files in the test folder."
    Print_Warning\
        " Values from options must be separated by space and short options cannot be combined.\n"
}

function __static__Add_Option_To_Helper()
{
    local name description length_option indentation
    length_option=24
    indentation='    '
    name="$1"
    description="$2"
    shift 2
    printf "${normal_color}%s${default_color}   ->  ${helper_color}%s\n"\
           "$(printf "%s%-${length_option}s" "${indentation}" "${name}")"\
           "${description}"
    while [[ $# -gt 0 ]]; do
        printf "%s       %s\n"\
               "$(printf "%s%${length_option}s" "${indentation}" "")"\
               "$1"
        shift
    done
    printf "${default_color}\n"
}

function __static__Print_List_Of_Tests()
{
    exit_code=${HYBRID_fatal_missing_feature} Print_Fatal_And_Exit "${FUNCNAME} option not yet implemented!"
}

function __static__Print_Option_Specification_Error_And_Exit()
{
    exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit\
        "The value of the option \"$1\" was not correctly specified"\
        " (either forgotten or invalid)!"
}


Make_Functions_Defined_In_This_File_Readonly
