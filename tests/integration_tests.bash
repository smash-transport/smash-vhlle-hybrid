#===================================================
#
#    Copyright (c) 2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Define_Available_Tests()
{
    Define_Available_Tests_For 'integration_tests'
}

function Make_Test_Preliminary_Operations()
{
    local test_name=$1
    {
        # The following global variable is needed when defining the software global variables
        # and since it is likely that most integration tests need it, let's always define it
        readonly HYBRID_top_level_path="${HYBRIDT_repository_top_level_path}"
        # Write header to the log file to give some structure to it
        printf "\n[$(date)]\nRunning integration test \"%s\"\n\n" "${test_name}"
        mkdir "$1" || exit ${HYBRID_fatal_builtin}
        cd "$1" || exit ${HYBRID_fatal_builtin}
        Call_Function_If_Existing_Or_No_Op ${FUNCNAME}__$1
    } &>> "${HYBRIDT_log_file}" 9>&1 # The fd 9 is used by the logger
}

function Run_Test()
{
    Integration_Test__$1 &>> "${HYBRIDT_log_file}" 9>&1 # The fd 9 is used by the logger
}

function Clean_Tests_Environment_For_Following_Test()
{
    # The fd 9 is used by the logger
    Call_Function_If_Existing_Or_No_Op ${FUNCNAME}__$1 &>> "${HYBRIDT_log_file}" 9>&1
}
