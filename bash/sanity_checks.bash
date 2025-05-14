#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables()
{
    __static__Perform_Command_Line_VS_Configuration_Consistency_Checks
    # Note that the fine-grained Python requirement check has to be done after the type
    # of parameter scan has been set, which is done done in the first function here.
    __static__Perform_Logic_Checks_Depending_On_Execution_Mode
    __static__Exit_If_Some_Further_Needed_Python_Requirement_Is_Missing
    local key
    for key in "${HYBRID_valid_software_configuration_sections[@]}"; do
        # The software output directories are always ALL set, even if not all software is run. This
        # is important as some software might rely on files in directories of other workflow blocks.
        HYBRID_software_output_directory[${key}]="${HYBRID_output_directory}/${key}/${HYBRID_run_id}"
        if Element_In_Array_Equals_To "${key}" "${HYBRID_given_software_sections[@]}"; then
            __static__Ensure_Executable_Exists "${key}"
            __static__Set_Software_Configuration_File "${key}"
            __static__Set_Software_Input_Data_File "${key}"
            __static__Set_Software_Version "${key}"
            __static__Choose_Base_Configuration_File "${key}"
            if [[ "${key}" = "Sampler" ]]; then
                __static__Ensure_Valid_Module_Given_For_Sampler
                __static__Ensure_Additional_Paths_Given_For_Sampler
                __static__Set_Sampler_Configuration_Key_Names
                __static__Set_Sampler_Input_Key_Paths
            fi
        fi
    done
    __static__Set_Software_Input_Data_File 'Spectators'
    __static__Set_Global_Variables_As_Readonly
}

# This "static" function is put here and not below "non static" ones as it should be often updated
function __static__Set_Global_Variables_As_Readonly()
{
    readonly \
        HYBRID_software_output_directory \
        HYBRID_software_configuration_file \
        HYBRID_software_input_file \
        HYBRID_software_executable \
        HYBRID_software_user_custom_input_file \
        HYBRID_software_base_config_file \
        HYBRID_software_new_input_keys \
        HYBRID_optional_feature
}

function Perform_Internal_Sanity_Checks()
{
    Internally_Ensure_Given_Files_Exist \
        'These Python scripts should be shipped within the hybrid handler codebase.' '--' \
        "${HYBRID_external_python_scripts[@]}"
    for key in "${!HYBRID_software_base_config_file[@]}"; do
        # The IC/Sampler entry in the associative array here is still empty and does not point to a
        # shipped configuration file. It will be chosen later according to the verion or module.
        if [[ ! ${key} =~ ^(IC|Sampler)$ ]]; then
            Internally_Ensure_Given_Files_Exist \
                'These base configuration files should be shipped within the hybrid handler codebase.' '--' \
                "${HYBRID_software_base_config_file[${key}]}"
        fi
    done
}

#===================================================================================================

function __static__Ensure_Valid_Module_Given_For_Sampler()
{
    if [[ ! "${HYBRID_module[Sampler]}" =~ ^(SMASH|FIST)$ ]]; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'The module specified for the Sampler run is not valid.' \
            'Valid modules are: ' --emph 'SMASH' ' and ' --emph 'FIST' '.'
    fi
    return 0
}

function __static__Ensure_Additional_Paths_Given_For_Sampler()
{
    if [[ "${HYBRID_module[Sampler]}" = 'FIST' ]]; then
        Ensure_Given_Files_Exist \
            'Some needed file for Thermal-FIST sampler was not specified in the configuration file.' \
            -- "${HYBRID_fist_module[Particle_file]}" "${HYBRID_fist_module[Decays_file]}"
    fi
}

function __static__Set_Sampler_Configuration_Key_Names()
{
    if [[ "${HYBRID_module[Sampler]}" = 'SMASH' ]]; then
        if Is_Version "${HYBRID_software_version[Sampler]}" -lt '3.2'; then
            declare -rgA HYBRID_sampler_input_key_names=(
                [surface_filename]='surface'
                [output_folder]='spectra_dir'
            )
        else
            declare -rgA HYBRID_sampler_input_key_names=(
                [surface_filename]='surface_file'
                [output_folder]='output_dir'
            )
        fi
    fi
}

function __static__Set_Sampler_Input_Key_Paths()
{
    # As the user may set particle_list_file and decays_list_file through the HYBRID_fist_module
    # array, we set the input_key_default_path array here and not in global_variables.bash.
    if [[ "${HYBRID_module[Sampler]}" = 'FIST' ]]; then
        declare -rgA HYBRID_sampler_input_key_default_paths=(
            [hypersurface_file]="${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
            [output_file]="${HYBRID_software_output_directory[Sampler]}/particle_lists.oscar"
            [particle_list_file]="${HYBRID_fist_module[Particle_file]}"
            [decays_list_file]="${HYBRID_fist_module[Decays_file]}"
        )
    else
        # The following local variable is just meant to keep the array assignment short and make formatter happy
        local -r freezeout="${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
        declare -rgA HYBRID_sampler_input_key_default_paths=(
            [${HYBRID_sampler_input_key_names[surface_filename]}]="${freezeout}"
            [${HYBRID_sampler_input_key_names[output_folder]}]="${HYBRID_software_output_directory[Sampler]}"
        )
    fi
}

function __static__Choose_Base_Configuration_File()
{
    local -r key=$1
    case "${key}" in
        IC)
            Ensure_That_Given_Variables_Are_Set_And_Not_Empty 'HYBRID_software_version[IC]'
            local ic_key
            if Is_Version "${HYBRID_software_version[IC]}" -lt '3.2'; then
                ic_key='IC_lt_3.2'
            else
                ic_key='IC_ge_3.2'
            fi
            HYBRID_software_base_config_file[IC]="${HYBRID_software_base_config_file[${ic_key}]}"
            ;;
        Sampler)
            if [[ "${HYBRID_software_base_config_file[Sampler]}" = '' ]]; then
                local sampler_key
                if [[ "${HYBRID_module[Sampler]}" = 'SMASH' ]]; then
                    Ensure_That_Given_Variables_Are_Set_And_Not_Empty 'HYBRID_software_version[Sampler]'
                    if Is_Version "${HYBRID_software_version[Sampler]}" -lt '3.2'; then
                        sampler_key='Sampler_SMASH_lt_3.2'
                    else
                        sampler_key='Sampler_SMASH_ge_3.2'
                    fi
                else
                    sampler_key='Sampler_FIST'
                fi
                HYBRID_software_base_config_file[Sampler]="${HYBRID_software_base_config_file[${sampler_key}]}"
            fi
            ;;
        *)
            # Nothing to do for other cases
            ;;
    esac
}

function __static__Perform_Command_Line_VS_Configuration_Consistency_Checks()
{
    Internally_Ensure_Given_Files_Exist "${HYBRID_configuration_file}"
    if Has_YAML_String_Given_Key "$(< "${HYBRID_configuration_file}")" 'Hybrid_handler.Run_ID' \
        && Element_In_Array_Equals_To '--id' "${!HYBRID_command_line_options_given_to_handler[@]}"; then
        Print_Attention 'The run ID was specified both in the configuration file and as command line option.'
        Print_Warning -l -- 'The value specified as ' --emph 'command line option' ' will be used!\n'
        HYBRID_run_id="${HYBRID_command_line_options_given_to_handler['--id']}"
    fi
    readonly HYBRID_run_id
}

function __static__Perform_Logic_Checks_Depending_On_Execution_Mode()
{
    case "${HYBRID_execution_mode}" in
        do)
            local key
            for key in "${!HYBRID_scan_parameters[@]}"; do
                if [[ "${HYBRID_scan_parameters["${key}"]}" != '' ]]; then
                    exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                        'Configuration key ' --emph 'Scan_parameters' ' can ONLY be specified in ' \
                        --emph 'parameter-scan' ' execution mode.'
                fi
            done
            ;;
        prepare-scan)
            if [[ "${HYBRID_number_of_samples}" -eq ${HYBRID_default_number_of_samples} ]]; then
                readonly HYBRID_scan_strategy='Combinations'
            elif [[ ! "${HYBRID_number_of_samples}" =~ ^[1-9][0-9]*$ ]] \
                || [[ "${HYBRID_number_of_samples}" -eq 1 ]]; then
                exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                    'The number of samples for Latin Hypercube Sampling scan ' \
                    'has to be ' --emph 'an integer greater than 1' '.'
            else
                readonly HYBRID_scan_strategy='LHS'
            fi
            readonly HYBRID_number_of_samples
            ;;
        help) ;; # This is the default mode which is set in tests -> do nothing, but catch it
        *)
            Print_Internal_And_Exit 'Unknown execution mode passed to ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}

function __static__Exit_If_Some_Further_Needed_Python_Requirement_Is_Missing()
{
    if ! Is_Python_Requirement_Satisfied 'packaging' &> /dev/null; then
        return # In this case we cannot do anything and the user should have already be warned
    fi
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_python_requirements
    local requirement unsatisfied_requirements=()
    for requirement in "${!HYBRID_python_requirements[@]}"; do
        case "${requirement}" in
            pyDOE*)
                if [[ ${HYBRID_execution_mode} = 'prepare-scan' ]] && [[ ${HYBRID_scan_strategy} = 'LHS' ]]; then
                    if ! Is_Python_Requirement_Satisfied "${requirement}" &> /dev/null; then
                        unsatisfied_requirements+=("${requirement}")
                    fi
                fi
                ;;
            PyYAML*)
                if [[ ${HYBRID_execution_mode} = 'do' ]] \
                    && Element_In_Array_Equals_To 'Afterburner' "${HYBRID_given_software_sections[@]}" \
                    && [[ ${HYBRID_optional_feature[Add_spectators_from_IC]} = 'TRUE' ]]; then
                    if ! Is_Python_Requirement_Satisfied "${requirement}" &> /dev/null; then
                        unsatisfied_requirements+=("${requirement}")
                    fi
                fi
                ;;
            *) ;;
        esac
    done
    if [[ ${#unsatisfied_requirements[@]} -gt 0 ]]; then
        exit_code=${HYBRID_fatal_missing_requirement} Print_Fatal_And_Exit \
            'The following Python requirements are not satisfied but needed for this run:\n' \
            --emph "$(printf '  %s\n' "${unsatisfied_requirements[@]}")" \
            '' '\nUnable to continue.'
    fi
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
    local -r label=$1
    printf -v HYBRID_software_configuration_file[${label}] \
        "${HYBRID_software_output_directory[${label}]}/${HYBRID_software_configuration_filename[${label}]}"
}

function __static__Set_Software_Input_Data_File()
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
        elif [[ "${filename}" =~ / ]]; then
            if Element_In_Array_Equals_To "${relative_key}" "${HYBRID_given_software_sections[@]}"; then
                exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                    'Requesting custom ' --emph "${key}" ' input file although executing ' \
                    --emph "${relative_key}" ' with default output name.'
            fi
        else
            printf -v filename '%s/%s' \
                "${HYBRID_software_output_directory[${relative_key}]}" \
                "${filename}"
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

function __static__Set_Software_Version()
{
    local -r key=$1
    case "${key}" in
        IC)
            local ic_version_output
            if ic_version_output=$(${HYBRID_software_executable[IC]} --version 2> /dev/null); then
                if [[ ${ic_version_output} =~ ${HYBRID_version_regex} ]]; then
                    HYBRID_software_version[IC]="${BASH_REMATCH[0]}"
                    Print_Debug 'IC version found to be ' --emph "${HYBRID_software_version[IC]}" '.'
                else
                    Print_Internal_And_Exit \
                        'IC ' --emph '--version' ' option returned a string not matching the version regex.' \
                        'The problem occurred in ' --emph "${FUNCNAME}" ' function.' \
                        'The returned string was ' --emph "${ic_version_output}" '.'
                fi
            else
                exit_code=${HYBRID_fatal_software_failed} Print_Fatal_And_Exit \
                    'The ' --emph 'IC' \
                    ' executable failed in an unexpected way when trying to retrieve its version.' \
                    'Try running ' --emph "${HYBRID_software_executable[IC]} --version" \
                    '\nto investigate the issue.'
            fi
            ;;
        Sampler)
            if [[ ${HYBRID_module[Sampler]} = 'SMASH' ]]; then
                HYBRID_software_version[Sampler]='0.0'
                local sampler_version_output
                # The SMASH hadron sampler might fail because the user is using a correctly compiled older
                # version which does not support the --version command line option, or because the user
                # did some mistake, e.g. setting up the environment and the sampler does not find some library.
                # We want to try here to be user friendly and this is to some extent possible because older
                # sampler versions exit with code 1 if a command line option is not recognized. Hence, we can
                # confidently give an error and fail if the sampler fails with an exit code different from 1.
                #
                # NOTE: Being errexit option enabled, we need to store the version output in the if-clause
                #       condition and access the possible exit code at the very beginning of the else-clause.
                if sampler_version_output=$(${HYBRID_software_executable[Sampler]} --version 2> /dev/null); then
                    if [[ ${sampler_version_output} =~ ${HYBRID_version_regex} ]]; then
                        HYBRID_software_version[Sampler]="${BASH_REMATCH[0]}"
                        Print_Debug 'Sampler version found to be ' --emph "${HYBRID_software_version[Sampler]}" '.'
                    else
                        Print_Internal_And_Exit \
                            'Sampler ' --emph '--version' ' option returned a string not matching the version regex.' \
                            'The problem occurred in ' --emph "${FUNCNAME}" ' function.' \
                            'The returned string was ' --emph "${sampler_version_output}" '.'
                    fi
                else
                    if [[ $? -ne 1 ]]; then
                        exit_code=${HYBRID_fatal_software_failed} Print_Fatal_And_Exit \
                            'The ' --emph 'Sampler' \
                            ' executable failed in an unexpected way when trying to retrieve its version.' \
                            'Try running ' --emph "${HYBRID_software_executable[Sampler]} --version" \
                            '\nto investigate the issue.'
                    else
                        Print_Debug 'Sampler version not found, setting it to 0.0'
                    fi
                fi
            fi
            ;;
        *)
            # Nothing to do in the other cases
            ;;
    esac
}

Make_Functions_Defined_In_This_File_Readonly
