#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables()
{
    local key
    for key in "${HYBRID_valid_software_configuration_sections[@]}"; do
        # The software output directories are always ALL set, even if not all software is run. This
        # is important as some software might rely on files in directories of other workflow blocks.
        HYBRID_software_output_directory[${key}]="${HYBRID_output_directory}/${key}/${HYBRID_run_id}"
        if Element_In_Array_Equals_To "${key}" "${HYBRID_given_software_sections[@]}"; then
            __static__Ensure_Executable_Exists "${key}"
            __static__Set_Software_Configuration_File "${key}"
            __static__Set_Software_Input_Data_File_If_Not_Set_By_User "${key}"
        fi
    done
    __static__Set_Software_Input_Data_File_If_Not_Set_By_User 'Spectators'
    readonly \
        HYBRID_software_output_directory \
        HYBRID_software_configuration_file \
        HYBRID_software_input_file
}

function Perform_Internal_Sanity_Checks()
{
    Internally_Ensure_Given_Files_Exist \
        'These Python scripts should be shipped within the hybrid handler codebase.' '--' \
        "${HYBRID_external_python_scripts[@]}"
    Internally_Ensure_Given_Files_Exist \
        'These base configuration files should be shipped within the hybrid handler codebase.' '--' \
        "${HYBRID_software_base_config_file[@]}"
}

function __static__Ensure_Executable_Exists()
{
    local label=$1 executable
    executable="${HYBRID_software_executable[${label}]}"
    if [[ "${executable}" = '' ]]; then
        exit_code=${HYBRID_fatal_variable_unset} Print_Fatal_And_Exit \
            'Software executable for ' --emph "${label}" ' run was not specified.'
    elif [[ "${executable}" = / ]]; then
        if [[ ! -f "${executable}" ]]; then
            exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
                'The executable file for the ' --emph "${label}" ' run was not found.' \
                'Not existing path: ' --emph "${file_path}"
        elif [[ ! -x "${executable}" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                'The executable file for the ' --emph "${label}" ' run is not executable.' \
                'File path: ' --emph "${file_path}"
        fi
    # It is important to perform this check with 'type' and not with 'hash' because 'hash' with
    # paths always succeed -> https://stackoverflow.com/a/42362142/14967071
    # This will be entered if the user gives something stupid as '~' as executable.
    elif ! type -P "${executable}" &> /dev/null; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'The command ' --emph "${executable}" ' specified for the ' \
            --emph "${label}" ' run was not located by the shell.' \
            'Please check your ' --emph 'PATH' ' environment variable and make sure' \
            'that ' --emph "type -P \"${executable}\"" ' succeeds in your terminal.'
    fi
}

function __static__Set_Software_Configuration_File()
{
    local label=$1
    printf -v HYBRID_software_configuration_file[${label}] \
        "${HYBRID_software_output_directory[${label}]}/${HYBRID_software_configuration_filename[${label}]}"
}

function __static__Set_Software_Input_Data_File_If_Not_Set_By_User()
{
    local key=$1
    if [[ ${key} =~ ^(Hydro|Afterburner)$ ]]; then
        local filename relative_key
        filename="${HYBRID_software_user_custom_input_file[${key}]}"
        case "${key}" in
            Hydro)
                relative_key='IC'
                ;;
            Afterburner)
                relative_key='Sampler'
                ;;
        esac
        if [[ "${filename}" = '' ]]; then
            printf -v filename '%s/%s' \
                "${HYBRID_software_output_directory[${relative_key}]}" \
                "${HYBRID_software_default_input_filename[${key}]}"
        else
            if Element_In_Array_Equals_To "${relative_key}" "${HYBRID_given_software_sections[@]}"; then
                exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                    'Requesting custom ' --emph "${key}" ' input file although executing ' \
                    --emph "${relative_key}" ' with default output name.'
            fi
        fi
        HYBRID_software_input_file[${key}]="${filename}"
    elif [[ "${key}" = 'Spectators' ]]; then
        if [[ "${HYBRID_optional_feature[Add_spectators_from_IC]}" = 'TRUE' ]]; then
            if [[ "${HYBRID_optional_feature[Spectators_source]}" != '' ]]; then
                HYBRID_software_input_file['Spectators']="${HYBRID_optional_feature[Spectators_source]}"
                if Element_In_Array_Equals_To "IC" "${HYBRID_given_software_sections[@]}"; then
                    exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                        'Requesting custom ' --emph 'Spectators' ' input file although executing ' \
                        --emph 'IC' ' with default output name.'
                fi
            else
                printf -v HYBRID_software_input_file[Spectators] '%s/%s' \
                    "${HYBRID_software_output_directory[IC]}" \
                    "${HYBRID_software_default_input_filename[Spectators]}"
            fi
        fi
    fi
}

function Ensure_Consistency_Of_Afterburner_Input()
{
    local config_section_input='Placeholder in case no input file is given.'
    if Has_YAML_String_Given_Key "${HYBRID_configuration_file}" 'Afterburner' 'Input_file'; then
        config_section_input=$(Read_From_YAML_String_Given_Key "${HYBRID_configuration_file}" \
            'Afterburner' 'Input_file')
    fi
    if Has_YAML_String_Given_Key "${HYBRID_configuration_file}" 'Afterburner' 'Software_keys' \
        'Modi' 'List' 'Filename'; then
        local given_filename
        given_filename=$(Read_From_YAML_String_Given_Key "${HYBRID_configuration_file}" 'Afterburner' 'Software_keys' \
            'Modi' 'List' 'Filename')
        if [[ "$given_filename" != "${config_section_input}" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                'The Afterburner input particle list has to be modified via the Input_file key, not the Software_keys!'
        fi
    fi
    if Has_YAML_String_Given_Key "${HYBRID_configuration_file}" 'Afterburner' 'Software_keys' 'Modi' \
        'List' 'Shift_ID'; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'The Afterburner input particle list has to be modified via the Input_file key, not the Software_keys!'
    fi
}

Make_Functions_Defined_In_This_File_Readonly
