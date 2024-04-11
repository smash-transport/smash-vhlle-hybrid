#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__Hydro-create-input-file()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'common_functionality.bash'
        'Hydro_functionality.bash'
        'global_variables.bash'
        'software_input_functionality.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
    HYBRID_output_directory="${HYBRIDT_folder_to_run_tests}/test_dir_Hydro"
    HYBRID_software_base_config_file[Hydro]='vhlle_config_cool'
    HYBRID_given_software_sections=('Hydro')
    # To test the generic case, create symbolic link to dummy executable
    ln -s "$(which echo)" "${PWD}/dummy_exec"
    HYBRID_software_executable[Hydro]="${PWD}/dummy_exec"
    # Touch dummy empty handler config as this is always there in sanity checks
    touch "${HYBRID_configuration_file}"
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
}

function Unit_Test__Hydro-create-input-file()
{
    local -r ic_file="${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    touch "${HYBRID_software_base_config_file[Hydro]}"
    mkdir 'eos'
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro
    if [[ ! -f "${HYBRID_software_configuration_file[Hydro]}" ]]; then
        Print_Error 'The config was not properly created in the output folder.'
        return 1
    elif [[ ! -L "${ic_file}" ]]; then
        Print_Error 'The symbolic link to the IC file was not properly created in the output folder.'
        return 1
    fi
    rm "${HYBRID_software_output_directory[Hydro]}"/*
    touch "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro &> /dev/null
    if [[ ! -f "${ic_file}" ]]; then
        Print_Error 'The already existing ic regular file was somehow lost.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro &> /dev/null
    if [[ $? -ne ${HYBRID_fatal_logic_error} ]]; then
        Print_Error \
            'Preparation of input with existent did not fail with exit code ' \
            --emph "${HYBRID_fatal_logic_error}" ' as expected.'
        return 1
    fi
    rm -r "${HYBRID_software_output_directory[Hydro]}"/*
    mkdir "${HYBRID_software_output_directory[Hydro]}/eos"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation succeeded even though the eos folder already exists.'
        return 1
    fi
    rm -r "${HYBRID_software_output_directory[Hydro]}"/*
    touch "${HYBRID_software_output_directory[Hydro]}/eos"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation succeeded even though a file called eos already exists.'
        return 1
    fi
    rm "${HYBRID_software_output_directory[Hydro]}"/*
    ln -s ~ "${HYBRID_software_output_directory[Hydro]}/eos"
    # Suppress logging to file descriptor 9 to suppress the warning
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro 9> /dev/null
    if [[ $? -ne 0 ]]; then
        Print_Error 'Preparation failed to replace existing symlink.'
        return 1
    fi
    rm -r "${HYBRID_software_output_directory[Hydro]}"/*
    ln -s "${PWD}/eos" "${HYBRID_software_output_directory[Hydro]}/eos"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro
    if [[ $? -ne 0 ]]; then
        Print_Error 'Preparation failed although the correct symlink exists.'
        return 1
    fi
    rm -r 'eos'
    rm "${HYBRID_software_output_directory[Hydro]}"/*
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation succeeded even though the eos folder does not exist.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Hydro-create-input-file()
{
    rm "${HYBRID_software_base_config_file[Hydro]}" 'dummy_exec'
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
    mkdir -p \
        "${HYBRID_software_output_directory[Hydro]}" \
        "${HYBRID_software_output_directory[IC]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing config file succeeded.'
        return 1
    fi
    touch "${HYBRID_software_configuration_file[Hydro]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing link to IC file succeeded.'
        return 1
    fi
    ln -s 'not-existing-target' "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Hydro &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of broken link to IC file succeeded.'
        return 1
    fi
    touch "${HYBRID_software_output_directory[IC]}/SMASH_IC.dat"
    ln -s -f \
        "${HYBRID_software_output_directory[IC]}/SMASH_IC.dat" \
        "${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Hydro &> /dev/null
    if [[ $? -ne 0 ]]; then
        Print_Error 'Ensuring existence of existing folder/file failed.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Hydro-check-all-input()
{
    rm -r "${HYBRID_output_directory}" 'dummy_exec'
}

function Make_Test_Preliminary_Operations__Hydro-test-run-software()
{
    Make_Test_Preliminary_Operations__Hydro-create-input-file
}

function Unit_Test__Hydro-test-run-software()
{
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    local -r \
        hydro_terminal_output="${HYBRID_software_output_directory[Hydro]}/${HYBRID_terminal_output["Hydro"]}" \
        Hydro_config_file_path="${HYBRID_software_configuration_file[Hydro]}" \
        IC_output_file_path="${HYBRID_software_output_directory[Hydro]}/SMASH_IC.dat"
    local terminal_output_result correct_result
    Call_Codebase_Function_In_Subshell Run_Software_Hydro
    if [[ ! -f "${hydro_terminal_output}" ]]; then
        Print_Error 'The terminal output was not created.'
        return 1
    fi
    terminal_output_result=$(< "${hydro_terminal_output}")
    printf -v correct_result '%s' \
        "-params ${Hydro_config_file_path} " \
        "-ISinput ${IC_output_file_path} " \
        "-outputDir ${HYBRID_software_output_directory[Hydro]}"
    if [[ "${terminal_output_result}" != "${correct_result}" ]]; then
        Print_Error 'The terminal output has not the expected content.'
        return 1
    fi

}

function Clean_Tests_Environment_For_Following_Test__Hydro-test-run-software()
{
    Clean_Tests_Environment_For_Following_Test__Hydro-check-all-input
}
