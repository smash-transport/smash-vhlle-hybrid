#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Define_Available_Tests()
{
    Define_Available_Tests_For 'unit_tests'
}

function Make_Test_Preliminary_Operations()
{
    local test_name=$1
    {
        # The following global variable is needed whe defining the software global variables
        # and since it is likely that most unit tests need it, let's always define it
        readonly HYBRID_top_level_path="${HYBRIDT_repository_top_level_path}"
        # Write header to the log file to give some structure to it
        printf "\n[$(date)]\nRunning test \"%s\"\n\n" "${test_name}"
        Call_Function_If_Existing_Or_No_Op ${FUNCNAME}__$1
    } &>> "${HYBRIDT_log_file}" 9>&1 # The fd 9 is used by the logger
}

function Run_Test()
{
    Unit_Test__$1 &>> "${HYBRIDT_log_file}" 9>&1  # The fd 9 is used by the logger
}

function Clean_Tests_Environment_For_Following_Test()
{
    # The fd 9 is used by the logger
    Call_Function_If_Existing_Or_No_Op ${FUNCNAME}__$1 &>> "${HYBRIDT_log_file}" 9>&1
}

function Call_Codebase_Function_In_Subshell()
{
    __static__Call_Codebase_Function_As_Desired 'IN_SUBSHELL' "$@"
}

function Call_Codebase_Function()
{
    __static__Call_Codebase_Function_As_Desired "$@"
}

#=======================================================================================================================

function __static__Call_Codebase_Function_As_Desired()
{
    # Set stricter bash mode to run codebase code in the mode it is supposed to be run
    set -o errexit
    shopt -s inherit_errexit
    # NOTE: Call the codebase function in subshell to avoid exiting the test if in the
    #       codebase function runs an exit command.
    local return_code=0
    if [[ ${1-} = 'IN_SUBSHELL' ]]; then
        ( Call_Function_If_Existing_Or_Exit "${@:2}" ) || return_code=$?
    else
        Call_Function_If_Existing_Or_Exit "$@" || return_code=$?
    fi
    # Switch off errexit bash mode to handle errors in a standard way inspecting $?
    set +o errexit
    shopt -u inherit_errexit
    return ${return_code}
}
