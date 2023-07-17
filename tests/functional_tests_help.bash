#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: These functional tests just require code to run and finish with zero exit code.

function Functional_Test__help-general()
{
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'help'
}

function Functional_Test__help-do()
{
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '--help'
}
