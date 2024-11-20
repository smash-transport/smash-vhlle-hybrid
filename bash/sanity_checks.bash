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
            __static__Set_Software_Input_Data_File_If_Not_Set_By_User "${key}"
            if [[ "${key}" = "Sampler" ]]; then
                __static__Ensure_Valid_Module_Given
                __static__Choose_Base_Configuration_File_For_Sampler
                __static__Ensure_Additional_Paths_Given_For_Sampler
                __static__Set_Sampler_Input_Key_Paths
            fi
        fi
    done
    __static__Set_Software_Input_Data_File_If_Not_Set_By_User 'Spectators'
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
        if [[ "$key" != "Sampler" ]]; then
            Internally_Ensure_Given_Files_Exist \
                'These base configuration files should be shipped within the hybrid handler codebase.' '--' \
                "${HYBRID_software_base_config_file[$key]}"
        fi
    done
}

#===================================================================================================

function __static__Ensure_Valid_Module_Given()
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
            'Some needed file for Thermal-FIST sampler was not specified in the configuration file' \
            -- "${HYBRID_fist_module[Particle_file]}" "${HYBRID_fist_module[Decays_file]}"
    fi
}

function __static__Set_Sampler_Input_Key_Paths()
{
    declare -rgA HYBRID_sampler_input_key_default_paths=(
        # FIST input key paths
        ['hypersurface_file']="${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
        ['output_file']="${HYBRID_software_output_directory[Sampler]}/particle_lists.oscar"
        ['particle_list_file']="${HYBRID_fist_module[Particle_file]}"
        ['decays_list_file']="${HYBRID_fist_module[Decays_file]}"
        # SMASH input key paths
        ['surface']="${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
        ['spectra_dir']="${HYBRID_software_output_directory[Sampler]}"
    )
}

function __static__Choose_Base_Configuration_File_For_Sampler()
{
    if [[ "${HYBRID_software_base_config_file[Sampler]}" = '' ]]; then
        Sampler_key="Sampler_${HYBRID_module[Sampler]}"
        HYBRID_software_base_config_file[Sampler]="${HYBRID_software_base_config_file[${Sampler_key}]}"
    fi
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

Make_Functions_Defined_In_This_File_Readonly
