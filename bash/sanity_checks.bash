#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables()
{
    local key base_file
    for key in "${HYBRID_valid_software_configuration_sections[@]}"; do
        # The software output directories are always ALL set, even if not all software is run. This
        # is important as some software might rely on files in directories of other workflow blocks.
        HYBRID_software_output_directory[${key}]="${HYBRID_output_directory}/${key}"
        if Element_In_Array_Equals_To "${key}" "${HYBRID_given_software_sections[@]}"; then
            __static__Ensure_Executable_Exists "${key}"
            printf -v HYBRID_software_configuration_file[${key}] \
               "${HYBRID_software_output_directory[${key}]}/${HYBRID_software_input_filename[${key}]}"
            base_file=$(basename "${HYBRID_software_base_config_file[${key}]}")
            HYBRID_software_configuration_file[${key}]="${HYBRID_software_output_directory[${key}]}/${base_file}"
            if [[ ${key} != 'IC' ]]; then
                base_file=$(basename "${HYBRID_software_default_input_file[${key}]}")
                HYBRID_software_input_file[${key}]="${HYBRID_software_output_directory[${key}]}/${base_file}"
            fi
        fi
    done
    readonly HYBRID_software_output_directory HYBRID_software_configuration_file  HYBRID_software_input_file 
}

function Perform_Sanity_Checks_On_Existence_Of_External_Python_Scripts()
{
    for external_file in "${HYBRID_external_python_scripts[@]}"; do
        if [[ ! -f "${external_file}" ]]; then
            exit_code=${HYBRID_fatal_file_not_found} Print_Internal_And_Exit\
                'The python script ' --emph "${external_file}" ' was not found.'
        fi
    done 
}

function __static__Ensure_Executable_Exists()
{
    local label=$1 executable
    executable="${HYBRID_software_executable[${label}]}"
    if [[ "${executable}" = '' ]]; then
        exit_code=${HYBRID_fatal_variable_unset} Print_Fatal_And_Exit\
            'Software executable for ' --emph "${label}" ' run was not specified.'
    elif [[ "${executable}" != / ]]; then 
        if [[ ! -f "${executable}" ]]; then
            exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
                'The executable file for the ' --emph "${label}" ' run was not found.'
        elif [[ ! -x "${executable}" ]]; then
            exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
                'The executable file for the ' --emph "${label}" ' run is not executable.'
        fi
    # It is important to perform this check with 'type' and not with 'hash' because 'hash' with
    # paths always succeed -> https://stackoverflow.com/a/42362142/14967071
    # This will be entered if the user gives something stupid as '~' as executable.
    elif ! type -P "${executable}" &> /dev/null; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
            'The command ' --emph "${executable}" ' specified for the '\
            --emph "${label}" ' run was not located by the shell.'\
            'Please check your ' --emph 'PATH' ' environment variable and make sure'\
            'that '--emph "type -P \"${executable}\"" ' succeeds in your terminal.'
    fi
}


Make_Functions_Defined_In_This_File_Readonly
