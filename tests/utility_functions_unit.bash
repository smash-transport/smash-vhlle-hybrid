#===================================================
#
#    Copyright (c) 2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

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

#===================================================================================================

# NOTE: In the following, if the codebase function call fails, this function will exit
#       the current shell because of the 'errexit' mode. If this function is called in
#       a subshell, then the main script will continue without the errexit options set,
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
