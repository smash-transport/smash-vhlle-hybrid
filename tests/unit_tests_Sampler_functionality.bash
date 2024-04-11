#===================================================
#
#    Copyright (c) 2023-2024
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
    HYBRID_software_executable[Sampler]="$(which echo)"
    # Touch dummy empty handler config as this is always there in sanity checks
    touch "${HYBRID_configuration_file}"
}

function Make_Test_Preliminary_Operations__Sampler-create-input-file()
{
    __static__Do_Preliminary_Sampler_Setup_Operations
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
}

function Unit_Test__Sampler-create-input-file()
{
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

function Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Sampler-check-all-input()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file
}

function Unit_Test__Sampler-check-all-input()
{
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
        "spectra_dir ${HOME}" > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler
    if [[ $? -ne 0 ]]; then
        Print_Error 'Ensuring existence of all input files unexpectedly failed.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-check-all-input()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Sampler-validate-config-file()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file
}

function Unit_Test__Sampler-validate-config-file()
{
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    cd "${HYBRID_software_output_directory[Sampler]}"
    # Empty config file
    touch "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although config file is empty.'
        return 1
    fi
    # Too many columns in config file
    printf '%s\n' 'surface whatever wrong' > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although config file has wrong number of columns.'
        return 1
    fi
    # Repeated key in config file
    printf '%s\n' 'spectra_dir ~' 'spectra_dir ~' > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although config file has repeated lines.'
        return 1
    fi
    # Config file with invalid key
    printf '%s\n' 'invalidKey value' > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although config file has invalid key.'
        return 1
    fi
    # Config file missing required key 'surface'
    printf '%s\n' 'spectra_dir .' > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although config file does not contain "surface" key.'
        return 1
    fi
    # Config file missing required key 'spectra_dir'
    printf '%s\n' "surface $(which ls)" > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although config file does not contain "spectra_dir" key.'
        return 1
    fi
    # Config file with incorrect surface
    printf '%s\n' 'surface not-a-file' > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although surface key has no string as value.'
        return 1
    fi
    # Config file with incorrect spectra_dir
    printf '%s\n' "spectra_dir $(which ls)" > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Config validation passed although spectra_dir key has no directory as value.'
        return 1
    fi
    # Config file with incorrect value type for other keys
    local wrong_key_value
    for wrong_key_value in \
        'number_of_events 3.14' \
        'rescatter 3..14' \
        'weakContribution false' \
        'shear true' \
        'ecrit +-1' \
        'Nbins -100' \
        'q_max 1.6'; do
        printf '%s\n' "${wrong_key_value}" > "${HYBRID_software_configuration_file[Sampler]}"
        Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid &> /dev/null
        if [[ $? -eq 0 ]]; then
            Print_Error "Unexpected success: Key '${wrong_key_value}' accepted."
            return 1
        fi
    done
    # Validate base configuration file we ship in the codebase
    cp "${HYBRID_software_base_config_file[Sampler]}" "${HYBRID_software_configuration_file[Sampler]}"
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    touch "${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
    Call_Codebase_Function_In_Subshell __static__Is_Sampler_Config_Valid
    if [[ $? -ne 0 ]]; then
        Print_Error 'Shipped sampler configuration unexpectedly detected as incorrect.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-validate-config-file()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Sampler-config-consistent-with-hydro()
{
    __static__Do_Preliminary_Sampler_Setup_Operations
    HYBRID_given_software_sections+=('Hydro')
    HYBRID_software_executable[Hydro]="$(which echo)" # Use command as fake executable
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
}

function Unit_Test__Sampler-config-consistent-with-hydro()
{
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    # Hydro config file with default ecrit
    touch "${HYBRID_software_configuration_file[Hydro]}"
    local ecrit_hydro
    ecrit_hydro='0.5'
    printf '%s   %s\n' "e_crit" "${ecrit_hydro}" > "${HYBRID_software_configuration_file[Hydro]}"
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    # Sampler config file with different ecrit
    local ecrit_entered
    ecrit_entered='0.3'
    touch "${HYBRID_software_configuration_file[Sampler]}"
    printf '%s   %s\n' "ecrit" "${ecrit_entered}" > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell __static__Check_If_Sampler_Configuration_Is_Consistent_With_Hydro &> /dev/null
    local ecrit_found
    while read key value; do
        if [[ "${key}" = "ecrit" ]]; then
            ecrit_found="${value}"
        fi
    done < "${HYBRID_software_configuration_file[Sampler]}"
    if ! [[ "${ecrit_found}" = "${ecrit_hydro}" ]]; then
        Print_Error 'The value of ecrit was not correctly replaced in sampler config.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-config-consistent-with-hydro()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Sampler-test-run-software()
{
    Make_Test_Preliminary_Operations__Sampler-create-input-file
}

function Unit_Test__Sampler-test-run-software()
{
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    local -r terminal_output="${HYBRID_software_output_directory[Sampler]}/${HYBRID_terminal_output["Sampler"]}"
    local terminal_output_result correct_result
    Call_Codebase_Function_In_Subshell Run_Software_Sampler
    if [[ ! -f "${terminal_output}" ]]; then
        Print_Error 'The terminal output was not created.'
        return 1
    fi
    terminal_output_result=$(< "${terminal_output}")
    correct_result="events 1 ${HYBRID_software_configuration_file[Sampler]}"
    if [[ "${terminal_output_result}" != "${correct_result}" ]]; then
        Print_Error 'The terminal output has not the expected content.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-test-run-software()
{
    Clean_Tests_Environment_For_Following_Test__Sampler-check-all-input
}
