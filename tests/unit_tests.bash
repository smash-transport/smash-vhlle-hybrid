#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Unit_Test__define-global-variables()
{
    Define_Further_Global_Variables
}

#=======================================================================================================================

function Define_Available_Tests()
{
    HYBRIDT_tests_to_be_run=(
        'define-global-variables'
    )
}

function Make_Test_Preliminary_Operations()
{
    case "$1" in
        define-global-variables )
            source "${HYBRIDT_repository_top_level_path}"/bash/global_variables.bash || exit "${HYBRID_fatal_builtin}"
            ;;
        * )
            ;;
    esac
}

function Run_Test()
{
    local test_name=$1
    {
        printf "\n[$(date)]\nRunning test \"%s\"\n\n" "${test_name}"
        Unit_Test__${test_name}
    } &>> "${HYBRIDT_log_file}"
}

function Clean_Tests_Environment_For_Following_Test()
{
    : # No-op for the moment
}

#=======================================================================================================================
