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
    HYBRIDT_tests_to_be_run=(
        'help-'{1..3}
        'version-'{1,2}
    )
}

function Make_Test_Preliminary_Operations()
{
    : # No-op for the moment
}

function Run_Test()
{
    local test_name=$1
    false # Fail by definition for the moment
}

function Clean_Tests_Environment_For_Following_Test()
{
    : # No-op for the moment
}
