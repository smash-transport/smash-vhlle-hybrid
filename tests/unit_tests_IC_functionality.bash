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
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__IC-create-input-file()
{
    HYBRID_output_directory="./test_dir_IC"
    if [[ -d "${HYBRID_output_directory}" ]]; then
        rm -r "${HYBRID_output_directory}"
    fi
    mkdir "${HYBRID_output_directory}"

    Prepare_Software_Input_File_IC
    IC_config_name=$(basename "${HYBRID_software_base_config_file[IC]}")
    IC_input_file_path="${HYBRID_output_directory}/IC/${IC_config_name}"
    if [[ ! -f "${IC_input_file_path}" ]]; then
        Print_Error 'The config was not properly created.'
        return 1
    fi
    ( Prepare_Software_Input_File_IC &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Failed checking the existens of the config.'
        return 1
    fi
    return 0
}

function Make_Test_Preliminary_Operations__IC-check-all-input()
{
    Make_Test_Preliminary_Operations__IC-create-input-file
}

function Unit_Test__IC-check-all-input()
{
    HYBRID_output_directory="./test_dir_IC"
    if [[ -d "${HYBRID_output_directory}" ]]; then
        rm -r "${HYBRID_output_directory}"
    fi
    mkdir "${HYBRID_output_directory}"

    ( Ensure_All_Needed_Input_Exists_IC &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of input directory failed.'
        return 1
    fi
    mkdir "${HYBRID_output_directory}/IC"
    ( Ensure_All_Needed_Input_Exists_IC &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of the config file failed.'
        return 1
    fi
    return 0
}

function Make_Test_Preliminary_Operations__IC-test-run-software()
{
    Make_Test_Preliminary_Operations__IC-create-input-file
}

function Unit_Test__IC-test-run-software()
{
    HYBRID_output_directory="test_dir_IC"
    if [[ -d "${HYBRID_output_directory}" ]]; then
        rm -r "${HYBRID_output_directory}"
    fi
    local IC_exec_directory="${HYBRID_output_directory}/IC"
    mkdir -p "${IC_exec_directory}"

    HYBRID_software_executable[IC]="${HYBRID_output_directory}/dummy_exec_IC.sh"
    touch "${HYBRID_software_executable[IC]}"
    echo "#!/bin/bash" >> "${HYBRID_software_executable[IC]}"
    echo "echo \$@" >> "${HYBRID_software_executable[IC]}"
    chmod u+x "${HYBRID_software_executable[IC]}"

    local IC_config_name=$(basename "${HYBRID_software_base_config_file[IC]}")
    local IC_input_file_path="${HYBRID_output_directory}/IC/${IC_config_name}"
    touch "${IC_input_file_path}"

    Run_Software_IC
    local IC_terminal_output="${HYBRID_output_directory}/IC/Terminal_Output.txt"
    if [[ ! -f "${IC_terminal_output}" ]]; then
        Print_Error 'The terminal output was not created.'
        return 1
    fi
    local terminal_output_result=$(head "${IC_terminal_output}")
    local correct_result="-i ${IC_input_file_path} -o ${IC_exec_directory} -n"
    if [[ "${terminal_output_result}" != "${correct_result}" ]]; then
        Print_Error 'The terminal output has not the expected content.'
        return 1
    fi
    return 0
}
