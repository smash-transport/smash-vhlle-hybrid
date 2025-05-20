#===================================================
#
#    Copyright (c) 2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__set-custom-inputfile()
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

function Integration_Test__set-custom-inputfile()
{
    local -r functions_to_call=(
        'Validate_And_Parse_Configuration_File'
        'Perform_Sanity_Checks_On_Provided_Input_And_Define_Auxiliary_Global_Variables'
    )
    declare -rA custom_inputfile=(
        [Hydro]='Input_from_IC.dat'
        [Afterburner]='Input_from_Sampler.dat'
    )
    local my_function key
    for key in 'Hydro' 'Afterburner'; do
        (
            printf '
            Hybrid_handler:
                Run_ID: %s
            %s:
                Executable: %s/tests/mocks/echo.py
                Input_file: "%s"
            ' \
                "custom_input_to_${key}" \
                "${key}" \
                "${HYBRIDT_repository_top_level_path}" \
                "${custom_inputfile[${key}]}" > "${HYBRID_configuration_file}"
            for my_function in "${functions_to_call[@]}"; do
                Call_Codebase_Function "${my_function}" #&> /dev/null
            done
            case "${key}" in
                Hydro)
                    relative_key='IC'
                    ;;
                Afterburner)
                    relative_key='Sampler'
                    ;;
            esac
            local -r expected_file="${HYBRID_software_output_directory[${relative_key}]}"/"${custom_inputfile[${key}]}"
            if [[ "${HYBRID_software_input_file[${key}]}" != "${expected_file}" ]]; then
                Print_Error 'Inputfile ' --emph "${HYBRID_software_input_file[${key}]}" \
                    ' for ' --emph "${key}" ' stage is different from the ' --emph "${expected_file}" ' set. '
                exit 1
            fi
        )
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    done
}
