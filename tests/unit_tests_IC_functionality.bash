#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function __static__Do_Preliminary_IC_Setup_Operations()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'common_functionality.bash'
        'IC_functionality.bash'
        'global_variables.bash'
        'software_input_functionality.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
    HYBRID_output_directory="${HYBRIDT_folder_to_run_tests}/test_dir_IC"
    HYBRID_given_software_sections=('IC')
    HYBRID_software_executable[IC]="${HYBRIDT_tests_folder}/mocks/echo.py"
    # Touch dummy empty handler config as this is always there in sanity checks
    touch "${HYBRID_configuration_file}"
}

function Make_Test_Preliminary_Operations__IC-pick-correct-base-config()
{
    __static__Do_Preliminary_IC_Setup_Operations
}

function __static__Is_Picked_IC_Base_Config_Correct_For_Version()
{
    export MOCK_ECHO_VERSION="$1"
    local -r expected_filename="$2"
    Call_Codebase_Function __static__Set_Software_Version 'IC'
    Call_Codebase_Function __static__Choose_Base_Configuration_File 'IC'
    [[ $(basename "${HYBRID_software_base_config_file[IC]}") == ${expected_filename} ]]
}

function Unit_Test__IC-pick-correct-base-config()
{
    # Call the function above in a sub-shell to avoid exiting the test in case of failure
    if ! (__static__Is_Picked_IC_Base_Config_Correct_For_Version '3.2' 'smash_initial_conditions__ge_v3.2.yaml'); then
        Print_Error 'The base configuration file was not properly picked for version ' --emph '3.2' '.'
        return 1
    fi
    if ! (__static__Is_Picked_IC_Base_Config_Correct_For_Version '3.1' 'smash_initial_conditions__lt_v3.2.yaml'); then
        Print_Error 'The base configuration file was not properly picked for version ' --emph '3.1' '.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__IC-pick-correct-base-config()
{
    :
}

function Make_Test_Preliminary_Operations__IC-create-input-file()
{
    __static__Do_Preliminary_IC_Setup_Operations
    export MOCK_ECHO_VERSION=3.1
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
    # Since we use our mock of echo as fake IC executable the function above will set the
    # IC version to the MOCK_ECHO_VERSION environment variable value.
}

function Unit_Test__IC-create-input-file()
{
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_IC
    if [[ ! -f "${HYBRID_software_configuration_file[IC]}" ]]; then
        Print_Error 'The output directory and/or software input file were not properly created.'
        return 1
    fi
    rm -r "${HYBRID_output_directory}/"*
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_IC
    if [[ ! -f "${HYBRID_software_configuration_file[IC]}" ]]; then
        Print_Error 'The input file was not properly created in the output folder.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_IC &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation of input with existent config succeeded.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__IC-create-input-file()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__IC-check-all-input()
{
    Make_Test_Preliminary_Operations__IC-create-input-file
}

function Unit_Test__IC-check-all-input()
{
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_IC &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing output directory succeeded.'
        return 1
    fi
    mkdir -p "${HYBRID_software_output_directory[IC]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_IC &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing config file succeeded.'
        return 1
    fi
    touch "${HYBRID_software_configuration_file[IC]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_IC
    if [[ $? -ne 0 ]]; then
        Print_Error 'Ensuring existence of existing folder/file failed.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__IC-check-all-input()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__IC-test-run-software()
{
    Make_Test_Preliminary_Operations__IC-create-input-file
}

function Unit_Test__IC-test-run-software()
{
    local -r ic_terminal_output="${HYBRID_software_output_directory[IC]}/${HYBRID_terminal_output["IC"]}"
    mkdir -p "${HYBRID_software_output_directory[IC]}"
    local terminal_output_result correct_result
    Call_Codebase_Function_In_Subshell Run_Software_IC
    if [[ ! -f "${ic_terminal_output}" ]]; then
        Print_Error 'The terminal output was not created.'
        return 1
    fi
    terminal_output_result=$(< "${ic_terminal_output}")
    correct_result="-i ${HYBRID_software_configuration_file[IC]} -o ${HYBRID_software_output_directory[IC]} -n"
    if [[ "${terminal_output_result}" != "${correct_result}" ]]; then
        Print_Error 'The terminal output has not the expected content.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__IC-test-run-software()
{
    Clean_Tests_Environment_For_Following_Test__IC-check-all-input
}
