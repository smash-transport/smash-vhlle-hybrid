#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function __static__Execute_FIST_Sampler_Test()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty 'run_id' 'particle_list' 'decays_list'
    local -r expectation="${1}" \
        hybrid_handler_config="${2}" \
        expected_exit_code="${3}" \
        error_message="${4}" \
        output_directory="${5}"
    mkdir -p "Sampler/${run_id}"
    touch "${particle_list}" "${decays_list}"
    Print_Info "Running Hybrid-handler expecting ${expectation}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -eq "${expected_exit_code}" ]]; then
        Print_Error "Hybrid-handler ${error_message}"
        return 1
    fi
    if [[ "${expected_exit_code}" != '0' ]]; then
        Check_If_Software_Produced_Expected_Output 'Sampler_FIST' "$(pwd)/Sampler"
    fi
    mv 'Sampler' "${output_directory}"
}

function Functional_Test__do-Sampler-only()
{
    shopt -s nullglob
    local -r \
        hybrid_handler_config='hybrid_config' \
        hybrid_handler_config_fist='hybrid_config_fist' \
        hybrid_handler_config_mixed='hybrid_config_mixed' \
        hybrid_handler_config_wrong_module='hybrid_config_wrong_module' \
        hybrid_handler_config_wrong_fist_file='hybrid_config_wrong_fist_file' \
        run_id='Sampler_only'
    local output_files
    mkdir -p "Hydro/${run_id}"
    touch "Hydro/${run_id}/freezeout.dat"
    particle_list="./Sampler/${run_id}/list.dat"
    decays_list="./Sampler/${run_id}/decays.dat"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: SMASH
      Executable: %s/tests/mocks/sampler_black-box.py
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config}"
    # Expect success and test presence of output files
    Print_Info 'Running Hybrid-handler with SMASH-sampler-3.1.1 expecting success'
    export MOCK_HADRON_SAMPLER_VERSION='3.1.1'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Sampler_SMASH' "$(pwd)/Sampler"
    mv 'Sampler' 'Sampler-SMASH-success-3.1.1'
    export MOCK_HADRON_SAMPLER_VERSION='3.2'
    Print_Info 'Running Hybrid-handler with SMASH-sampler-3.2 expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Sampler_SMASH' "$(pwd)/Sampler"
    mv 'Sampler' 'Sampler-SMASH-success-3.2'
    # Expect failure and test terminal output
    local terminal_output_file error_message
    local -r terminal_output_file="Sampler/${run_id}/Sampler.log"
    Print_Info 'Running Hybrid-handler with SMASH-sampler-3.2 expecting crash in Sampler'
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
    mv 'Sampler' 'Sampler-SMASH-crash-3.2'
    # Expect Hybrid-handler to crash before calling the Sampler because of invalid config file
    Print_Info 'Running Hybrid-handler with SMASH-sampler-3.2 expecting invalid config error'
    export BLACK_BOX_FAIL='false'
    mkdir -p "Sampler/${run_id}"
    local -r invalid_sampler_config="invalid_hadron_sampler"
    touch "${invalid_sampler_config}"
    printf '
    Sampler:
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s
    ' "${HYBRIDT_repository_top_level_path}" \
        "${invalid_sampler_config}" > "${hybrid_handler_config}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with invalid config for Sampler.'
        return 1
    fi
    mv 'Sampler' 'Sampler-SMASH-invalid-config-3.2'
    # Expect failure for unfinished Hydro input
    Print_Info 'Running Hybrid-handler with SMASH-sampler-3.2 expecting failure for unfinished Hydro input'
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
       Executable: %s/tests/mocks/sampler_black-box.py
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config}"
    rm "Hydro/${run_id}/freezeout.dat"
    touch "Hydro/${run_id}/freezeout.dat.unfinished"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${hybrid_handler_config}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_file_not_found} ]]; then
        Print_Error \
            'Sampler finished without exit code ' \
            --emph "${HYBRID_fatal_file_not_found}" ' finding unfinished files.'
        return 1
    fi
    mv 'Sampler' 'Sampler-SMASH-unfinished-hydro-3.2'
    rm "Hydro/${run_id}/freezeout.dat.unfinished"
    touch "Hydro/${run_id}/freezeout.dat"
    # FIST part
    export BLACK_BOX_TYPE_SAMPLER="FIST"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: FIST
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s/configs/fist_config
      Particle_file: %s/tests/run_tests/do-Sampler-only/Sampler/Sampler_only/list.dat
      Decays_file: %s/tests/run_tests/do-Sampler-only/Sampler/Sampler_only/decays.dat
        ' "${run_id}" "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" \
        "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config_fist}"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: FIST
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s/configs/fist_config
      Particle_file: %s/tests/run_tests/do-Sampler-only/Sampler/Sampler_only/list.dat
      Decays_file: %s/tests/run_tests/do-Sampler-only/Sampler/Sampler_only/decays.dat.wrong
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" \
        "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" \
        > "${hybrid_handler_config_wrong_fist_file}"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: FIST
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s/configs/hadron_sampler_from_version_3.2_on
      Particle_file: %s/tests/run_tests/do-Sampler-only/Sampler/Sampler_only/list.dat
      Decays_file: %s/tests/run_tests/do-Sampler-only/Sampler/Sampler_only/decays.dat
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" \
        "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" > "${hybrid_handler_config_mixed}"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Module: 42
      Executable: %s/tests/mocks/sampler_black-box.py
      Config_file: %s/configs/hadron_sampler
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" "${HYBRIDT_repository_top_level_path}" \
        > "${hybrid_handler_config_wrong_module}"
    # Expect success with FIST module
    __static__Execute_FIST_Sampler_Test 'success when running with FIST module' \
        "${hybrid_handler_config_fist}" 1 'unexpectedly failed when running with FIST module.' \
        'Sampler-FIST-success' || return 1
    # Expect failure with config from wrong module
    __static__Execute_FIST_Sampler_Test 'failure when running FIST with smash_hadron_sampler config' \
        "${hybrid_handler_config_mixed}" 0 'unexpectedly succeeded when running with config from wrong module.' \
        'Sampler-FIST-failure-wrong_config' || return 1
    # Expect failure with wrong module name
    __static__Execute_FIST_Sampler_Test 'failure when running FIST with invalid module' \
        "${hybrid_handler_config_wrong_module}" 0 'unexpectedly succeeded when running with wrong module.' \
        'Sampler-FIST-failure-wrong-module' || return 1
    # Expect failure with wrong FIST file
    __static__Execute_FIST_Sampler_Test 'failure when running with wrong FIST file' \
        "${hybrid_handler_config_wrong_fist_file}" 0 'unexpectedly succeeded when running with wrong FIST file.' \
        'Sampler-FIST-failure-wrong-fist-file' || return 1
}
