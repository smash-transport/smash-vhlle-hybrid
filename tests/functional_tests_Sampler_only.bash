 #===================================================
 #
 #    Copyright (c) 2023
 #      SMASH Hybrid Team
 #
 #    GNU General Public License (GPLv3 or later)
 #
 #===================================================

 function Functional_Test__do-Sampler-only()
 {
     #how to define the output directory
     shopt -s nullglob
     local -r Hybrid_handler_config='hybrid_config'
     local output_files
     mkdir -p './Hydro'
     touch './Hydro/freezeout.dat'
     printf '
     Sampler:
       Executable: %s/tests/mocks/sampler_black_box.py
       Software_keys:
         surface: %s
         spectra_dir: %s
     ' "${HYBRIDT_repository_top_level_path}"\
       "Hydro/freezeout.dat"\
       "Sampler" > "${Hybrid_handler_config}"
     # Expect success and test presence of particle_lists
     Print_Info 'Running Hybrid-handler expecting success'
     Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${Hybrid_handler_config}"
     if [[ $? -ne 0 ]]; then
         Print_Error 'Hybrid-handler unexpectedly failed.'
         return 1
     fi
     output_files=( Sampler/* )
     if [[ ${#output_files[@]} -ne 3 ]]; then
         Print_Error 'Expected ' --emph '3' " output files, but ${#output_files[@]} found."
         return 1
     fi
     mv 'Sampler' 'Sampler-success'

     # Expect failure and test terminal output
     Print_Info 'Running Hybrid-handler expecting crash in Sampler'
     BLACK_BOX_FAIL='true'\
         Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${Hybrid_handler_config}"
     if [[ $? -eq 0 ]]; then
         Print_Error 'Hybrid-handler unexpectedly succeeded with Sampler crashing.'
         return 1
     fi
     mv 'Sampler' 'Sampler-crash'

     # Expect failure
     Print_Info 'Running Hybrid-handler expecting invalid config argument'
     BLACK_BOX_FAIL='false'
     mkdir -p Sampler
     local -r invalid_sampler_config="invalid_hadron_sampler"
     local terminal_output_file='Sampler/Terminal_Output.txt'
     touch "${invalid_sampler_config}"
     printf '
     Sampler:
       Executable: %s/tests/mocks/sampler_black_box.py
       Input_file: %s
     ' "${HYBRIDT_repository_top_level_path}"\
       "${invalid_sampler_config}" > "${Hybrid_handler_config}"
     Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${Hybrid_handler_config}"\
     > "${terminal_output_file}"
     if [[ $? -eq 0 ]]; then
         Print_Error 'Hybrid-handler unexpectedly succeeded with invalid config for Sampler.'
         return 1
     elif [[ ! -f "${terminal_output_file}" ]]; then
         Print_Error 'File ' --emph "${terminal_output_file}" ' not found.'
         return 1
     fi
     rm "${invalid_sampler_config}"
     mv 'Sampler' 'Sampler-invalid-config'

 } 