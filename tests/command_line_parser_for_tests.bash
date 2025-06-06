#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Parse_Tests_Suite_Parameter_And_Source_Specific_Code()
{
    local suite_name code_filename
    suite_name="$1"
    if [[ ! ${suite_name} =~ ^(functional|integration|unit)$ ]]; then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit \
            'Invalid tests type ' --emph "${suite_name:-<no value>}" '. Valid values: ' \
            --emph 'unit' ', ' --emph 'integration' ' or ' --emph 'functional' '.' \
            'Use the ' --emph '--help' ' option to get more information.'
    fi
    code_filename="${HYBRIDT_tests_folder}/${suite_name}_tests.bash"
    if [[ ! -f "${code_filename}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'File ' --emph "${code_filename}" ' not found.'
    else
        source "${code_filename}" || exit ${HYBRID_fatal_builtin}
    fi
    # If existing, source utility functions of given type of tests
    code_filename="${HYBRIDT_tests_folder}/utility_functions_${suite_name}.bash"
    if [[ -f "${code_filename}" ]]; then
        source "${code_filename}" || exit ${HYBRID_fatal_builtin}
    fi
}

function Parse_Tests_Command_Line_Options()
{
    # This function needs the array of tests not sparse => enforce it
    HYBRIDT_tests_to_be_run=("${HYBRIDT_tests_to_be_run[@]}")

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h | --help)
                __static__Print_Helper
                exit 0
                shift
                ;;
            -r | --report-level)
                if [[ ${2-} =~ ^[0-3]$ ]]; then
                    readonly HYBRIDT_report_level=$2
                else
                    Print_Option_Specification_Error_And_Exit "$1"
                fi
                shift 2
                ;;
            -t | --run-tests)
                if [[ ! ${2-} =~ ^- && "${2-}" != '' ]]; then
                    if [[ $2 =~ ^[1-9][0-9]*([,\-][1-9][0-9]*)*$ ]]; then
                        __static__Set_Tests_To_Be_Run_Using_Numbers "$2"
                    elif [[ $2 =~ ^[[:alpha:]*?] ]]; then
                        __static__Set_Tests_To_Be_Run_Using_Globbing "$2"
                    else
                        Print_Option_Specification_Error_And_Exit "$1"
                    fi
                else
                    __static__Print_List_Of_Tests
                    exit 0
                fi
                shift 2
                ;;
            -k | --keep-tests-folder)
                HYBRIDT_clean_test_folder='FALSE'
                shift
                ;;
            *)
                exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit \
                    'Invalid option ' --emph "$1" ' specified! Use the ' \
                    --emph '--help' ' option to get further information.'
                ;;
        esac
    done
}

function __static__Print_Helper()
{
    local text_color options_color default
    text_color='\e[38;5;26m'
    emph_color='\e[93m'
    options_color='\e[96m'
    default_color='\e[0m'
    printf " USAGE: ${options_color}tests_runner <tests_type> [-h|--help] [<options>...]${default_color}\n\n"
    printf " ${emph_color}Name of available types of tests:${default_color}\n\n"
    __static__Add_Option_To_Helper "unit" "Unit tests of the codebase."
    __static__Add_Option_To_Helper "integration" "Integration tests of the codebase."
    __static__Add_Option_To_Helper "functional" "Tests of the handler as whole script."
    printf " ${emph_color}Execute tests with the following optional arguments:${default_color}\n\n"
    __static__Add_Option_To_Helper "-r | --report-level" \
        "Verbosity of test report (default value ${HYBRIDT_report_level})." \
        "To be chosen among" \
        "  0 = binary, 1 = summary, 2 = short, 3 = detailed."
    __static__Add_Option_To_Helper "-t | --run-tests" \
        "Specify which tests have to be run. A comma-separated" \
        "list of numbers and/or of intervals (e.g. 1,3-5) or" \
        "a string (e.g. 'help*') has to be specified. The string" \
        "is matched against test names using bash regular globbing." \
        "Remember to quote the argument to avoid shell expansion." \
        "If no value is specified the available tests list is printed." \
        "Without this option all existing tests are run."
    __static__Add_Option_To_Helper "-k | --keep-tests-folder" \
        "Leave all the created folders and files in the test folder."
    Print_Warning \
        " Values from options must be separated by space and short options cannot be combined."
}

function __static__Add_Option_To_Helper()
{
    local name description length_option indentation
    length_option=24
    indentation='    '
    name="$1"
    description="$2"
    shift 2
    printf "${options_color}%s${default_color}   ->  ${text_color}%s\n" \
        "$(printf "%s%-${length_option}s" "${indentation}" "${name}")" \
        "${description}"
    while [[ $# -gt 0 ]]; do
        printf "%s       %s\n" \
            "$(printf "%s%${length_option}s" "${indentation}" "")" \
            "$1"
        shift
    done
    printf "${default_color}\n"
}

function __static__Set_Tests_To_Be_Run_Using_Numbers()
{
    local selection_string numeric_list number selected_tests
    selection_string=$1
    numeric_list=(
        $(
            awk \
                'BEGIN{RS=","}
                /\-/{split($0, res, "-"); for(i=res[1]; i<=res[2]; i++){printf "%d\n", i}; next}
                {printf "%d\n", $0}' <<< "${selection_string}"
        )
    )
    Print_Debug 'Selected tests indices: ' --emph "( ${numeric_list[*]} )"
    selected_tests=()
    for number in "${numeric_list[@]}"; do
        # The user selects human-friendly numbers (1,2,...), here go back to array indices
        ((number--))
        if [[ ${number} -lt ${#HYBRIDT_tests_to_be_run[@]} ]]; then
            selected_tests+=("${HYBRIDT_tests_to_be_run[number]}")
        else
            exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit \
                'Some specified test number within ' --emph "$1" ' is not valid! Use' \
                'the ' --emph '-t' ' option without value to get a list of available tests.'
        fi
    done
    HYBRIDT_tests_to_be_run=("${selected_tests[@]}")
    Print_Debug 'Selected tests: ' --emph "( ${HYBRIDT_tests_to_be_run[*]} )"
}

function __static__Set_Tests_To_Be_Run_Using_Globbing()
{
    local selection_string test_name selected_tests
    selection_string=$1
    selected_tests=()
    for test_name in "${HYBRIDT_tests_to_be_run[@]}"; do
        # In this if-clause, no quotes must be used -> globbing comparison!
        if [[ ${test_name} = ${selection_string} ]]; then
            selected_tests+=("${test_name}")
        fi
    done
    HYBRIDT_tests_to_be_run=("${selected_tests[@]}")
    if [[ ${#HYBRIDT_tests_to_be_run[@]} -eq 0 ]]; then
        exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit \
            "No test name found matching \"$1\" globbing pattern! Use" \
            "the '-t' option without value to get a list of available tests."
    fi
    Print_Debug 'Selected tests: ' --emph "( ${HYBRIDT_tests_to_be_run[*]} )"
}

function __static__Print_List_Of_Tests()
{
    local index indentation width_of_list
    printf " \e[96mList of available tests:\e[0m\n\n"
    width_of_list=$(($(tput cols) * 4 / 5))
    for ((index = 0; index < ${#HYBRIDT_tests_to_be_run[@]}; index++)); do
        printf '%3d) %s\n' "$((index + 1))" "${HYBRIDT_tests_to_be_run[index]}"
    done | column -c "${width_of_list}"
}

Make_Functions_Defined_In_This_File_Readonly
