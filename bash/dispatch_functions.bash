#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File()
{
    Print_Info 'Preparing software input file for ' --emph "$1" ' stage'
    Call_Function_If_Existing_Or_Exit ${FUNCNAME}_$1 "${@:2}"
}

function Ensure_All_Needed_Input_Exists()
{
    Print_Info 'Ensuring all needed input for ' --emph "$1" ' stage exists'
    Call_Function_If_Existing_Or_Exit ${FUNCNAME}_$1 "${@:2}"
}

function Ensure_Run_Reproducibility()
{
    Print_Info 'Preparing ' --emph "$1" ' reproducibility metadata'
    Call_Function_If_Existing_Or_Exit ${FUNCNAME}_$1 "${@:2}"
}

function Run_Software()
{
    Print_Info 'Running ' --emph "$1" ' software'
    Call_Function_If_Existing_Or_Exit ${FUNCNAME}_$1 "${@:2}"
}

Make_Functions_Defined_In_This_File_Readonly
