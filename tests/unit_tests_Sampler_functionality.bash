#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__Sampler-create-input-file()
{
   local file_to_be_sourced list_of_files
    list_of_files=(
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
    HYBRID_software_base_config_file[Sampler]='fake_sampler_config'
    HYBRID_given_software_sections=('Sampler')
    HYBRID_software_output_directory[Hydro]="${HYBRID_output_directory}/Hydro"
    HYBRID_software_executable[Sampler]="$(which echo)"
    Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
}

function Unit_Test__Sampler-create-input-file()
{
    printf '%s\n' \
        'surface          ../Hydro/freezeout.dat' \
        'spectra_dir      .' \
        > "${HYBRID_software_base_config_file[Sampler]}"
    mkdir -p "${HYBRID_software_output_directory[Hydro]}"
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Sampler
    if [[ ! -f "${HYBRID_software_configuration_file[Sampler]}" ]]; then
        Print_Error 'The output directory and/or software input file were not properly created.'
        return 1
    fi
    Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Preparation of input with existent config succeeded.'
        return 1
    fi

    # Ensure that paths in Sampler config were replaced by global paths
    local surface_path spectra_dir_path
    surface_path=$(awk '$1 == "surface" {print $2; exit}' \
                       "${HYBRID_software_configuration_file[Sampler]}")
    spectra_dir_path=$(awk '$1 == "spectra_dir" {print $2; exit}' \
                           "${HYBRID_software_configuration_file[Sampler]}")
    if [[ "${surface_path}" != /* || "${spectra_dir_path}" != /* ]]; then
        Print_Error 'freezeout and/or output directory path in Sampler config is not a global path.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-create-input-file()
{
    rm "${HYBRID_software_base_config_file[Sampler]}"
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
        Print_Error 'Ensuring existence of not-existing output directory succeeded, although failure was expected.'
        return 1
    fi
    mkdir -p "${HYBRID_software_output_directory[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing config file succeeded, although failure was expected.'
        return 1
    fi
    touch "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring correctness of empty sampler input file succeeded, although failure was expected.'
        return 1
    fi
    printf 'surface not-existing-file\n' > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Ensuring existence of not-existing freezeout surface file succeeded.'
        return 1
    fi
    printf 'surface %s\n' "$(which ls)" > "${HYBRID_software_configuration_file[Sampler]}"
    Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
    if [[ $? -ne 0 ]]; then
        Print_Error 'Ensuring existence of all input files unexpectedly failed.'
        return 1
    fi
}

function Clean_Tests_Environment_For_Following_Test__Sampler-check-all-input()
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
    local -r sampler_terminal_output="${HYBRID_software_output_directory[Sampler]}/Terminal_Output.txt"\
             sampler_config_file_path="${HYBRID_software_configuration_file[Sampler]}"
    local terminal_output_result correct_result
    Call_Codebase_Function_In_Subshell Run_Software_Sampler
    if [[ ! -f "${sampler_terminal_output}" ]]; then
        Print_Error 'The terminal output was not created.'
        return 1
    fi
    terminal_output_result=$(< "${sampler_terminal_output}")
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
