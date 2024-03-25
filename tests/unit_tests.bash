#===================================================
#
#    Copyright (c) 2023-2024
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
        # The following global variable is needed when defining the software global variables
        # and since it is likely that most unit tests need it, let's always define it
        readonly HYBRID_top_level_path="${HYBRIDT_repository_top_level_path}"
        # Write header to the log file to give some structure to it
        printf "\n[$(date)]\nRunning unit test \"%s\"\n\n" "${test_name}"
        mkdir "$1" || exit ${HYBRID_fatal_builtin}
        cd "$1" || exit ${HYBRID_fatal_builtin}
        Call_Function_If_Existing_Or_No_Op ${FUNCNAME}__$1
    } &>> "${HYBRIDT_log_file}" 9>&1 # The fd 9 is used by the logger
}

function Run_Test()
{
    Unit_Test__$1 &>> "${HYBRIDT_log_file}" 9>&1 # The fd 9 is used by the logger
}

function Clean_Tests_Environment_For_Following_Test()
{
    # The fd 9 is used by the logger
    Call_Function_If_Existing_Or_No_Op ${FUNCNAME}__$1 &>> "${HYBRIDT_log_file}" 9>&1
}

function Call_Codebase_Function_In_Subshell()
{
    # Calling the codebase function in a subshell is useful to avoid
    # exiting the test if in the codebase function runs an exit command.
    (__static__Call_Codebase_Function_As_Desired "$@")
}

function Call_Codebase_Function()
{
    __static__Call_Codebase_Function_As_Desired "$@"
}

#=======================================================================================================================

# NOTE: In the following, if the codebase function call fails, this function will exit
#       the current shell because of the 'errexit' mode. If this function is called in
#       a subshell, then the main script will continue without the *errexit options set,
#       because these were set in the subshell only. However, if this function is called
#       in the main script shell, then this will exit, too.
#       Why not to ALWAYS call this function in a subshell? Because the codebase function
#       might change some environment property to be tested afterwards and such a change,
#       if done in a subshell, would be lost once the subshell exits.
function __static__Call_Codebase_Function_As_Desired()
{
    # Set stricter bash mode to run codebase code in the mode it is supposed to be run
    set -o errexit
    shopt -s inherit_errexit
    Call_Function_If_Existing_Or_Exit "$@"
    # Switch off errexit bash mode to handle errors in a standard way inspecting $?
    set +o errexit
    shopt -u inherit_errexit
}
