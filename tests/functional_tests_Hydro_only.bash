#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__do-Hydro-only()
{
    shopt -s nullglob
    local -r \
        config_filename='vhlle_hydro_config' \
        run_id='Hydro_only'
    local output_files terminal_output_file failure_message
    # Make a symlink to the python mock such that the eos folder doesn't have to be created in the mock folder
    ln -s "${HYBRIDT_repository_top_level_path}/tests/mocks/vhlle_black-box.py" "vhlle_black-box.py"
    mkdir 'eos'
    printf '
    Hybrid_handler:
      Run_ID: %s
    Hydro:
      Executable: %s/vhlle_black-box.py
    ' "${run_id}" "$(pwd)" > "${config_filename}"
    # Run the hydro stage and check if freezeout is successfully generated
    mkdir -p "IC/${run_id}"
    touch "IC/${run_id}/SMASH_IC.dat"
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Hydro' "$(pwd)/Hydro"
    mv 'Hydro' 'Hydro-success'
    #Expect success with custom input file name from IC
    custom_input="hydro_input.dat"
    mkdir -p "IC/${run_id}"
    touch "IC/${run_id}/${custom_input}"
    printf '
    Hybrid_handler:
      Run_ID: %s
    Hydro:
      Executable: %s/vhlle_black-box.py
      Input_file: %s
    ' "${run_id}" "$(pwd)" "${custom_input}" > "${config_filename}"
    # Run the hydro stage and check if freezeout is successfully generated
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Hydro' "$(pwd)/Hydro"
    mv 'Hydro' 'Hydro-success-custom-input-file-name'
    # Expect failure when giving an invalid IC output
    Print_Info 'Running Hybrid-handler expecting invalid IC argument'
    local -r terminal_output_file="Hydro/${run_id}/Hydro.log"
    BLACK_BOX_FAIL='invalid_input' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
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
    #Expect success with custom path to input file
    printf '
    Hybrid_handler:
      Run_ID: %s
    Hydro:
      Executable: %s/vhlle_black-box.py
      Input_file: %s/test/input
    ' "${run_id}" "$(pwd)" "$(pwd)" > "${config_filename}"
    # Run the hydro stage and check if freezeout is successfully generated
    rm "IC/${run_id}/SMASH_IC.dat"
    mkdir -p test
    touch 'test/input'
    Print_Info 'Running Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    Check_If_Software_Produced_Expected_Output 'Hydro' "$(pwd)/Hydro"
    mv 'Hydro' 'Hydro-success-custom-path-to-input'
    # Expect failure when an invalid config was supplied
    Print_Info 'Running Hybrid-handler expecting invalid config argument'
    BLACK_BOX_FAIL='invalid_config' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
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
    BLACK_BOX_FAIL='crash' \
        Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
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
    #Expect failure  with custom path to input file while also using IC
    printf '
    Hybrid_handler:
      Run_ID: %s
    IC:
      Executable: %s/echo.py
    Hydro:
      Executable: %s/vhlle_black-box.py
      Input_file: %s/test/input
    ' "${run_id}" "${HYBRIDT_tests_folder}/mocks" "$(pwd)" "$(pwd)" > "${config_filename}"
    Print_Info 'Running Hybrid-handler expecting failure'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_logic_error} ]]; then
        Print_Error \
            'Hybrid-handler did not fail as expected with exit code ' \
            --emph "${HYBRID_fatal_logic_error}" '.'
        return 1
    fi
    # Expect failure for unfinished IC input
    printf '
    Hybrid_handler:
      Run_ID: %s
    Hydro:
      Executable: %s/vhlle_black-box.py
      Input_file: %s
    ' "${run_id}" "$(pwd)" "IC/${run_id}/SMASH_IC.dat" > "${config_filename}"
    touch "IC/${run_id}/SMASH_IC.dat.unfinished"
    Print_Info 'Running Hybrid-handler expecting failure'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -ne ${HYBRID_fatal_file_not_found} ]]; then
        Print_Error \
            'Hydro finished without exit code ' \
            --emph "${HYBRID_fatal_file_not_found}" ' finding unfinished files.'
        return 1
    fi
}