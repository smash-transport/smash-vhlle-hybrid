#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# function Make_Test_Preliminary_Operations__Hydro-create-input()
# {
#     local file_to_be_sourced list_of_files
#     list_of_files=(
#         'Hydro_functionality.bash'
#         'global_variables.bash'
#         'software_input_functionality.bash'
#         'sanity_checks.bash'
#     )
#     for file_to_be_sourced in "${list_of_files[@]}"; do
#         source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
#     done
#     Define_Further_Global_Variables
#     HYBRID_output_directory="./test_dir_Hydro"
#     HYBRID_software_base_config_file[Hydro]="${HYBRID_output_directory}/vhlle_config_cool"
#     HYBRID_given_software_sections=('Hydro' )
#     HYBRID_software_output_directory[IC]="${HYBRID_output_directory}/IC"
#     HYBRID_software_executable[Hydro]="../mocks/vhlle_black-box.py"
#     mkdir -p ${HYBRID_output_directory} ${HYBRID_software_output_directory[IC]}
#     touch "${HYBRID_software_base_config_file[Hydro]}"
#     touch "${HYBRID_software_output_directory[IC]}/SMASH_IC.dat"
#     Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables
    
# }

# function Make_Test_Preliminary_Operations__Hydro-execute()
# {
#     Make_Test_Preliminary_Operations__Hydro-create-input
# }

# function Functional_Test__Hydro-execute()
# {   
#     #cd "${HYBRID_output_directory}"
#     Call_Codebase_Function_In_Subshell Prepare_Software_Input_File_Hydro
#     Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Hydro
#     Call_Codebase_Function_In_Subshell Run_Software_Hydro
#     terminal_output=$(tail -n1 ${HYBRID_software_output_directory[Hydro]}/Terminal_Output.txt)
#     if [[ "$terminal_output" != *'-nan'* ]]
#     then
#         Print_Error 'Hydro terminal output contains an error!'
#         return 1
#     fi
#     if [[ ! -f "${HYBRID_software_output_directory[Hydro]}/freezeout.dat" ]]
#     then
#         Print_Error 'Hydro output was not created!'
#         return 1
#     fi

#     return 1
# }

function Functional_Test__do-Hydro-only()
{
    #how to define the output directory
    shopt -s nullglob
    local -r config_filename='vhlle_hydro'
    local -r input_filename='SMASH_IC.dat'
    local unfinished_files output_files terminal_output_file failure_message
    printf '
    Hydro:
      Executable: %s/tests/mocks/vhlle_black-box.py
      Output_directory: ../IC/
    ' "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    # Expect success and test presence of freezeout
    mkdir -p './IC'
    touch './IC/SMASH_IC.dat'
    ls
    cd IC
    ls
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    
    output_files=( Hydro/* )
    if [[ ${#output_files[@]} -ne 3 ]]; then
        Print_Error 'Expected ' --emph '3' " output files, but ${#output_files[@]} found."
        return 1
    fi
    mv 'Hydro' 'Hydro-success'
    # Expect failure
    Print_Info 'Running Hybrid-handler expecting invalid Hydro input file failure'
    terminal_output_file='Hydro/Terminal_Output.txt'
    #we have some bad input here
    # BLACK_BOX_FAIL='invalid_config'\
    #     Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    # if [[ $? -eq 0 ]]; then
    #     Print_Error 'Hybrid-handler unexpectedly succeeded with invalid IC input.'
    #     return 1
    # elif [[ ! -f "${terminal_output_file}" ]]; then
    #     Print_Error 'File ' --emph "${terminal_output_file}" ' not found.'
    #     return 1
    # fi
    # failure_message=$(tail -n 1 "${terminal_output_file}" | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g')
    # if [[ "${failure_message}" != 'Validation of SMASH input failed.' ]]; then
    #     Print_Error 'Unexpected failure message: ' --emph "${failure_message}"
    #     return 1
    # fi
    # mv 'IC' 'IC-invalid-config'
    # # Expect failure and test "SMASH" unfinished/lock files
    # Print_Info 'Running Hybrid-handler expecting crash in IC software'
    # BLACK_BOX_FAIL='smash_crashes'\
    #     Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    # if [[ $? -eq 0 ]]; then
    #     Print_Error 'Hybrid-handler unexpectedly succeeded with IC software crashing.'
    #     return 1
    # fi
    # unfinished_files=( IC/*.{unfinished,lock} )
    # if [[ ${#unfinished_files[@]} -ne 3 ]]; then
    #     Print_Error 'Expected ' --emph '3' " unfinished/lock files, but ${#unfinished_files[@]} found."
    #     return 1
    # fi
    # mv 'IC' 'IC-software-crash'
}