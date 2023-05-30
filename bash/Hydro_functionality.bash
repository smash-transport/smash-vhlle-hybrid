#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_Hydro()
{
   # check if output-dir is there and create
    local Hydro_output_directory="${HYBRID_output_directory}/Hydro" # this could also be a global variable
    if [[ ! -d "${Hydro_output_directory}" ]]; then
        mkdir "${Hydro_output_directory}"
    fi
    # check if config already exists in the output directory, exit if yes
    local Hydro_input_file_path="${Hydro_output_directory}/vhlle_config"
    if [[ ! -f "${Hydro_input_file_path}" ]]; then
        cp "${HYBRID_software_base_config_file['Hydro']}" "${Hydro_input_file_path}" || exit ${HYBRID_fatal_builtin}
    else
        exit_code=${HYBRID_fatal_builtin} Print_Fatal_And_Exit\
            "File \"${Hydro_input_file_path}\" is already there."
    fi
    
    # replace all fields with input configs
    Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File\
        'TXT' "${Hydro_input_file_path}" "${HYBRID_software_input['Hydro']}"
}

function Ensure_All_Needed_Input_Exists_Hydro()
{
   #check that input lists exists
   local IC_output_directory="${HYBRID_output_directory}/IC" # this could also be a global variable
    if [[ ! -d "${IC_output_directory}" ]]; then
        mkdir "${IC_output_directory}"
    fi
    # check if input exists
    local IC_output_file_path="${IC_output_directory}/SMASH_IC.dat"
    if [[ ! -f "${IC_output_file_path}" ]]; then
        exit_code=${HYBRID_fatal_builtin} Print_Fatal_And_Exit\
                "File \"${IC_output_file_path}\" is not there."
    fi
        
}

function Run_Software_Hydro()
{
    local Hydro_input_file_path="${Hydro_output_directory}/${HYBRID_software_base_config_file['Hydro']}"
    local IC_output_file_path="${IC_output_directory}/SMASH_IC.dat"
    local Hydro_output_directory="${HYBRID_output_directory}/Hydro"
    ./"${HYBRID_hydro_software_executable}" "-params" "${Hydro_input_file_path}" 
        "-ISinput" "${IC_output_file_path}" 
        "-outputDir" "${Hydro_output_directory}"
            ">" "${Hydro_output_directory}/Terminal_Output.txt"
}


Make_Functions_Defined_In_This_File_Readonly
