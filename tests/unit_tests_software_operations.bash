#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__copy-hybrid-handler-config-section()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'global_variables.bash'
        'software_operations.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__copy-hybrid-handler-config-section()
{
    HYBRID_configuration_file=${FUNCNAME}.yaml
    # Avoid empty lines in the beginning in this test as yq behavior
    # might change with different versions (here we compare strings)
    printf '%s\n' \
        'Hybrid_handler:' \
        "  Run_ID: ${HYBRID_run_id}" \
        'IC:' \
        '  Executable: ex' \
        '  Config_file: conf' \
        'Hydro:' \
        '  Executable: exh' \
        '  Config_file: confh' > "${HYBRID_configuration_file}"
    local -r git_description="$(git -C "${HYBRIDT_folder_to_run_tests}" describe --long --always --all)"
    local folder description expected_result
    for folder in "${HYBRIDT_folder_to_run_tests}" ~; do
        Call_Codebase_Function_In_Subshell Copy_Hybrid_Handler_Config_Section 'IC' "." "${folder}"
        if [[ $? -ne 0 ]]; then
            Print_Error 'Extraction of configuration failed.'
            return 1
        elif [[ "${folder}" = "${HYBRIDT_folder_to_run_tests}" ]]; then
            description="${git_description}"
        else
            description='Not a Git repository'
        fi
        printf -v expected_result '%b' \
            "# Git describe of executable folder: ${description}\n\n" \
            "# Git describe of handler folder: ${git_description}\n\n" \
            'Hybrid_handler:\n' \
            "  Run_ID: ${HYBRID_run_id}\n" \
            'IC:\n' \
            '  Executable: ex\n' \
            '  Config_file: conf' # No trailing endline as "$(< ...)" strips them
        if [[ "$(< "${HYBRID_handler_config_section_filename[IC]}")" != "${expected_result}" ]]; then
            Print_Error \
                "Copying of relevant handler config sections failed!" \
                "---- OBTAINED: ----\n$(< "${HYBRID_handler_config_section_filename[IC]}")" \
                "---- EXPECTED: ----\n${expected_result}" \
                '-------------------'
            return 1
        fi
        rm "${HYBRID_handler_config_section_filename[IC]}"
    done
}

function Unit_Test__add-section-terminal-output()
{
    Do_Preliminary_Afterburner_Setup_Operations
    HYBRID_software_output_directory[IC]="${HYBRIDT_folder_to_run_tests}/test_dir_IC"
    mkdir -p "${HYBRID_software_output_directory[IC]}"
    local -r filename="${HYBRID_software_output_directory[IC]}/${HYBRID_terminal_output[IC]}"
    touch "${filename}"
    Call_Codebase_Function_In_Subshell Separate_Terminal_Output_For 'IC'
    if [[ $(grep -o '=' "${filename}" | wc -l) != 282 ]]; then
        Print_Error 'Terminal output file not properly separated.'
        return 1
    fi
    rm -r "${HYBRID_software_output_directory[IC]}"
}
