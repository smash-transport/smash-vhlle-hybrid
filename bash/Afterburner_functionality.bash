#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_Afterburner()
{
    mkdir -p "${HYBRID_software_output_directory[Afterburner]}" || exit ${HYBRID_fatal_builtin}
    if [[ -f "${HYBRID_software_configuration_file[Afterburner]}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
            'Configuration file ' --emph "${HYBRID_software_configuration_file[Afterburner]}" ' is already existing.'
    elif [[ ! -f "${HYBRID_software_base_config_file[Afterburner]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'Base configuration file ' --emph "${HYBRID_software_base_config_file[Afterburner]}" ' was not found.'
    fi
    cp "${HYBRID_software_base_config_file[Afterburner]}"\
       "${HYBRID_software_configuration_file[Afterburner]}" || exit ${HYBRID_fatal_builtin}
    if [[ "${HYBRID_software_new_input_keys[Afterburner]}" != '' ]]; then
        Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File\
            'YAML' "${HYBRID_software_configuration_file[Afterburner]}" "${HYBRID_software_new_input_keys[Afterburner]}"
    fi
    
    if [[ ! -f "${HYBRID_software_input_file[Afterburner]}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
            'Sampler output file ' --emph "${HYBRID_software_input_file[Afterburner]}"\
            ' does not exist.'
    fi
    if [[ "${HYBRID_optional_feature[Add_spectators_from_IC]}" = 'TRUE' ]]; then
        if [[ -f "${HYBRID_software_output_directory[Sampler]}/sampling0" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
                'The input file for the afterburner ' --emph "${HYBRID_software_output_directory[Sampler]}/sampling0"\
                ' already exists.'
        # Here the config.yaml file is expected to be produced by SMASH in the output folder
        # during the IC run. It is used to determine the initial number of particles.
        elif [[ ! -f "${HYBRID_software_output_directory[IC]}/config.yaml" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
                'Initial condition configuration file ' --emph "${HYBRID_software_output_directory[IC]}/config.yaml"\
                ' does not exist which is needed to check number of initial nucleons.'
        elif [[ ! -f "${HYBRID_software_output_directory[IC]}/${HYBRID_optional_feature[Spectator_Source]}" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
                'Initial condition file ' --emph "${HYBRID_software_output_directory[IC]}/${HYBRID_optional_feature[Spectator_Source]}"\
                ' does not exist.'
        fi
        "${HYBRID_external_python_scripts[Add_spectators_from_IC]}"\
            '--sampled_particle_list' "${HYBRID_software_input_file[Afterburner]}"\
            '--initial_particle_list' "${HYBRID_software_output_directory[IC]}/${HYBRID_optional_feature[Spectator_Source]}"\
            '--output_file' "${HYBRID_software_output_directory[Afterburner]}/sampling0"\
            '--smash_config' "${HYBRID_software_output_directory[IC]}/config.yaml"
    else
        ln -s "${HYBRID_software_input_file[Afterburner]}"\
              "${HYBRID_software_output_directory[Afterburner]}/sampling0" 
    fi
}

function Ensure_All_Needed_Input_Exists_Afterburner()
{
    if [[ ! -d "${HYBRID_software_output_directory[Afterburner]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'Folder ' --emph "${HYBRID_software_output_directory[Afterburner]}" ' does not exist.'
    fi
    if [[ ! -f "${HYBRID_software_configuration_file[Afterburner]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'The configuration file ' --emph "${HYBRID_software_configuration_file[Afterburner]}"\
            ' does not exist.'
    fi
    # sampling0 could be either a symlink or an actual file, therefore the check for existence is necessary
    if [[ ! -e "${HYBRID_software_output_directory[Afterburner]}/sampling0" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'The input file ' --emph "${HYBRID_software_output_directory[Afterburner]}/sampling0"\
            ' was not found.'
    fi
}

function Run_Software_Afterburner()
{
    cd "${HYBRID_software_output_directory[Afterburner]}"
    local -r afterburner_terminal_output="${HYBRID_software_output_directory[Afterburner]}/Terminal_Output.txt"
    "${HYBRID_software_executable[Afterburner]}" \
       '-i' "${HYBRID_software_configuration_file[Afterburner]}" \
       '-o' "${HYBRID_software_output_directory[Afterburner]}" \
       '-n' \
       >> "${afterburner_terminal_output}"
}


Make_Functions_Defined_In_This_File_Readonly
