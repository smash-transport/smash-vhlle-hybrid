#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: The following unit test checks the system requirements code by defining functions
#       with the same name as the required system commands. This will make bash run these
#       instead of the system ones (remember that functions have higher priority than
#       external commands). As each fake command print the variable ${...version} as version
#       number, it is then possible to mimic a system complying with the requirements and
#       another one violating them. The same is valid for the ${gnu} variable.

function __static__Fake_Command_Version()
{
    if [[ "$3" = "$1" ]]; then
        printf "$2\n" # If version was requested print fake string
    else
        command ${FUNCNAME[1]} "${@:3}" # otherwise run original commands with given arguments
    fi
}

function __static__Inhibit_Commands_Version()
{
    function awk()
    {
        __static__Fake_Command_Version \
            '--version' "${gnu} Awk ${awk_version}, API: 3.0 (${gnu} MPFR 4.1.0, ${gnu} MP 6.2.1)" "$@"
    }
    function git()
    {
        __static__Fake_Command_Version \
            '--version' "git version ${git_version}" "$@"
    }
    function sed()
    {
        __static__Fake_Command_Version \
            '--version' "sed (${gnu} sed) ${sed_version} Packaged by Debian" "$@"
    }
    function tput()
    {
        __static__Fake_Command_Version \
            '-V' "ncurses ${tput_version}" "$@"
    }
    function yq()
    {
        __static__Fake_Command_Version \
            '--version' "yq (https://github.com/mikefarah/yq/) version v${yq_version}" "$@"
    }
}

function Make_Test_Preliminary_Operations__system-requirements()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
}

function Unit_Test__system-requirements()
{
    # This environment variable makes the python check requirement tool mock pip and
    # find only the always required python packages, independently from OS installation.
    # Note that it needs to be set to a value to be visible from the python script.
    export HYBRID_TEST_MODE='set'
    __static__Inhibit_Commands_Version
    local gnu {awk,git,sed,tput,yq}_version
    # Prepare mocked good system
    gnu='GNU'
    awk_version=4.1
    git_version=2.0
    sed_version=4.2.1
    tput_version=5.9
    yq_version=4.24.2
    Call_Codebase_Function_In_Subshell Check_System_Requirements
    if [[ $? -ne 0 ]]; then
        Print_Error "Check system requirements of good system failed."
        return 1
    fi
    Call_Codebase_Function_In_Subshell Check_System_Requirements_And_Make_Report
    if [[ $? -ne 0 ]]; then
        Print_Error "Check system requirements making report of good system failed."
        return 1
    fi
    # Make "missing" python requirement needed changing global variables
    HYBRID_execution_mode='prepare-scan'
    HYBRID_scan_strategy='LHS'
    Call_Codebase_Function_In_Subshell \
        __static__Exit_If_Some_Further_Needed_Python_Requirement_Is_Missing &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Check system requirements of system without needed python succeeded."
        return 1
    fi
    HYBRID_execution_mode='test'
    # Prepare mocked bad system
    gnu='BSD'
    awk_version=4.1.0
    git_version=1.8.3
    sed_version=4.2.0
    tput_version=''
    yq_version=3.9.98
    printf '\n'
    Call_Codebase_Function_In_Subshell Check_System_Requirements &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error "Check system requirements of bad system succeeded."
        return 1
    fi
    printf '\n'
    (
        unset -v 'TERM'
        Call_Codebase_Function_In_Subshell Check_System_Requirements_And_Make_Report
    )
    if [[ $? -ne 0 ]]; then
        Print_Error "Check system requirements making report of bad system failed."
        return 1
    fi
}
