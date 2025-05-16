#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function __static__Check_Successful_Handler_Run()
{
    if [[ $1 -ne 0 ]]; then
        exit_code=1 Print_Fatal_And_Exit 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Afterburner' "$(pwd)/Afterburner"
}

function Functional_Test__do-Afterburner-only()
{
    shopt -s nullglob
    local -r \
        config_filename='Handler_config.yaml' \
        run_id='Afterburner_only' \
        mocks_folder="${HYBRIDT_tests_folder}/mocks"
    local unfinished_files output_files terminal_output_file failure_message

    mkdir -p "Sampler/${run_id}"
    touch "Sampler/${run_id}/particle_lists.oscar"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Afterburner:
      Executable: %s/tests/mocks/smash_afterburner_black-box.py
      Add_spectators_from_IC: false
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" > "${config_filename}"
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    __static__Check_Successful_Handler_Run $?
    mv 'Afterburner' 'Afterburner-success'
    # Expect success with custom input file name from Sampler
    custom_input="afterburner_input.dat"
    mkdir -p "Sampler/${run_id}"
    touch "Sampler/${run_id}/${custom_input}"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Afterburner:
      Executable: %s/tests/mocks/smash_afterburner_black-box.py
      Add_spectators_from_IC: false
      Input_file: %s
    ' "${run_id}" "${HYBRIDT_repository_top_level_path}" "${custom_input}" > "${config_filename}"
    # Run the hydro stage and check if freezeout is successfully generated
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    mv 'Afterburner' 'Afterburner-success-custom-input-file-name'
    # Expect failure and test "SMASH" message
    Print_Info 'Running Hybrid-handler expecting invalid Afterburner input file failure'
    local -r terminal_output_file="Afterburner/${run_id}/Afterburner.log"
    BLACK_BOX_FAIL='invalid_config' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
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
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with Afterburner software crashing.'
        return 1
    fi
    unfinished_files=("Afterburner/${run_id}/"*.{unfinished,lock})
    if [[ ${#unfinished_files[@]} -ne 3 ]]; then
        Print_Error 'Expected ' --emph '3' " unfinished/lock files, but ${#unfinished_files[@]} found."
        return 1
    fi
    mv 'Afterburner' 'Afterburner-software-crash'
    #Test with custom input
    rm "Sampler/${run_id}/particle_lists.oscar"
    mkdir -p test
    touch 'test/particle_lists_2.oscar'
    printf '
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Input_file: %s/test/particle_lists_2.oscar
      Add_spectators_from_IC: false
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${mocks_folder}" "$(pwd)" > "${config_filename}"
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    __static__Check_Successful_Handler_Run $? || return 1
    mv 'Afterburner' 'Afterburner-success-custom-input'
    # Expect failure when using custom input while also running the sampler
    printf '
    Hybrid_handler:
      Run_ID: %s
    Sampler:
      Executable: %s/echo.py
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Input_file: %s/test/particle_lists_2.oscar
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${run_id}" "${mocks_folder}" "${mocks_folder}" "$(pwd)" > "${config_filename}"
    Print_Info 'Running Hybrid-handler expecting failure when using custom input while also running the sampler'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_logic_error} ]]; then
        Print_Error \
            'Hybrid-handler did not fail as expected with exit code ' \
            --emph "${HYBRID_fatal_logic_error}" '.'
        return 1
    fi
    # Expect failure when wrongly specifying custom input (I)
    printf '
    Hybrid_handler:
      Run_ID: %s
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Software_keys:
        Modi:
          List:
            File_Directory: "."
            Filename: "particle_lists_2.oscar"
    ' "${run_id}" "${mocks_folder}" > "${config_filename}"
    Print_Info 'Running Hybrid-handler expecting failure when specifying custom input via Software_keys Filename'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_logic_error} ]]; then
        Print_Error \
            'Hybrid-handler did not fail as expected with exit code ' \
            --emph "${HYBRID_fatal_logic_error}" '.'
        return 1
    fi
    # Expect failure when wrongly specifying custom input (II)
    printf '
    Hybrid_handler:
      Run_ID: %s
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Software_keys:
        Modi:
          List:
            File_Directory: "."
            File_Prefix: "sampling"
            Shift_Id: 0
    ' "${run_id}" "${mocks_folder}" > "${config_filename}"
    Print_Info \
        'Running Hybrid-handler expecting failure when specifying custom input via Software_keys Shift_Id/File_Prefix'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_logic_error} ]]; then
        Print_Error \
            'Hybrid-handler did not fail as expected with exit code ' \
            --emph "${HYBRID_fatal_logic_error}" '.'
        return 1
    fi
    # Expect success and test the add_spectator functionality
    Print_Info 'Running Hybrid-handler expecting success with the add_spectator option'
    mkdir -p "IC/${run_id}"
    touch "IC/${run_id}/SMASH_IC.oscar" "Sampler/${run_id}/particle_lists.oscar"
    cp "${HYBRIDT_repository_top_level_path}/configs/smash_initial_conditions__ge_v3.2.yaml" "IC/${run_id}/config.yaml"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Add_spectators_from_IC: true
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${run_id}" "${mocks_folder}" > "${config_filename}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    __static__Check_Successful_Handler_Run $?
    mv 'Afterburner' 'Afterburner-success-with-spectators'
    # Expect failure and test the add_spectator functionality combined with more than one IC event
    Print_Info 'Running Hybrid-handler expecting failure with the add_spectator option and more than one IC event'
    mkdir -p "IC/${run_id}"
    touch "IC/${run_id}/config.yaml" "IC/${run_id}/SMASH_IC.oscar" "Sampler/${run_id}/particle_lists.oscar"
    printf '
    General:
      Nevents: 42
    Modi:
      Collider:
        Projectile:
          Particles: {2212: 79, 2112: 118}
        Target:
          Particles: {2212: 79, 2112: 118}
    ' > "IC/${run_id}/config.yaml"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Add_spectators_from_IC: true
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${run_id}" "${mocks_folder}" > "${config_filename}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_value_error} ]]; then
        Print_Error \
            'Hybrid-handler did not fail as expected with exit code ' \
            --emph "${HYBRID_fatal_value_error}" '.'
        return 1
    fi
    mv 'Afterburner' 'Afterburner-invalid-IC-events-with-spectators'
    # Expect success and test the add_spectator functionality with custom spectator input
    Print_Info 'Running Hybrid-handler expecting success with the custom add_spectator option'
    rm -r "IC"/*
    mkdir -p 'test' "IC/${run_id}"
    touch 'test/SMASH_IC_2.oscar'
    cp "${HYBRIDT_repository_top_level_path}/configs/smash_initial_conditions__ge_v3.2.yaml" "IC/${run_id}/config.yaml"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Add_spectators_from_IC: True
      Spectators_source: %s/test/SMASH_IC_2.oscar
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${run_id}" "${mocks_folder}" "$(pwd)" > "${config_filename}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    __static__Check_Successful_Handler_Run $? || return 1
    mv 'Afterburner' 'Afterburner-success-custom-spectators-input'
    # Expect failure when combining custom spectator lists and running IC
    Print_Info 'Running Hybrid-handler expecting failure with the add_spectator option and IC at the same time'
    printf '
    IC:
      Executable: %s/echo.py
    Hydro:
      Executable: %s/echo.py
    Sampler:
      Executable: %s/echo.py
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Add_spectators_from_IC: TRUE
      Spectators_source: %s/test/SMASH_IC_2.oscar
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${mocks_folder}" "${mocks_folder}" "${mocks_folder}" "${mocks_folder}" "$(pwd)" > "${config_filename}"
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_logic_error} ]]; then
        Print_Error \
            'Hybrid-handler did not fail as expected with exit code ' \
            --emph "${HYBRID_fatal_logic_error}" '.'
        return 1
    fi
    # Expect failure for unfinished Sampler output
    printf '
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Input_file: %s/test/particle_lists_2.oscar
    ' "${mocks_folder}" "${HYBRIDT_tests_folder}" > "${config_filename}"
    touch "Sampler/particle_lists.oscar.unfinished"
    Print_Info 'Running Hybrid-handler expecting failure'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_file_not_found} ]]; then
        Print_Error \
            'Afterburner finished without exit code ' \
            --emph "${HYBRID_fatal_file_not_found}" ' finding unfinished files.'
        return 1
    fi
}
