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
        hybrid_handler_config_fist='hybrid_config_fist' \
        hybrid_handler_config_mixed='hybrid_config_mixed' \
        hybrid_handler_config_wrong_module='hybrid_config_wrong_module' \
        run_id='Sampler_only'
    local output_files
    mkdir -p "Hydro/${run_id}"
    touch "Hydro/${run_id}/freezeout.dat"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: smash-hadron-sampler
      Executable: %s/tests/mocks/sampler_black-box.py
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config}"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: FIST-sampler
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s/configs/fist_config
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config_fist}"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: FIST-sampler
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s/configs/hadron_sampler
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config_mixed}"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: 42
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s/configs/hadron_sampler
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config_wrong_module}"
    # Expect success and test presence of output files
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Sampler' "$(pwd)/Sampler"
    mv 'Sampler' 'Sampler-success'
    # Expect success with FIST module
    Print_Info 'Running Hybrid-handler expecting success'
    touch "./list.dat"
    touch "./decays.dat"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config_fist}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed when running with alternative sampler.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Sampler' "$(pwd)/Sampler"
    mv 'Sampler' 'Sampler-success-fist'
    # Expect failure with config from wrong module
    Print_Info 'Running Hybrid-handler expecting failure'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config_mixed}" '-o' '.'
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded when running with config from wrong module.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Sampler' "$(pwd)/Sampler"
    mv 'Sampler' 'Sampler-failure-wrong-config'
    # Expect failure with wrong module name
    Print_Info 'Running Hybrid-handler expecting failure'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config_wrong_module}" '-o' '.'
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded when running with config from wrong module.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Sampler' "$(pwd)/Sampler"
    mv 'Sampler' 'Sampler-failure-wrong-module'
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
    # Expect failure for unfinished Hydro input
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
       Executable: %s/tests/mocks/sampler_black-box.py
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config}"
    rm "Hydro/${run_id}/freezeout.dat"
    touch "Hydro/${run_id}/freezeout.dat.unfinished"
    Print_Info 'Running Hybrid-handler expecting failure'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_file_not_found} ]]; then
        Print_Error \
            'Sampler finished without exit code ' \
            --emph "${HYBRID_fatal_file_not_found}" ' finding unfinished files.'
        return 1
    fi
    mv 'Sampler' 'Sampler-unfinished-hydro'
}
