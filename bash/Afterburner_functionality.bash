#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_Afterburner()
{
    Ensure_Consistency_Of_Afterburner_Input
    Create_Output_Directory_For 'Afterburner'
    Ensure_Given_Files_Do_Not_Exist "${HYBRID_software_configuration_file[Afterburner]}"
    Ensure_Given_Files_Exist "${HYBRID_software_base_config_file[Afterburner]}"
    Copy_Base_Configuration_To_Output_Folder_For 'Afterburner'
    Replace_Keys_In_Configuration_File_If_Needed_For 'Afterburner'
    __static__Create_Sampled_Particles_List_File_Or_Symbolic_Link_With_Or_Without_Spectators
}

function Ensure_All_Needed_Input_Exists_Afterburner()
{
    Ensure_Given_Folders_Exist "${HYBRID_software_output_directory[Afterburner]}"
    Ensure_Given_Files_Exist \
        "${HYBRID_software_configuration_file[Afterburner]}" \
        "${HYBRID_software_input_file[Afterburner]}"
    Internally_Ensure_Given_Files_Exist \
        "${HYBRID_software_output_directory[Afterburner]}/${HYBRID_afterburner_list_filename}"
}

function Ensure_Run_Reproducibility_Afterburner()
{
    Copy_Hybrid_Handler_Config_Section 'Afterburner' \
        "${HYBRID_software_output_directory[Afterburner]}" \
        "$(dirname "$(realpath "${HYBRID_software_executable[Afterburner]}")")"
}

function Run_Software_Afterburner()
{
    Separate_Terminal_Output_For 'Afterburner'
    cd "${HYBRID_software_output_directory[Afterburner]}"
    "${HYBRID_software_executable[Afterburner]}" \
        '-i' "${HYBRID_software_configuration_file[Afterburner]}" \
        '-o' "${HYBRID_software_output_directory[Afterburner]}" \
        '-n' \
        &>> "${HYBRID_software_output_directory[Afterburner]}/${HYBRID_terminal_output[Afterburner]}"
}

#===============================================================================

function __static__Create_Sampled_Particles_List_File_Or_Symbolic_Link_With_Or_Without_Spectators()
{
    local -r target_link_name="${HYBRID_software_output_directory[Afterburner]}/${HYBRID_afterburner_list_filename}"
    if [[ "${HYBRID_optional_feature[Add_spectators_from_IC]}" = 'TRUE' ]]; then
        Ensure_Given_Files_Do_Not_Exist "${target_link_name}"
        # Here the config.yaml file is expected to be produced by SMASH in the output folder
        # during the IC run. It is used to determine the initial number of particles.
        Ensure_Given_Files_Exist \
            'This file is expected to be produced by the IC software run' \
            'and is needed to check number of initial nucleons.' '--' \
            "${HYBRID_software_output_directory[IC]}/config.yaml"
        Ensure_Given_Files_Exist \
            "${HYBRID_software_input_file[Afterburner]}" \
            "${HYBRID_software_input_file[Spectators]}"
        # Run Python script to add spectators
        "${HYBRID_external_python_scripts[Add_spectators_from_IC]}" \
            '--sampled_particle_list' "${HYBRID_software_input_file[Afterburner]}" \
            '--initial_particle_list' "${HYBRID_software_input_file[Spectators]}" \
            '--output_file' "${target_link_name}" \
            '--smash_config' "${HYBRID_software_output_directory[IC]}/config.yaml"
    else
        if [[ ! -f "${target_link_name}" || -L "${target_link_name}" ]]; then
            ln -s -f "${HYBRID_software_input_file[Afterburner]}" "${target_link_name}"
        elif [[ ! "${target_link_name}" -ef "${HYBRID_software_input_file[Afterburner]}" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                'File ' --emph "${target_link_name}" ' exists but it is not the Afterburner input file ' \
                --emph "${HYBRID_software_input_file[Afterburner]}" ' to be used.'
        fi
    fi
}

Make_Functions_Defined_In_This_File_Readonly
