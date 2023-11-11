#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_Sampler()
{
    mkdir -p "${HYBRID_software_output_directory[Sampler]}" || exit ${HYBRID_fatal_builtin}
    if [[ -f "${HYBRID_software_configuration_file[Sampler]}" ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
            'Configuration file ' --emph "${HYBRID_software_configuration_file[Sampler]}"\
            ' is already existing.'
    elif [[ ! -f "${HYBRID_software_base_config_file[Sampler]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'Base configuration file ' --emph "${HYBRID_software_base_config_file[Sampler]}"\
            ' was not found.'
    fi
    cp "${HYBRID_software_base_config_file[Sampler]}"\
       "${HYBRID_software_output_directory[Sampler]}" || exit ${HYBRID_fatal_builtin}
    if [[ "${HYBRID_software_new_input_keys[Sampler]}" != '' ]]; then
        Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File\
            'TXT' "${HYBRID_software_configuration_file[Sampler]}"\
            "${HYBRID_software_new_input_keys[Sampler]}"
    fi

    # Replace potentially relative paths in Sampler config with absolute paths
    local freezeout_path output_directory
    freezeout_path=$(__static__Get_Path_Field_From_Sampler_Config_As_Global_Path 'surface')
    output_directory=$(__static__Get_Path_Field_From_Sampler_Config_As_Global_Path 'spectra_dir')
    Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File\
        'TXT' "${HYBRID_software_configuration_file[Sampler]}"\
        "$(printf "%s: %s\n"\
                  'surface' "${freezeout_path}"\
                  'spectra_dir' "${output_directory}")"

    # The following symbolic link is not needed by the sampler, as it refers to its input file.
    # However, we want to have all input in the output folder for future easier reproducibility
    # (and we do so for all blocks in the workflow).
    if [[ "$( dirname "${freezeout_path}" )" != "${HYBRID_software_output_directory[Sampler]}" ]]; then
        ln -s "${freezeout_path}"\
              "${HYBRID_software_output_directory[Sampler]}/freezeout.dat"
    fi
}

function Ensure_All_Needed_Input_Exists_Sampler()
{
    if [[ ! -d "${HYBRID_software_output_directory[Sampler]}" ]]; then
         exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
             'Folder ' --emph "${HYBRID_software_output_directory[Sampler]}"\
             ' does not exist.'
    fi
    if [[ ! -f "${HYBRID_software_configuration_file[Sampler]}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'Configuration file ' --emph "${HYBRID_software_configuration_file[Sampler]}"\
            ' was not found.'
    fi
    local freezeout_path
    freezeout_path=$(__static__Get_Path_Field_From_Sampler_Config_As_Global_Path 'surface')
    echo "DGFSHJ " "${freezeout_path}"
    if [[ ! -f "${freezeout_path}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            'Freezeout hypersurface ' --emph "${freezeout_path}" ' does not exist.'
    fi
}

function Run_Software_Sampler()
{
    local -r sampler_config_file_path="${HYBRID_software_configuration_file[Sampler]}"
    local sampler_terminal_output="${HYBRID_software_output_directory[Sampler]}/Terminal_Output.txt"
    cd "${HYBRID_software_output_directory[Sampler]}"
    "${HYBRID_software_executable[Sampler]}" 'events'  '1' \
            "${sampler_config_file_path}" >> "${sampler_terminal_output}"
}

function __static__Get_Path_Field_From_Sampler_Config_As_Global_Path()
{
    local field value
    field=$1
    value=$(awk -v name="${field}" '$1 == name {print $2; exit}'\
                      "${HYBRID_software_configuration_file[Sampler]}")
    (
        cd "${HYBRID_software_output_directory[Sampler]}"
        # If realpath succeeds, it prints the path that is the result of the function
        if ! realpath "${value}" 2> /dev/null; then
            exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
                'Unable to transform relatrive path "' --emph "${value}"\
                '" into global one.'
        fi
    )
}

Make_Functions_Defined_In_This_File_Readonly
