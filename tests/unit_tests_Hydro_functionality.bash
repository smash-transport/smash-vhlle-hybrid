#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

#TODO IC ALREADY GIVEN


function Make_Test_Preliminary_Operations__Hydro-create-input-file()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'Hydro_functionality.bash'
        'global_variables.bash'
        'software_input_functionality.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
    HYBRID_output_directory="./test_dir_Hydro"
    HYBRID_software_base_config_file[Hydro]='vhlle_config_cool'
    HYBRID_given_software_sections=( 'IC' 'Hydro' )
    HYBRID_software_executable[IC]=$(which ls) # Use command as fake executable
    HYBRID_software_executable[Hydro]=$(which ls) # Use command as fake executable
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
    
}

function Unit_Test__Hydro-create-input-file()
{
    
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro
    touch "${HYBRID_software_input_file[Hydro]}"
    if [[ ! -f "${HYBRID_software_configuration_file[Hydro]}" ]]; then
        Print_Error 'The output directory and/or software input file were not properly created.'
        return 1
    fi
    rm -r "${HYBRID_output_directory}/"*
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro
    if [[ ! -f "${HYBRID_software_configuration_file[Hydro]}" ]]; then
        Print_Error 'The input file was not properly created in the output folder.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation of input with existent config succeeded.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Hydro-create-input-file()
{
    rm "${HYBRID_software_base_config_file[Hydro]}"
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Hydro-check-all-input()
{
    Make_Test_Preliminary_Operations__Hydro-create-input-file
}

function Unit_Test__Hydro-check-all-input()
{
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing output directory succeeded.'
        return 1
    fi
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    mkdir -p "${HYBRID_software_output_directory[IC]}"
    touch "${HYBRID_software_base_config_file[Hydro]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing config file succeeded.'
        return 1
    fi
    touch "${HYBRID_software_configuration_file[Hydro]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Hydro
    if [[ $? -ne 0 ]]; then
        Print_Error 'Ensuring existence of existing folder/file failed.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Hydro-check-all-input()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Hydro-test-run-software()
{
    Make_Test_Preliminary_Operations__Hydro-create-input-file
    #Make_Test_Preliminary_Operations__IC-create-input-file
}

function Unit_Test__Hydro-test-run-software()
{
    HYBRID_software_executable[Hydro]="${HYBRID_output_directory}/dummy_exec_Hydro.bash"
    echo "${HYBRID_software_output_directory[Hydro]}"
    local -r hydro_terminal_output="${HYBRID_software_output_directory[Hydro]}/Terminal_Output.txt"
    echo "${hydro_terminal_output}"
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    printf '#!/usr/bin/env bash\n\necho "$@"\n' > "${HYBRID_software_executable[Hydro]}"
    echo "${HYBRID_software_executable[Hydro]}"
    chmod a+x "${HYBRID_software_executable[Hydro]}"
    local terminal_output_result correct_result
    Call_Codebase_Function_In_Subshell Run_Software_Hydro
    if [[ ! -f "${hydro_terminal_output}" ]]; then
        Print_Error 'The terminal output was not created.'
        return 1
    fi
    terminal_output_result=$(< "${hydro_terminal_output}")
    correct_result="-i ${HYBRID_software_configuration_file[Hydro]} -o ${HYBRID_software_output_directory[Hydro]} -n"
    if [[ "${terminal_output_result}" != "${correct_result}" ]]; then
        Print_Error 'The terminal output has not the expected content.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Hydro-test-run-software()
{
    Clean_Tests_Environment_For_Following_Test__Hydro-check-all-input
}
