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
    Define_Available_Tests_For 'functional_tests'
}

function Make_Test_Preliminary_Operations()
{
    : # No-op for the moment
}

function Run_Test()
{
    local test_name=$1
    return 0 # Success by definition for the moment
}

function Clean_Tests_Environment_For_Following_Test()
{
    : # No-op for the moment
}
