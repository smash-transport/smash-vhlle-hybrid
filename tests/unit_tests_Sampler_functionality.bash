#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function __static__Do_Preliminary_Sampler_Setup_Operations()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'common_functionality.bash'
        'Sampler_functionality.bash'
        'Sampler_functionality_FIST.bash'
        'Sampler_functionality_SMASH.bash'
        'global_variables.bash'
        'software_input_functionality.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
    HYBRID_output_directory="${HYBRIDT_folder_to_run_tests}/test_dir_Sampler"
    HYBRID_given_software_sections=('Sampler')
    HYBRID_software_executable[Sampler]="${HYBRIDT_tests_folder}/mocks/echo.py"
    # Touch dummy empty handler config as this is always there in sanity checks
    touch "${HYBRID_configuration_file}"
}

function Make_Test_Preliminary_Operations__Sampler-create-input-file-SMASH()
{
    __static__Do_Preliminary_Sampler_Setup_Operations
    export MOCK_ECHO_VERSION=3.1.1
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
    # Since we use our mock of echo as fake sampler executable the function above will set the
    # sampler version to the MOCK_ECHO_VERSION environment variable value.
}

function Unit_Test__Sampler-create-input-file-SMASH()
{
    HYBRID_module[Sampler]='SMASH'
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    touch "${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Sampler
    if [[ $? -ne 0 ]]; then
        Print_Error 'Preparation of input unexpectedly failed.'
        return 1
    elif [[ ! -f "${HYBRID_software_configuration_file[Sampler]}" ]]; then
        Print_Error 'The output directory and/or software input file were not properly created.'
        return 1
    fi
    # Ensure that paths in Sampler config were replaced by global paths
    local surface_path spectra_dir_path
    surface_path=$(awk '$1 == "surface" {print $2; exit}' \
        "${HYBRID_software_configuration_file[Sampler]}")
    spectra_dir_path=$(awk '$1 == "spectra_dir" {print $2; exit}' \
        "${HYBRID_software_configuration_file[Sampler]}")
    if [[ "${surface_path}" != /* || "${spectra_dir_path}" != /* ]]; then
        Print_Error 'Freezeout and/or output directory path in Sampler config is not a global path.'
        return 1
    fi
    # Creating again the input should fail
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation of input with existent config succeeded.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-SMASH()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Sampler-create-input-file-FIST()
{
    __static__Do_Preliminary_Sampler_Setup_Operations
    HYBRID_module[Sampler]='FIST'
    touch "${HYBRID_fist_module[Particle_file]}" "${HYBRID_fist_module[Decays_file]}"
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables

}

function Unit_Test__Sampler-create-input-file-FIST()
{
    HYBRID_module[Sampler]='FIST'
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    touch "${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Sampler
    if [[ $? -ne 0 ]]; then
        Print_Error 'Preparation of input unexpectedly failed.'
        return 1
    elif [[ ! -f "${HYBRID_software_configuration_file[Sampler]}" ]]; then
        Print_Error 'The output directory and/or software input file were not properly created.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-FIST()
{
    rm "${HYBRID_fist_module[Decays_file]}"
    rm "${HYBRID_fist_module[Particle_file]}"
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Sampler-check-all-input-SMASH()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file-SMASH
}

function Unit_Test__Sampler-check-all-input-SMASH()
{
    HYBRID_module[Sampler]='SMASH'
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing output directory succeeded.'
        return 1
    fi
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing config file succeeded.'
        return 1
    fi
    touch "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring correctness of empty sampler input file succeeded.'
        return 1
    fi
    printf 'surface not-existing-file\n' > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing freezeout surface file succeeded.'
        return 1
    fi
    printf '%s\n' \
        "surface $(which ls)" \
        "spectra_dir ${HOME}" \
        'ecrit 0.5' \
        'number_of_events 42' > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler
    if [[ $? -ne 0 ]]; then
        Print_Error 'Ensuring existence of all input files unexpectedly failed.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-check-all-input-SMASH()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-SMASH
}

function Make_Test_Preliminary_Operations__Sampler-validate-config-file-SMASH()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file-SMASH
}

function __static__Validate_Given_Configuration_File_SMASH()
{
    local -r \
        failure_reason=$1 \
        config_lines=("${@:2}")
    printf '%s\n' "${config_lines[@]}" > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although ' --emph "${failure_reason}" '.'
        return 1
    fi
}

function __static__Possibly_Fail_Validation_Test()
{
    if [[ $1 -ne 0 ]]; then
        return 1
    fi
}

function __static__Validate_Config_File_For_Fixed_Version_SMASH()
{
    local surface_key output_dir_key
    Print_Debug "${HYBRID_software_version[Sampler]}"
    if Is_Version "${HYBRID_software_version[Sampler]}" -lt '3.2'; then
        surface_key='surface'
        output_dir_key='spectra_dir'
    else
        surface_key='surface_file'
        output_dir_key='output_dir'
    fi
    # Empty config file
    __static__Validate_Given_Configuration_File_SMASH \
        'config file is empty'
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Too many columns in config file
    __static__Validate_Given_Configuration_File_SMASH \
        'config file has wrong number of columns' "${surface_key} whatever wrong"
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Repeated key in config file
    __static__Validate_Given_Configuration_File_SMASH \
        'config file has repeated lines' "${output_dir_key} ~" "${output_dir_key} ~"
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Config file with invalid key
    __static__Validate_Given_Configuration_File_SMASH \
        'config file has invalid key' 'invalidKey value'
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Config file missing one required key
    local -r mandatory_config_keys=(
        "${output_dir_key} ."
        "${surface_key} $(which ls)"
        'ecrit 0.5'
        'number_of_events 100'
    )
    local index aux_copy
    for index in ${!mandatory_config_keys[@]}; do
        aux_copy=("${mandatory_config_keys[@]}")
        unset -v 'aux_copy[index]'
        __static__Validate_Given_Configuration_File_SMASH \
            "config file does not contain '${mandatory_config_keys[index]}'" "${aux_copy[@]}"
        __static__Possibly_Fail_Validation_Test $? || return 1
    done
    # Config file with incorrect surface key
    __static__Validate_Given_Configuration_File_SMASH \
        "${surface_key} key has no string as value" "${surface_key} not-a-file"
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Config file with incorrect output directory
    __static__Validate_Given_Configuration_File_SMASH \
        "${output_dir_key} key has no directory as value" "${output_dir_key} $(which ls)"
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Config file with incorrect value type for mandatory keys
    __static__Validate_Given_Configuration_File_SMASH \
        "'ecrit' should not be accepted" \
        "${output_dir_key} ." "${surface_key} $(which ls)" 'number_of_events 314' 'ecrit +-1'
    __static__Possibly_Fail_Validation_Test $? || return 1
    __static__Validate_Given_Configuration_File_SMASH \
        "'number_of_events' should not be accepted" \
        "${output_dir_key} ." "${surface_key} $(which ls)" 'number_of_events 3.14' 'ecrit 0.5'
    __static__Possibly_Fail_Validation_Test $? || return 1
}

function Unit_Test__Sampler-validate-config-file-SMASH()
{
    HYBRID_module[Sampler]='SMASH'
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    cd "${HYBRID_software_output_directory[Sampler]}"
    HYBRID_software_version[Sampler]='3.1.1'
    __static__Validate_Config_File_For_Fixed_Version_SMASH
    if [[ $? -ne 0 ]]; then
        Print_Error \
            'Validation of sampler configuration file for version ' \
            --emph "${HYBRID_software_version[Sampler]}" ' failed.'
        return 1
    fi
    HYBRID_software_version[Sampler]='3.2'
    __static__Validate_Config_File_For_Fixed_Version_SMASH
    if [[ $? -ne 0 ]]; then
        Print_Error \
            'Validation of sampler configuration file for version ' \
            --emph "${HYBRID_software_version[Sampler]}" ' failed.'
        return 1
    fi
    # Config file with incorrect value type for optional keys
    for wrong_key_value in \
        'bulk true' \
        'shear true' \
        'cs2 +-1' \
        'ratio_pressure_energydensity +-1' \
        'create_root_output True'; do
        __static__Validate_Given_Configuration_File_SMASH \
            "'${wrong_key_value}' should not be accepted" "${mandatory_config_keys[@]}" "${wrong_key_value}"
        __static__Possibly_Fail_Validation_Test $? || return 1
    done
}

function Clean_Tests_Environment_For_Following_Test__Sampler-validate-config-file-SMASH()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-SMASH
}

function Make_Test_Preliminary_Operations__Sampler-validate-shipped-config-file-SMASH-lt-3.2()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file-SMASH
    readonly HYBRIDT_sampler_base_config_file_label='Sampler_SMASH_lt_3.2'
}

function Unit_Test__Sampler-validate-shipped-config-file-SMASH-lt-3.2()
{
    HYBRID_module[Sampler]='SMASH'
    Print_Debug 'Sampler version: ' --emph "${HYBRID_software_version[Sampler]}"
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    cd "${HYBRID_software_output_directory[Sampler]}"
    cp \
        "${HYBRID_software_base_config_file["${HYBRIDT_sampler_base_config_file_label}"]}" \
        "${HYBRID_software_configuration_file[Sampler]}"
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    touch "${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid
    if [[ $? -ne 0 ]]; then
        Print_Error \
            'Shipped sampler configuration for version ' --emph "${HYBRID_software_version[Sampler]}" \
            ' unexpectedly detected as incorrect.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-validate-shipped-config-file-SMASH-lt-3.2()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-SMASH
}

function Make_Test_Preliminary_Operations__Sampler-validate-shipped-config-file-SMASH-ge-3.2()
{
    __static__Do_Preliminary_Sampler_Setup_Operations
    export MOCK_ECHO_VERSION=3.2
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
    readonly HYBRIDT_sampler_base_config_file_label='Sampler_SMASH_ge_3.2'
}

function Unit_Test__Sampler-validate-shipped-config-file-SMASH-ge-3.2()
{
    Unit_Test__Sampler-validate-shipped-config-file-SMASH-lt-3.2
}

function Clean_Tests_Environment_For_Following_Test__Sampler-validate-shipped-config-file-SMASH-lt-3.2()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-SMASH
}

function Make_Test_Preliminary_Operations__Sampler-validate-config-file-FIST()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file-FIST
}

function __static__Validate_Given_Configuration_File_FIST()
{
    local -r \
        failure_reason=$1 \
        config_lines=("${@:2}")
    printf '%s\n' "${config_lines[@]}" > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although ' --emph "${failure_reason}" '.'
        return 1
    fi
}

function Unit_Test__Sampler-validate-config-file-FIST()
{
    HYBRID_module[Sampler]='FIST'
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    cd "${HYBRID_software_output_directory[Sampler]}"
    # Empty config file
    __static__Validate_Given_Configuration_File_FIST \
        'config file is empty'
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Too many columns in config file
    __static__Validate_Given_Configuration_File_FIST \
        'config file has wrong number of columns' 'hypersurface whatever wrong'
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Repeated key in config file
    __static__Validate_Given_Configuration_File_FIST \
        'config file has repeated lines' 'output_file ~' 'output_file ~'
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Config file with invalid key
    __static__Validate_Given_Configuration_File_FIST \
        'config file has invalid key' 'invalidKey value'
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Config file missing one required key
    local -r mandatory_config_keys=(
        "hypersurface_file $(which ls)"
        'output_file .'
        'particle_list_file .'
        'decays_list_file .'
    )
    local index aux_copy
    for index in ${!mandatory_config_keys[@]}; do
        aux_copy=("${mandatory_config_keys[@]}")
        unset -v 'aux_copy[index]'
        __static__Validate_Given_Configuration_File_FIST \
            "config file does not contain '${mandatory_config_keys[index]}'" "${aux_copy[@]}"
        __static__Possibly_Fail_Validation_Test $? || return 1
    done
    # Config file with incorrect hypersurface_file
    __static__Validate_Given_Configuration_File_FIST \
        '"hypersurface_file" key has no valid file as value' 'hypersurface_file not-a-file'
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Config file with incorrect output_file location
    __static__Validate_Given_Configuration_File_FIST \
        '"output_file" key has no valid folder as value' 'output_file /not-a-folder/file.txt'
    __static__Possibly_Fail_Validation_Test $? || return 1
    # Config file with incorrect value type for other keys
    local wrong_key_value
    for wrong_key_value in \
        'nevents 3.14' \
        'Bcanonical 3..14' \
        'Qcanonical false' \
        'shear_correction true' \
        'edens +-1'; do
        printf '%s\n' \
            "hypersurface_file $(which ls)" \
            'output_file .' \
            'particle_list_file .' \
            'decays_list_file .' \
            "${wrong_key_value}" > "${HYBRID_software_configuration_file[Sampler]}"
        __static__Validate_Given_Configuration_File_FIST \
            "'${wrong_key_value}' should not be accepted" "${mandatory_config_keys[@]}" "${wrong_key_value}"
        __static__Possibly_Fail_Validation_Test $? || return 1
    done
    # Validate base configuration file we ship in the codebase
    cp "${HYBRID_software_base_config_file[Sampler_FIST]}" "${HYBRID_software_configuration_file[Sampler]}"
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    touch "${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid
    if [[ $? -ne 0 ]]; then
        Print_Error 'Shipped sampler configuration unexpectedly detected as incorrect.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-validate-config-file-FIST()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-FIST
}

function Make_Test_Preliminary_Operations__Sampler-config-consistent-with-hydro-SMASH()
{
    __static__Do_Preliminary_Sampler_Setup_Operations
    HYBRID_given_software_sections+=('Hydro')
    HYBRID_software_executable[Hydro]="$(which echo)" # Use command as fake executable
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
}

function Unit_Test__Sampler-config-consistent-with-hydro-SMASH()
{
    HYBRID_module[Sampler]='SMASH'
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    # Hydro config file with default ecrit
    local -r ecrit_hydro='0.5'
    printf '%s   %s\n' "e_crit" "${ecrit_hydro}" > "${HYBRID_software_configuration_file[Hydro]}"
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    # Sampler config file with different ecrit
    local -r ecrit_entered='0.3'
    printf '%s   %s\n' "ecrit" "${ecrit_entered}" > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell \
        __static__Check_If_Sampler_Configuration_Is_Consistent_With_Hydro &> /dev/null
    local ecrit_found
    while read key value; do
        if [[ "${key}" = "ecrit" ]]; then
            ecrit_found="${value}"
        fi
    done < "${HYBRID_software_configuration_file[Sampler]}"
    if [[ "${ecrit_found}" != "${ecrit_hydro}" ]]; then
        Print_Error 'The value of ecrit was not correctly replaced in sampler config.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-config-consistent-with-hydro-SMASH()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-SMASH
}

function Make_Test_Preliminary_Operations__Sampler-test-run-software-SMASH()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file-SMASH
}

function __static__Run_Software_Sampler_And_Test_Outcome()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty 'terminal_output'
    local -r \
        version="$1" \
        reference_value="$2"
    HYBRID_software_version[Sampler]="${version}"
    local terminal_output_result
    Call_Codebase_Function_In_Subshell Run_Software_Sampler
    if [[ ! -f "${terminal_output}" ]]; then
        Print_Error 'The terminal output for version ' --emph "${version}" ' was not created.'
        return 1
    fi
    terminal_output_result=$(< "${terminal_output}")
    if [[ "${terminal_output_result}" != "${reference_value}" ]]; then
        Print_Error 'The terminal output for version ' --emph "${version}" ' has not the expected content.'
        Print_Debug "${terminal_output_result}" "${reference_value}"
        return 1
    fi
}

function Unit_Test__Sampler-test-run-software-SMASH()
{
    HYBRID_module[Sampler]='SMASH'
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    local -r terminal_output="${HYBRID_software_output_directory[Sampler]}/${HYBRID_terminal_output["Sampler"]}"
    __static__Run_Software_Sampler_And_Test_Outcome \
        '3.1.1' "events 1 ${HYBRID_software_configuration_file[Sampler]}" || return 1
    rm "${terminal_output}"
    __static__Run_Software_Sampler_And_Test_Outcome \
        '3.2' "--config ${HYBRID_software_configuration_file[Sampler]} --num 1" || return 1
}

function Clean_Tests_Environment_For_Following_Test__Sampler-test-run-software-SMASH()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-SMASH
}

function Make_Test_Preliminary_Operations__Sampler-test-run-software-FIST()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file-FIST
}

function Unit_Test__Sampler-test-run-software-FIST()
{
    HYBRID_module[Sampler]='FIST'
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    local -r terminal_output="${HYBRID_software_output_directory[Sampler]}/${HYBRID_terminal_output["Sampler"]}"
    local terminal_output_result correct_result
    Call_Codebase_Function_In_Subshell Run_Software_Sampler
    if [[ ! -f "${terminal_output}" ]]; then
        Print_Error 'The terminal output was not created.'
        return 1
    fi
    terminal_output_result=$(< "${terminal_output}")
    correct_result="${HYBRID_software_configuration_file[Sampler]}"
    if [[ "${terminal_output_result}" != "${correct_result}" ]]; then
        Print_Error 'The terminal output has not the expected content.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-test-run-software-FIST()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file-FIST
}
