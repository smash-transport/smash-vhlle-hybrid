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
    mkdir -p "${HYBRID_software_output_directory[Hydro]}" || exit ${HYBRID_fatal_builtin}
    if [[ -f "${HYBRID_software_configuration_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
            'Configuration file ' --emph "${HYBRID_software_configuration_file[Hydro]}" ' is already existing.'
    elif [[ ! -f "${HYBRID_software_base_config_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'Base configuration file ' --emph "${HYBRID_software_base_config_file[Hydro]}" ' was not found.'
    fi
    # check if config already exists in the output directory, exit if yes
    local Hydro_input_file_path="${Hydro_output_directory}/vhlle_config"
    if [[ ! -f "${Hydro_input_file_path}" ]]; then
        cp "${HYBRID_software_base_config_file['Hydro']}" "${Hydro_input_file_path}" || exit ${HYBRID_fatal_builtin}
    else
        exit_code=${HYBRID_fatal_builtin} Print_Fatal_And_Exit\
            "File \"${Hydro_input_file_path}\" is already there."
    fi
}

function Ensure_All_Needed_Input_Exists_Hydro()
{
    if [[ ! -d "${HYBRID_software_output_directory[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'Folder ' --emph "${HYBRID_software_output_directory[Hydro]}" ' does not exist.'
    fi
    if [[ ! -f "${HYBRID_software_configuration_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'The configuration file ' --emph "${HYBRID_software_configuration_file[Hydro]}" ' was not found.'
    fi
    if [[ ! -f "${HYBRID_software_input_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'The input file ' --emph "${HYBRID_software_input_file[Hydro]}" ' was not found.'
    fi
}

function Run_Software_Hydro()
{
    local Hydro_input_file_path="${Hydro_output_directory}/${HYBRID_software_base_config_file['Hydro']}"
    local IC_output_file_path="${IC_output_directory}/SMASH_IC.dat"
    local Hydro_output_directory="${HYBRID_output_directory}/Hydro"
    ./"${HYBRID_hydro_software_executable}" "-params" "${Hydro_input_file_path}" 
        "-ISinput" "${IC_output_file_path}" 
        "-outputDir" "${HYBRID_software_output_directory[Hydro]}"
            ">" "${HYBRID_software_output_directory[Hydro]}/Terminal_Output.txt"
}


Make_Functions_Defined_In_This_File_Readonly
