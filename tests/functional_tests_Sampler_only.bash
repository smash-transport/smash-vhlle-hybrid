#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__do-Sampler-only()
{
    shopt -s nullglob
    local -r \
        hybrid_handler_config='hybrid_config' \
        run_id='Sampler_only'
    local output_files
    mkdir -p "Hydro/${run_id}"
    touch "Hydro/${run_id}/freezeout.dat"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Executable: %s/tests/mocks/sampler_black-box.py
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config}"
    # Expect success and test presence of output files
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Sampler' "$(pwd)/Sampler"
    mv 'Sampler' 'Sampler-success'
    # Expect failure and test terminal output
    local terminal_output_file error_message
    local -r terminal_output_file="Sampler/${run_id}/Sampler.log"
    Print_Info 'Running Hybrid-handler expecting crash in Sampler'
    BLACK_BOX_FAIL='true' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with Sampler crashing.'
        return 1
    elif [[ ! -f "${terminal_output_file}" ]]; then
        Print_Error 'File ' --emph "${terminal_output_file}" ' not found.'
        return 1
    fi
    error_message="$(< "${terminal_output_file}")"
    if [[ "${error_message}" != 'Sampler black-box crashed!' ]]; then
        Print_Error 'Sampler crashed with unexpected terminal output.'
        return 1
    fi
    mv 'Sampler' 'Sampler-crash'
    # Expect Hybrid-handler to crash before calling the Sampler because of invalid config file
    Print_Info 'Running Hybrid-handler expecting invalid config error'
    BLACK_BOX_FAIL='false'
    mkdir -p "Sampler/${run_id}"
    local -r invalid_sampler_config="invalid_hadron_sampler"
    touch "${invalid_sampler_config}"
    printf '
    Sampler:
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s
    ' "${HYBRIDT_repository_top_level_path}" \
        "${invalid_sampler_config}" > "${hybrid_handler_config}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.' &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with invalid config for Sampler.'
        return 1
    fi
    mv 'Sampler' 'Sampler-invalid-config'
}
