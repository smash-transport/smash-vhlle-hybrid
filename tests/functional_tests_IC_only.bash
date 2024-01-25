#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__do-IC-only()
{
    shopt -s nullglob
    local -r \
        config_filename='IC_config.yaml' \
        run_id='IC_only'
    local unfinished_files output_files terminal_output_file failure_message
    printf '
    Hybrid_handler:
      Run_ID: %s
    IC:
      Executable: %s/tests/mocks/smash_IC_black-box.py
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'IC' "$(pwd)/IC"
    mv 'IC' 'IC-success'
    # Expect failure and test "SMASH" message
    Print_Info 'Running Hybrid-handler expecting invalid IC input file failure'
    terminal_output_file="IC/${run_id}/Terminal_Output.txt"
    BLACK_BOX_FAIL='invalid_config' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with invalid IC input.'
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
    mv 'IC' 'IC-invalid-config'
    # Expect failure and test "SMASH" unfinished/lock files
    Print_Info 'Running Hybrid-handler expecting crash in IC software'
    BLACK_BOX_FAIL='smash_crashes' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with IC software crashing.'
        return 1
    fi
    unfinished_files=("IC/${run_id}/"*.{unfinished,lock})
    if [[ ${#unfinished_files[@]} -ne 3 ]]; then
        Print_Error 'Expected ' --emph '3' " unfinished/lock files, but ${#unfinished_files[@]} found."
        return 1
    fi
    mv 'IC' 'IC-software-crash'
}
