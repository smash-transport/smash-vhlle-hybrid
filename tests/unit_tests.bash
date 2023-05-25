#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Unit_Test__configuration-validate-1()
{
    false
}

function Unit_Test__configuration-validate-2()
{
    false
}

function Unit_Test__parse-command-line-options()
{
    false
}

function Unit_Test__parse-execution-mode()
{
    false
}

function Unit_Test__system-requirements()
{
    false
}

function Unit_Test__version()
{
    false
}

#=======================================================================================================================

function Define_Available_Tests()
{
    # Available tests are based on functions in this file whose names begins with "Unit_Test__"
    HYBRIDT_tests_to_be_run=(
        # Here word splitting can split names, no space allowed in function name!
        $(grep -E '^function[[:space:]]+Unit_Test__[-[:alnum:]_:]+\(\)[[:space:]]*$' "${BASH_SOURCE[0]}" |\
           sed -E 's/^function[[:space:]]+Unit_Test__([^(]+)\(\)[[:space:]]*$/\1/')
    )
}

function Make_Test_Preliminary_Operations()
{
    case "$1" in
        define-global-variables )
            source "${HYBRIDT_repository_top_level_path}"/bash/global_variables.bash || exit "${HYBRID_fatal_builtin}"
            ;;
        parse-* )
            source "${HYBRIDT_repository_top_level_path}"/bash/command_line_parsers/main_parser.bash || exit "${HYBRID_fatal_builtin}"
            ;;
        handler-help )
            source "${HYBRIDT_repository_top_level_path}"/bash/command_line_parsers/helper.bash || exit "${HYBRID_fatal_builtin}"
            ;;
        version )
            source "${HYBRIDT_repository_top_level_path}"/bash/version.bash || exit "${HYBRID_fatal_builtin}"
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
