#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File()
{
    Call_Function_If_Existing_Or_Exit ${FUNCNAME}_$1 "${@:2}"
}

function Ensure_All_Needed_Input_Exists()
{
    Call_Function_If_Existing_Or_Exit ${FUNCNAME}_$1 "${@:2}"
}

function Ensure_Run_Reproducibility()
{
    Call_Function_If_Existing_Or_Exit ${FUNCNAME}_$1 "${@:2}"
}

function Run_Software()
{
    Call_Function_If_Existing_Or_Exit ${FUNCNAME}_$1 "${@:2}"
}

Make_Functions_Defined_In_This_File_Readonly
