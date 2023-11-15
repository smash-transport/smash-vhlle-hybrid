#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__do-Hydro-only()
{
    shopt -s nullglob
    local -r config_filename='vhlle_hydro'
    local output_files terminal_output_file failure_message
    printf '
    Hydro:
      Executable: %s/tests/mocks/vhlle_black-box.py
    ' "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    # Run the hydro stage and check if freezeout is successfully generated
    mkdir -p 'IC'
    touch 'IC/SMASH_IC.dat'
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    output_files=( Hydro/* )
    if [[ ${#output_files[@]} -ne 4 ]]; then
        Print_Error 'Expected ' --emph '4' " output files, but ${#output_files[@]} found."
        return 1
    fi
    mv 'Hydro' 'Hydro-success'
    # Expect failure when giving an invalid IC output
    Print_Info 'Running Hybrid-handler expecting invalid IC argument'
    terminal_output_file='Hydro/Terminal_Output.txt'
    BLACK_BOX_FAIL='invalid_input'\
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with invalid IC input for Hydro.'
        return 1
    elif [[ ! -f "${terminal_output_file}" ]]; then
        Print_Error 'File ' --emph "${terminal_output_file}" ' not found.'
        return 1
    fi
    failure_message=$(tail -n 1 "${terminal_output_file}" | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g')
    if [[ "${failure_message}" != 'I/O error with '* ]]; then
        Print_Error 'Unexpected failure message: ' --emph "${failure_message}"
        return 1
    fi
    mv 'Hydro' 'Hydro-invalid-input'
    # Expect failure when an invalid config was supplied
    Print_Info 'Running Hybrid-handler expecting invalid config argument'
    terminal_output_file='Hydro/Terminal_Output.txt'
    BLACK_BOX_FAIL='invalid_config'\
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with invalid config for Hydro.'
        return 1
    elif [[ ! -f "${terminal_output_file}" ]]; then
        Print_Error 'File ' --emph "${terminal_output_file}" ' not found.'
        return 1
    fi
    failure_message=$(tail -n 1 "${terminal_output_file}" | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g')
    if [[ "${failure_message}" != 'cannot open parameters file '* ]]; then
        Print_Error 'Unexpected failure message: ' --emph "${failure_message}"
        return 1
    fi
    mv 'Hydro' 'Hydro-invalid-config'
    # Expect failure and test terminal output in the case of a crash of vHLLE
    Print_Info 'Running Hybrid-handler expecting crash in Hydro'
    BLACK_BOX_FAIL='crash'\
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with Hydro crashing.'
        return 1
    fi
    failure_message=$(tail -n 1 "${terminal_output_file}" | sed -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g')
    if [[ "${failure_message}" != 'Crash happened in vHLLE' ]]; then
        Print_Error 'Hydro finished although crash was expected.'
        return 1
    fi
    mv 'Hydro' 'Hydro-crash'
}
