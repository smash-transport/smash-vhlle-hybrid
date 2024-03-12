#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__do-IC-only-with-ID-from-command-line()
{
    shopt -s nullglob
    local -r \
        config_filename='IC_config.yaml' \
        run_id='ID_as_CLO'
    local unfinished_files output_files terminal_output_file failure_message
    printf '
    Hybrid_handler:
      Run_ID: %s
    IC:
      Executable: %s/tests/mocks/smash_IC_black-box.py
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' \
        '-c' "${config_filename}" \
        '-o' '.' \
        '--id' "${run_id}"
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    elif [[ ! -d "$(pwd)/IC/${run_id}" ]]; then
        Print_Error 'Hybrid-handler failed to create ID folder specified as command line option.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'IC' "$(pwd)/IC"
}
