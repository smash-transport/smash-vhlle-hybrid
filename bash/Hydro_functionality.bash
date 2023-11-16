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
    cp "${HYBRID_software_base_config_file[Hydro]}"\
       "${HYBRID_software_configuration_file[Hydro]}" || exit ${HYBRID_fatal_builtin}
    if [[ "${HYBRID_software_new_input_keys[Hydro]}" != '' ]]; then
        Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File\
            'TXT' "${HYBRID_software_configuration_file[Hydro]}" "${HYBRID_software_new_input_keys[Hydro]}"
    fi
    # Create symbolic link to IC file, which is assumed to exist here (its existence is checked later).
    # If the file exists we will just use it; if it exists as a broken link we overwrite it with 'ln -f'.
    if [[ ! -e "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat" ]]; then
        ln -s -f "${HYBRID_software_output_directory[IC]}/SMASH_IC.dat"\
                 "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    fi
    # Create a symbolic link to the eos folder, which is assumed to exist in the vhlle repository.
    local eos_folder
    eos_folder="$(dirname $(which "${HYBRID_software_executable[Hydro]}"))/eos"
    if [[ ! -d "${eos_folder}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'The folder ' --emph "${eos_folder}" ' does not exist.'
    fi
    ln -s "${eos_folder}" "${HYBRID_software_output_directory[Hydro]}"
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
    if [[ ! -e "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
        'IC output file ' --emph "${HYBRID_software_output_directory[IC]}/SMASH_IC.dat" ' does not exist.'
    fi
}

function Run_Software_Hydro()
{
    cd "${HYBRID_software_output_directory[Hydro]}"
    local -r\
        hydro_config_file_path="${HYBRID_software_configuration_file[Hydro]}"\
        ic_output_file_path="${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"\
        hydro_terminal_output="${HYBRID_software_output_directory[Hydro]}/Terminal_Output.txt"
    "${HYBRID_software_executable[Hydro]}" "-params" "${hydro_config_file_path}"\
         "-ISinput" "${ic_output_file_path}" "-outputDir" "${HYBRID_software_output_directory[Hydro]}" >> "${hydro_terminal_output}"
}


Make_Functions_Defined_In_This_File_Readonly
