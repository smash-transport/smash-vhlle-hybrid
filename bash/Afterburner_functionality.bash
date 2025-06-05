#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_Afterburner()
{
    __static__Ensure_Consistency_Of_Afterburner_Input
    Create_Output_Directory_For 'Afterburner'
    Ensure_Given_Files_Do_Not_Exist "${HYBRID_software_configuration_file[Afterburner]}"
    Ensure_Given_Files_Exist "${HYBRID_software_base_config_file[Afterburner]}"
    Copy_Base_Configuration_To_Output_Folder_For 'Afterburner'
    Replace_Keys_In_Configuration_File_If_Needed_For 'Afterburner'
    __static__Create_Sampled_Particles_File_Or_Symbolic_Link_With_Or_Without_Spectators
    __static__Check_If_Afterburner_Configuration_Is_Consistent_With_Sampler
}

function Ensure_All_Needed_Input_Exists_Afterburner()
{
    Ensure_Given_Folders_Exist "${HYBRID_software_output_directory[Afterburner]}"
    Ensure_Input_File_Exists_And_Alert_If_Unfinished \
        "${HYBRID_software_input_file[Afterburner]}"
    Ensure_Given_Files_Exist \
        "${HYBRID_software_configuration_file[Afterburner]}"
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
        &>> "${HYBRID_software_output_directory[Afterburner]}/${HYBRID_terminal_output[Afterburner]}" \
        || Report_About_Software_Failure_For 'Afterburner'
}

#===================================================================================================

function __static__Ensure_Consistency_Of_Afterburner_Input()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty 'HYBRID_software_input_file[Afterburner]'
    if Has_YAML_String_Given_Key \
        "$(< "${HYBRID_configuration_file}")" 'Afterburner' 'Software_keys' 'Modi' 'List' 'Filename'; then
        local given_filename
        given_filename=$(Read_From_YAML_String_Given_Key "$(< "${HYBRID_configuration_file}")" 'Afterburner' \
            'Software_keys' 'Modi' 'List' 'Filename')
        if [[ "${given_filename}" != "${HYBRID_software_input_file[Afterburner]}" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                'The Afterburner input particle list has to be modified via the ' \
                --emph 'Input_file' ' key,' 'not the ' --emph 'Software_keys' \
                ' specifying the input list filename!'
        fi
    fi
    if Has_YAML_String_Given_Key \
        "$(< "${HYBRID_configuration_file}")" 'Afterburner' 'Software_keys' 'Modi' 'List' 'Shift_ID' \
        || Has_YAML_String_Given_Key \
            "$(< "${HYBRID_configuration_file}")" 'Afterburner' 'Software_keys' 'Modi' 'List' 'File_Prefix'; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'The Afterburner input particle list has to be modified via the ' \
            --emph 'Input_file' ' key,' 'not the ' --emph 'Software_keys' \
            ' specifying the input list prefix and ID!'
    fi
}

function __static__Run_Add_Spectators_Python_Script()
{
    local python_fatal_value_error
    # NOTE: To extract the right error code in the python script, it has to be handed to it right
    #       before calling the script since the error codes are not exported by default.
    python_fatal_value_error=${HYBRID_fatal_value_error} \
        "${HYBRID_external_python_scripts[Add_spectators_from_IC]}" \
        '--sampled_particle_list' "${HYBRID_software_input_file[Afterburner]}" \
        '--initial_particle_list' "${HYBRID_software_input_file[Spectators]}" \
        '--output_file' "${target_link_name}" \
        '--smash_config' "${HYBRID_software_output_directory[IC]}/config.yaml" 2> /dev/null
}

function __static__Create_Sampled_Particles_File_Or_Symbolic_Link_With_Or_Without_Spectators()
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
        # NOTE: Since the errexit option enabled, the python script to add the spectators is run in the if-statement
        #       and the possible exit code is accessed at the very beginning of the else-clause.
        local python_exit_code
        if __static__Run_Add_Spectators_Python_Script; then
            # BE AWARE: The negation of the if-clause does not work because then the exit code cannot
            #           be extracted properly (it will always be 0 because of the true if-statement).
            :
        else
            python_exit_code=$?
            if [[ ${python_exit_code} -eq ${HYBRID_fatal_value_error} ]]; then
                exit_code=${HYBRID_fatal_value_error} Print_Fatal_And_Exit \
                    'It was attempted to add spectators from multiple IC events to the sampled particles file. Only' \
                    'running one IC event is supported when using the Afterburner config key ' \
                    --emph "Add_spectators_from_IC: true" '.'
            elif [[ ${python_exit_code} -eq 2 ]]; then
                Print_Internal_And_Exit \
                    'The handing over of the ' --emph "python_fatal_value_error" \
                    ' to the Python script that adds spectators from the IC did not work.'
            else
                Print_Fatal_And_Exit \
                    'Adding spectators from the IC particles to the sampled particles file failed.'
            fi
        fi
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

function __static__Check_If_Afterburner_Configuration_Is_Consistent_With_Sampler()
{
    local -r config_afterburner="${HYBRID_software_configuration_file[Afterburner]}"
    if Element_In_Array_Equals_To 'Sampler' "${HYBRID_given_software_sections[@]}"; then
        local -r config_sampler="${HYBRID_software_configuration_file[Sampler]}"
        local number_of_events_config_key_sampler
        if [[ "${HYBRID_module[Sampler]}" = 'SMASH' ]]; then
            number_of_events_config_key_sampler='number_of_events'
        elif [[ "${HYBRID_module[Sampler]}" = 'FIST' ]]; then
            number_of_events_config_key_sampler='nevents'
        else
            Print_Internal_And_Exit 'The used sampler module ' --emph "${HYBRID_module[Sampler]}" \
                ' is not recognized by the function\n' --emph "${FUNCNAME}" \
                '. This should not have happened.'
        fi
        while read key value; do
            if [[ "${key}" = "${number_of_events_config_key_sampler}" ]]; then
                local events_sampler
                events_sampler="${value}"
            fi
        done < "${config_sampler}"
        local events_afterburner
        events_afterburner=$(Read_From_YAML_String_Given_Key "$(< "${config_afterburner}")" 'General.Nevents')
        if [[ "${events_afterburner}" -gt "${events_sampler}" ]]; then
            Print_Attention 'The number of events set to run in the afterburner (' \
                --emph "${events_afterburner}" ')\nis greater than the number of events sampled (' \
                --emph "${events_sampler}" ').\n' \
                --emph 'Nevents' ' in the afterburner configuration file is reset to ' --emph "${events_sampler}" '!'
            Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
                'YAML' "${config_afterburner}" \
                "$(printf "%s:\n  %s:  %s\n" 'General' 'Nevents' "${events_sampler}")"
        elif [[ "${events_afterburner}" -lt "${events_sampler}" ]]; then
            Print_Attention 'The number of events set to run in the afterburner (' \
                --emph "${events_afterburner}" ')\nis smaller than the number of events sampled (' \
                --emph "${events_sampler}" ').' \
                'Excess sampled events remain unused.' \
                'Please, ensure that this is desired behavior.'
        fi
    fi
}

Make_Functions_Defined_In_This_File_Readonly
