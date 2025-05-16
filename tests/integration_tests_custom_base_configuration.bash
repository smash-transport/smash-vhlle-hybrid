#===================================================
#
#    Copyright (c) 2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__set-base-config-file-from-user()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'configuration_parser.bash'
        'global_variables.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Integration_Test__set-base-config-file-from-user()
{
    local -r functions_to_call=(
        'Validate_And_Parse_Configuration_File'
        'Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables'
    )
    declare -rA custom_base_config=(
        [IC]='Custom_IC_base_config.yaml'
        [Hydro]='Custom_Hydro_base_config.txt'
        [Sampler]='Custom_Sampler_base_config.txt'
        [Afterburner]='Custom_Afterburner_base_config.yaml'
    )
    local my_function key
    for key in 'IC' 'Hydro' 'Sampler' 'Afterburner'; do
        (
            printf '
            Hybrid_handler:
                Run_ID: %s
            %s:
                Config_file: "%s"
                Executable: %s/tests/mocks/echo.py
            ' \
                "${key}_only" \
                "${key}" \
                "${custom_base_config[${key}]}" \
                "${HYBRIDT_repository_top_level_path}" > "${HYBRID_configuration_file}"
            for my_function in "${functions_to_call[@]}"; do
                Call_Codebase_Function "${my_function}" #&> /dev/null
            done
            if [[ "${HYBRID_software_base_config_file[${key}]}" != "${custom_base_config[${key}]}" ]]; then
                Print_Error 'Wrong base config file ' --emph "${HYBRID_software_base_config_file[${key}]}" \
                    ' set for ' --emph "${key}" ' stage.'
                exit 1
            fi
        )
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    done
}
