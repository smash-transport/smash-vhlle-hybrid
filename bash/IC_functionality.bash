#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_IC()
{
    Create_Output_Directory_For 'IC'
    Ensure_Given_Files_Do_Not_Exist "${HYBRID_software_configuration_file[IC]}"
    Ensure_Given_Files_Exist "${HYBRID_software_base_config_file[IC]}"
    Copy_Base_Configuration_To_Output_Folder_For 'IC'
    Replace_Keys_In_Configuration_File_If_Needed_For 'IC'
}

function Ensure_All_Needed_Input_Exists_IC()
{
    Ensure_Given_Folders_Exist "${HYBRID_software_output_directory[IC]}"
    Ensure_Given_Files_Exist "${HYBRID_software_configuration_file[IC]}"
}

function Ensure_Run_Reproducibility_IC()
{
    Copy_Hybrid_Handler_Config_Section 'IC' \
        "${HYBRID_software_output_directory[IC]}" \
        "$(dirname "$(realpath "${HYBRID_software_executable[IC]}")")"
}

function Run_Software_IC()
{
    cd "${HYBRID_software_output_directory[IC]}"
    local ic_terminal_output="${HYBRID_software_output_directory[IC]}/Terminal_Output.txt"
    "${HYBRID_software_executable[IC]}" \
        '-i' "${HYBRID_software_configuration_file[IC]}" \
        '-o' "${HYBRID_software_output_directory[IC]}" \
        '-n' \
        >> "${ic_terminal_output}"
}

Make_Functions_Defined_In_This_File_Readonly
