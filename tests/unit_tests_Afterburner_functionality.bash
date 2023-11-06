#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__Afterburner-create-input-file()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'Afterburner_functionality.bash'
        'global_variables.bash'
        'software_input_functionality.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
    HYBRID_output_directory="${HYBRIDT_tests_folder}/test_dir_Afterburner"
    HYBRID_software_base_config_file[Afterburner]='my_cool_conf.yaml'
    HYBRID_given_software_sections=( 'Afterburner' )
    HYBRID_software_executable[Afterburner]=$(which echo) # Use command as fake executable
    HYBRID_software_output_directory[Sampler]="${HYBRID_output_directory}/Sampler"
    HYBRID_software_output_directory[IC]="${HYBRID_output_directory}/IC"
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
    Perform_Sanity_Checks_On_Existence_Of_External_Python_Scripts
}

function Unit_Test__Afterburner-create-input-file()
{
    touch "${HYBRID_software_base_config_file[Afterburner]}"
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    local -r\
        plist_Sampler="${HYBRID_software_output_directory[Sampler]}/particle_lists.oscar"\
        plist_Final="${HYBRID_software_output_directory[Afterburner]}/sampling0"
    touch "${plist_Sampler}"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Afterburner
    if [[ ! -f "${HYBRID_software_configuration_file[Afterburner]}" ]]; then
        Print_Error 'The input file was not properly created in the output folder.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Afterburner &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation of input with existent config succeeded.'
        return 1
    fi
    rm -r "${HYBRID_output_directory}/"*
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Afterburner  &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation of input succeeded even though the particle_list.oscar does not exist.'
        return 1
    fi
    rm -r "${HYBRID_output_directory}/"*
}

function Clean_Tests_Environment_For_Following_Test__Afterburner-create-input-file()
{
    rm "${HYBRID_software_base_config_file[Afterburner]}"
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Afterburner-create-input-file-with-spectators()
{
    Make_Test_Preliminary_Operations__Afterburner-create-input-file
}

function Unit_Test__Afterburner-create-input-file-with-spectators()
{
    HYBRID_optional_feature[Add_Spectators_From_IC]='TRUE'
    touch "${HYBRID_software_base_config_file[Afterburner]}"
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    local -r\
        plist_Sampler="${HYBRID_software_output_directory[Sampler]}/particle_lists.oscar"\
        plist_IC="${HYBRID_software_output_directory[IC]}/SMASH_IC.oscar"\
        plist_Final="${HYBRID_software_output_directory[Afterburner]}/sampling0"
    touch "${plist_Sampler}"
    rm -r "${HYBRID_output_directory}/"*
    mkdir -p "${HYBRID_software_output_directory[IC]}" "${HYBRID_software_output_directory[Sampler]}"
    touch "${plist_Sampler}" "${plist_Final}"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Afterburner  &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation succeeded even though the final particle list already exists.'
        return 1
    fi
    rm "${plist_Final}" "${HYBRID_output_directory}/Afterburner/"*
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Afterburner  &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation succeeded even though the config.yaml of the IC does not exist.'
        return 1
    fi
    rm "${HYBRID_output_directory}/Afterburner/"*
    touch "${HYBRID_software_output_directory[IC]}/config.yaml"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Afterburner  &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation succeeded even though the SMASH_IC.oscar does not exist.'
        return 1
    fi
    rm -r "${HYBRID_output_directory}/"*
    mkdir -p "${HYBRID_software_output_directory[IC]}" "${HYBRID_software_output_directory[Sampler]}" "${HYBRID_software_output_directory[Afterburner]}"
    touch "${HYBRID_software_output_directory[IC]}/config.yaml" "${plist_Sampler}" "${plist_IC}"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Afterburner
    if [[ ! -f "${plist_Final}" ]]; then
        Print_Error 'The final input file was not properly created in the output folder.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Afterburner-create-input-file-with-spectators()
{
    Clean_Tests_Environment_For_Following_Test__Afterburner-create-input-file
}

function Make_Test_Preliminary_Operations__Afterburner-check-all-input()
{
    Make_Test_Preliminary_Operations__Afterburner-create-input-file
}

function Unit_Test__Afterburner-check-all-input()
{
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Afterburner &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing output directory succeeded.'
        return 1
    fi
    mkdir -p "${HYBRID_software_output_directory[Afterburner]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Afterburner &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing config file succeeded.'
        return 1
    fi
    touch "${HYBRID_software_configuration_file[Afterburner]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Afterburner &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of input file succeeded.'
        return 1
    fi
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    touch "${HYBRID_software_output_directory[Afterburner]}/sampling0"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Afterburner
    if [[ $? -ne 0 ]]; then
        Print_Error 'Ensuring existence of existing folder/file succeeded.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Afterburner-check-all-input()
{
    rm -r "${HYBRID_output_directory}"
}

function Make_Test_Preliminary_Operations__Afterburner-test-run-software()
{
    Make_Test_Preliminary_Operations__Afterburner-create-input-file
}

function Unit_Test__Afterburner-test-run-software()
{
    mkdir -p "${HYBRID_software_output_directory[Afterburner]}"
    local -r afterburner_terminal_output="${HYBRID_output_directory}/Afterburner/Terminal_Output.txt"
    local terminal_output_result correct_result
    Call_Codebase_Function_In_Subshell Run_Software_Afterburner
    if [[ ! -f "${afterburner_terminal_output}" ]]; then
        Print_Error 'The terminal output was not created.'
        return 1
    fi
    terminal_output_result=$(< "${afterburner_terminal_output}")
    correct_result="-i ${HYBRID_software_configuration_file[Afterburner]} -o ${HYBRID_software_output_directory[Afterburner]} -n"
    if [[ "${terminal_output_result}" != "${correct_result}" ]]; then
        Print_Error 'The terminal output has not the expected content.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Afterburner-test-run-software()
{
    Clean_Tests_Environment_For_Following_Test__Afterburner-check-all-input
}
