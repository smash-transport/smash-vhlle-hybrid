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
     HYBRID_output_directory="./test_dir_Sampler"
     HYBRID_software_base_config_file[Sampler]='fake_sampler_config'
     HYBRID_given_software_sections=('Sampler')
     HYBRID_software_output_directory[Hydro]="${HYBRID_output_directory}/Hydro"
     HYBRID_software_executable[Sampler]="${HYBRID_output_directory}/dummy_exec_Sampler.bash"
     mkdir -p ${HYBRID_output_directory}
     printf '#!/usr/bin/env bash\n\necho "$@"\n' > "${HYBRID_software_executable[Sampler]}"
     chmod a+x "${HYBRID_software_executable[Sampler]}"
     Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables

 }

 function Unit_Test__Sampler-create-input-file()
 {
     touch "${HYBRID_software_base_config_file[Sampler]}"
     mkdir -p "${HYBRID_software_output_directory[Hydro]}"
     local -r plist_hydro="${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
     touch "${plist_hydro}"
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
     rm -r "${HYBRID_output_directory}/"*
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
     mkdir -p "${HYBRID_software_output_directory[Sampler]}" \
              "${HYBRID_software_output_directory[Hydro]}"
     Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
     if [[ $? -eq 0 ]]; then
         Print_Error 'Ensuring existence of not-existing config file succeeded, although failure was expected.'
         return 1
     fi
     touch "${HYBRID_software_configuration_file[Sampler]}" \
           "${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
     Call_Codebase_Function_In_Subshell Ensure_All_Needed_Input_Exists_Sampler &> /dev/null
     if [[ $? -ne 0 ]]; then
         Print_Error 'Ensuring existence of existing folder/file failed.'
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
     local -r Sampler_terminal_output="${HYBRID_output_directory}/Sampler/Terminal_Output.txt"\
              Sampler_config_file_path="${HYBRID_software_configuration_file[Sampler]}"\
              Hydro_output_file_path="${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
     local terminal_output_result correct_result
     Call_Codebase_Function_In_Subshell Run_Software_Sampler
     if [[ ! -f "${Sampler_terminal_output}" ]]; then
         Print_Error 'The terminal output was not created.'
         return 1
     fi
     terminal_output_result=$(< "${Sampler_terminal_output}")
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