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
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'Configuration file ' --emph "${HYBRID_software_configuration_file[Hydro]}" ' is already existing.'
    elif [[ ! -f "${HYBRID_software_base_config_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'Base configuration file ' --emph "${HYBRID_software_base_config_file[Hydro]}" ' was not found.'
    fi
    cp "${HYBRID_software_base_config_file[Hydro]}" \
        "${HYBRID_software_configuration_file[Hydro]}" || exit ${HYBRID_fatal_builtin}
    if [[ "${HYBRID_software_new_input_keys[Hydro]}" != '' ]]; then
        Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
            'TXT' "${HYBRID_software_configuration_file[Hydro]}" "${HYBRID_software_new_input_keys[Hydro]}"
    fi
    # Create symbolic link to IC file, which is assumed to exist here (its existence is checked later).
    # If the file exists we will just use it; if it exists as a broken link we overwrite it with 'ln -f'.
    local -r target_link_name="${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    if [[ ! -f "${target_link_name}" || -L "${target_link_name}" ]]; then
        ln -s -f "${HYBRID_software_input_file[Hydro]}" "${target_link_name}"
    elif [[ ! "${target_link_name}" -ef "${HYBRID_software_input_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'File ' --emph "${target_link_name}" ' exists but it is not the Hydro input file ' \
            --emph "${HYBRID_software_input_file[Hydro]}" ' to be used.'
    fi
    # Create a symbolic link to the eos folder, which is assumed to exist in the hydro software
    # folder. The user-specified software executable is guaranteed to be either a command name
    # or a global path and in both cases 'type -P' is expected to succeed and print a global path.
    local eos_folder
    eos_folder="$(dirname $(type -P "${HYBRID_software_executable[Hydro]}"))/eos"
    if [[ ! -d "${eos_folder}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'The folder ' --emph "${eos_folder}" ' does not exist.'
    fi
    local -r link_to_eos_folder="${HYBRID_software_output_directory[Hydro]}/eos"
    if [[ -d "${link_to_eos_folder}" ]]; then
        if [[ ! "${link_to_eos_folder}" -ef "${eos_folder}" ]]; then
            if [[ -L "${link_to_eos_folder}" ]]; then
                Print_Warning 'Found a symlink ' --emph "${HYBRID_software_output_directory[Hydro]}/eos" \
                    '\npointing to a different eos folder. Unlink and link again!\n'
                unlink "${HYBRID_software_output_directory[Hydro]}/eos"
                ln -s "${eos_folder}" "${link_to_eos_folder}"
            else
                exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                    'A ' --emph 'eos' ' folder called already exists at ' \
                    --emph "${HYBRID_software_output_directory[Hydro]}" \
                    '.' 'Please remove it and run the hybrid handler again.'
            fi
        fi
    elif [[ -e "${link_to_eos_folder}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'A ' --emph 'eos' ' file already exists at ' --emph "${HYBRID_software_output_directory[Hydro]}" \
            '.' 'Please remove it and run the hybrid handler again.'
    else
        ln -s "${eos_folder}" "${link_to_eos_folder}"
    fi
}

function Ensure_All_Needed_Input_Exists_Hydro()
{
    if [[ ! -d "${HYBRID_software_output_directory[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'Folder ' --emph "${HYBRID_software_output_directory[Hydro]}" ' does not exist.'
    fi
    if [[ ! -f "${HYBRID_software_configuration_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'The configuration file ' --emph "${HYBRID_software_configuration_file[Hydro]}" ' was not found.'
    fi
    if [[ ! -e "${HYBRID_software_input_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'The input file ' --emph "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat" \
            ' was not found.'
    elif [[ ! -e "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat" ]]; then
        Print_Internal_And_Exit \
            'Something went wrong when creating the Hydro symbolic link.'
    fi
}

function Run_Software_Hydro()
{
    Copy_Hybrid_Handler_Config_Section "Hydro" "${HYBRID_software_output_directory[Hydro]}"
    cd "${HYBRID_software_output_directory[Hydro]}"
    local -r \
        hydro_config_file_path="${HYBRID_software_configuration_file[Hydro]}" \
        ic_output_file_path="${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat" \
        hydro_terminal_output="${HYBRID_software_output_directory[Hydro]}/Terminal_Output.txt"
    "${HYBRID_software_executable[Hydro]}" \
        "-params" "${hydro_config_file_path}" \
        "-ISinput" "${ic_output_file_path}" \
        "-outputDir" "${HYBRID_software_output_directory[Hydro]}" >> "${hydro_terminal_output}"
}

Make_Functions_Defined_In_This_File_Readonly
