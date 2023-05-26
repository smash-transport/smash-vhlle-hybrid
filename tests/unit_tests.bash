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
    # Source all unit tests files to also deduce existing tests
    local file_to_be_sourced files_to_be_sourced
    files_to_be_sourced=(
        "${HYBRIDT_tests_folder}/"unit_tests_*.bash
    )
    for file_to_be_sourced in "${files_to_be_sourced[@]}"; do
        Print_Debug "Sourcing ${file_to_be_sourced}"
        source "${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    # Available tests are based on functions in this file whose names begins with "Unit_Test__"
    HYBRIDT_tests_to_be_run=(
        # Here word splitting can split names, no space allowed in function name!
        $(grep -hE '^function[[:space:]]+Unit_Test__[-[:alnum:]_:]+\(\)[[:space:]]*$' "${files_to_be_sourced[@]}" |\
           sed -E 's/^function[[:space:]]+Unit_Test__([^(]+)\(\)[[:space:]]*$/\1/')
    )
}

function Make_Test_Preliminary_Operations()
{
    Call_Function_If_Existing_Or_No_Op ${FUNCNAME}__$1
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
    Call_Function_If_Existing_Or_No_Op ${FUNCNAME}__$1
}

#=======================================================================================================================
