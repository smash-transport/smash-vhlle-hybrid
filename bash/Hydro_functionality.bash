#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_Hydro()
{
    Create_Output_Directory_For 'Hydro'
    Ensure_Given_Files_Do_Not_Exist "${HYBRID_software_configuration_file[Hydro]}"
    Ensure_Given_Files_Exist "${HYBRID_software_base_config_file[Hydro]}"
    Copy_Base_Configuration_To_Output_Folder_For 'Hydro'
    Replace_Keys_In_Configuration_File_If_Needed_For 'Hydro'
    __static__Create_Symbolic_Link_To_IC_File
    __static__Create_Symbolic_Link_To_EOS_Folder
}

function Ensure_All_Needed_Input_Exists_Hydro()
{
    Ensure_Given_Folders_Exist "${HYBRID_software_output_directory[Hydro]}"
    Ensure_Given_Files_Exist \
        "${HYBRID_software_configuration_file[Hydro]}" \
        "${HYBRID_software_input_file[Hydro]}"
    Internally_Ensure_Given_Files_Exist "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
}

function Ensure_Run_Reproducibility_Hydro()
{
    Copy_Hybrid_Handler_Config_Section 'Hydro' \
        "${HYBRID_software_output_directory[Hydro]}" \
        "$(dirname "$(realpath "${HYBRID_software_executable[Hydro]}")")"
}

function Run_Software_Hydro()
{
    Separate_Terminal_Output_For 'Hydro'
    cd "${HYBRID_software_output_directory[Hydro]}"
    local -r \
        hydro_config_file_path="${HYBRID_software_configuration_file[Hydro]}" \
        ic_output_file_path="${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    "${HYBRID_software_executable[Hydro]}" \
        "-params" "${hydro_config_file_path}" \
        "-ISinput" "${ic_output_file_path}" \
        "-outputDir" "${HYBRID_software_output_directory[Hydro]}" &>> \
        "${HYBRID_software_output_directory[Hydro]}/${HYBRID_terminal_output[Hydro]}"
}

#===============================================================================

function __static__Create_Symbolic_Link_To_IC_File()
{
    local -r target_link_name="${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    if [[ ! -f "${target_link_name}" || -L "${target_link_name}" ]]; then
        ln -s -f "${HYBRID_software_input_file[Hydro]}" "${target_link_name}"
    elif [[ ! "${target_link_name}" -ef "${HYBRID_software_input_file[Hydro]}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'File ' --emph "${target_link_name}" ' exists but it is not the Hydro input file ' \
            --emph "${HYBRID_software_input_file[Hydro]}" ' to be used.'
    fi
}

# NOTE: The 'eos' folder is assumed to exist in the hydro software folder.
#       The user-specified software executable is guaranteed to be either a
#       command name or a global path and in both cases 'type -P' is expected
#       to succeed and print a global path.
function __static__Create_Symbolic_Link_To_EOS_Folder()
{
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
                Print_Warning \
                    'Found a symlink ' --emph "${HYBRID_software_output_directory[Hydro]}/eos" \
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
            'A ' --emph 'eos' ' file already exists at ' \
            --emph "${HYBRID_software_output_directory[Hydro]}" \
            '.' 'Please remove it and run the hybrid handler again.'
    else
        ln -s "${eos_folder}" "${link_to_eos_folder}"
    fi
}

Make_Functions_Defined_In_This_File_Readonly
