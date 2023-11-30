#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function __static__Check_Successful_Handler_Run()
{
    if [[ $1 -ne 0 ]]; then
        exit_code=${HYBRID_failure_exit_code} Print_Fatal_And_Exit \
            'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output  'Afterburner' "$(pwd)/Afterburner"
}

function Functional_Test__do-Afterburner-only()
{
    shopt -s nullglob
    local -r config_filename='Handler_config.yaml'
    local unfinished_files output_files terminal_output_file failure_message
    mkdir 'Sampler'
    touch 'Sampler/particle_lists.oscar'
    printf '
    Afterburner:
      Executable: %s/tests/mocks/smash_afterburner_black-box.py
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    __static__Check_Successful_Handler_Run $?
    mv 'Afterburner' 'Afterburner-success'
    # Expect failure and test "SMASH" message
    Print_Info 'Running Hybrid-handler expecting invalid Afterburner input file failure'
    terminal_output_file='Afterburner/Terminal_Output.txt'
    BLACK_BOX_FAIL='invalid_config' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with invalid Afterburner input.'
        return 1
    elif [[ ! -f "${terminal_output_file}" ]]; then
        Print_Error 'File ' --emph "${terminal_output_file}" ' not found.'
        return 1
    fi
    failure_message=$(tail -n 1 "${terminal_output_file}" | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g')
    if [[ "${failure_message}" != 'Validation of SMASH input failed.' ]]; then
        Print_Error 'Unexpected failure message: ' --emph "${failure_message}"
        return 1
    fi
    mv 'Afterburner' 'Afterburner-invalid-config'
    # Expect failure and test "SMASH" unfinished/lock files
    Print_Info 'Running Hybrid-handler expecting crash in Afterburner software'
    BLACK_BOX_FAIL='smash_crashes' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with Afterburner software crashing.'
        return 1
    fi
    unfinished_files=(Afterburner/*.{unfinished,lock})
    if [[ ${#unfinished_files[@]} -ne 3 ]]; then
        Print_Error 'Expected ' --emph '3' " unfinished/lock files, but ${#unfinished_files[@]} found."
        return 1
    fi
    mv 'Afterburner' 'Afterburner-software-crash'
    #Test with custom input
    rm 'Sampler/particle_lists.oscar'
    mkdir -p test
    touch 'test/particle_lists_2.oscar'
    printf '
    Afterburner:
      Executable: %s/mocks/smash_afterburner_black-box.py
      Input_file: %s/test/particle_lists_2.oscar
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${HYBRIDT_tests_folder}" "$(pwd)"  > "${config_filename}"
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    __static__Check_Successful_Handler_Run $? || return 1
    mv 'Afterburner' 'Afterburner-success-custom-input'
    # Expect failure when using custom input while also running the sampler
    printf '
    Sampler:
      Executable: echo
    Afterburner:
      Executable: %s/mocks/smash_afterburner_black-box.py
      Input_file: %s/test/particle_lists_2.oscar
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    '  "${HYBRIDT_tests_folder}" "$(pwd)"  > "${config_filename}"
    Print_Info 'Running Hybrid-handler expecting failure'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -ne 110 ]]; then
        Print_Error 'Hybrid-handler did not fail as expected with exit code 110.'
        return 1
    fi
    # Expect success and test the add_spectator functionality
    Print_Info 'Running Hybrid-handler expecting success with the add_spectator option'
    mkdir 'IC'
    touch 'IC/config.yaml' 'IC/SMASH_IC.oscar' 'Sampler/particle_lists.oscar'
    printf '
    Afterburner:
      Executable: %s/tests/mocks/smash_afterburner_black-box.py
      Add_spectators_from_IC: TRUE
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    __static__Check_Successful_Handler_Run  $?
    mv 'Afterburner' 'Afterburner-success-with-spectators'
    # Expect success and test the add_spectator functionality with custom spectator input
    Print_Info 'Running Hybrid-handler expecting success with the custom add_spectator option'
    rm -r "IC"/*
    mkdir -p test
    touch 'test/SMASH_IC_2.oscar' 'IC/config.yaml'
    printf '
    Afterburner:
      Executable: %s/mocks/smash_afterburner_black-box.py
      Add_spectators_from_IC: TRUE
      Spectators_source: %s/test/SMASH_IC_2.oscar
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${HYBRIDT_tests_folder}" "$(pwd)"  > "${config_filename}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    __static__Check_Successful_Handler_Run  $? || return 1
    mv 'Afterburner' 'Afterburner-success-with-spectators'
    # Expect failure when combining custom spectator lists and running IC
    Print_Info 'Running Hybrid-handler expecting failure with the add_spectator option and IC at the same time'
    printf '
    IC:
      Executable: echo
    Hydro:
      Executable: echo
    Sampler:
      Executable: echo
    Afterburner:
      Executable: %s/mocks/smash_afterburner_black-box.py
      Add_spectators_from_IC: TRUE
      Spectators_source: %s/test/SMASH_IC_2.oscar
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    '  "${HYBRIDT_tests_folder}" "$(pwd)" > "${config_filename}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -ne 110 ]]; then
        Print_Error 'Hybrid-handler did not fail as expected with exit code 110.'
        return 1
    fi
}
