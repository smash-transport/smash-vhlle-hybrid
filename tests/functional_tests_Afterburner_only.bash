#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: These functional tests just require code to run and finish with zero exit code.

function __static__Check_Successful_Handler_Run()
{
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    unfinished_files=( Afterburner/*.unfinished )
    output_files=( Afterburner/* )
    if [[ ${#unfinished_files[@]} -lt 0 ]]; then
        Print_Error 'Some unexpected ' --emph '.unfinished' ' output file remained.'
        return 1
    elif [[ ${#output_files[@]} -ne 6 ]]; then
        Print_Error 'Expected ' --emph '6' " output files, but ${#output_files[@]} found."
        return 1
    fi
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
            File_Directory: "./Afterburner"
    ' "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    __static__Check_Successful_Handler_Run || return 1
    mv 'Afterburner' 'Afterburner-success'
    # Expect failure and test "SMASH" message
    Print_Info 'Running Hybrid-handler expecting invalid Afterburner input file failure'
    terminal_output_file='Afterburner/Terminal_Output.txt'
    BLACK_BOX_FAIL='invalid_config'\
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
    BLACK_BOX_FAIL='smash_crashes'\
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with Afterburner software crashing.'
        return 1
    fi
    unfinished_files=( Afterburner/*.{unfinished,lock} )
    if [[ ${#unfinished_files[@]} -ne 3 ]]; then
        Print_Error 'Expected ' --emph '3' " unfinished/lock files, but ${#unfinished_files[@]} found."
        return 1
    fi
    mv 'Afterburner' 'Afterburner-software-crash'
    # Expect success and test the add_spectator functionality
    Print_Info 'Running Hybrid-handler expecting success with the add_spectator option'
    mkdir 'IC'
    touch 'IC/config.yaml' 'IC/SMASH_IC.oscar'
    printf '
    Afterburner:
      Executable: %s/tests/mocks/smash_afterburner_black-box.py
      Add_spectators_from_IC: TRUE
      Software_keys:
        Modi:
          List:
            File_Directory: "./Afterburner"
    ' "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    __static__Check_Successful_Handler_Run || return 1
    mv 'Afterburner' 'Afterburner-success-with-spectators'
}
