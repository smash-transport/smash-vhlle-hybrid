#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__IC-create-input-file()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
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
    HYBRID_software_base_config_file[IC]='my_cool_conf.yaml'
    HYBRID_given_software_sections=('IC')
    HYBRID_software_executable[IC]=$(which echo) # Use command as fake executable
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
}

function Unit_Test__IC-create-input-file()
{
    touch "${HYBRID_software_base_config_file[IC]}"
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
    rm "${HYBRID_software_base_config_file[IC]}"
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
    local -r ic_terminal_output="${HYBRID_software_output_directory[IC]}/Terminal_Output.txt"
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
