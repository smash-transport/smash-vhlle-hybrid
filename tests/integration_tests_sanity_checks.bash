#===================================================
#
#    Copyright (c) 2025-2026
#      Hybrid-handler Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__pick-correct-base-config()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'common_functionality.bash'
        'global_variables.bash'
        'sanity_checks.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
    HYBRID_software_executable[IC]="${HYBRIDT_tests_folder}/mocks/echo.py"
    HYBRID_software_executable[Sampler]="${HYBRIDT_tests_folder}/mocks/echo.py"
    # Touch dummy empty handler config as this is always there in sanity checks
    touch "${HYBRID_configuration_file}"
}

function __static__Test_Picked_Base_Config_For_Version()
{
    export MOCK_ECHO_VERSION="$1"
    local -r \
        expected_filename="$2" \
        key="$3"
    Call_Codebase_Function __static__Set_Software_Version "${key}"
    Call_Codebase_Function __static__Set_Base_Configuration_File_If_Unset "${key}"
    Print_Debug "${expected_filename} ==? $(basename "${HYBRID_software_base_config_file[${key}]}")"
    if [[ $(basename "${HYBRID_software_base_config_file[${key}]}") != ${expected_filename} ]]; then
        Print_Error 'Picking base configuration failed for ' --emph "${key}" ' and version ' --emph "$1" '.'
        return 1
    fi
}

function Integration_Test__pick-correct-base-config()
{
    declare -A IC_cases=(
        ['3.1']='smash_IC__v3.1.yaml'
        ['3.2']='smash_IC__v3.2.yaml'
        ['3.2.1']='smash_IC__v3.2.yaml'
    )
    declare -A Sampler_cases=(
        ['2.42.666']='hadron_sampler__v0.0'
        ['3.2']='hadron_sampler__v3.2'
    )
    local key v
    for key in 'IC' 'Sampler'; do
        declare -n cases=${key}_cases
        for v in "${!cases[@]}"; do
            # Call the function in a sub-shell to avoid exiting the test in case of failure
            (__static__Test_Picked_Base_Config_For_Version "${v}" "${cases[${v}]}" "${key}")
            if [[ $? -ne 0 ]]; then
                return 1
            fi
        done
    done
    (__static__Test_Picked_Base_Config_For_Version "2.333" '' 'IC' 2> /dev/null)
    if [[ $? -eq 0 ]]; then
        return 1
    fi
}

function Make_Test_Preliminary_Operations__pick-correct-default-input-file()
{
    Make_Test_Preliminary_Operations__pick-correct-base-config
    # Pretend sanity checks are done in a scenario where both IC and Hydro are run
    HYBRID_given_software_sections=('IC' 'Hydro')
}

function __static__Test_Picked_Default_Input_File_For_Version()
{
    export MOCK_ECHO_VERSION="$1"
    local -r \
        expected_filename="$2" \
        key="$3"
    Call_Codebase_Function __static__Set_Software_Version 'IC'
    Call_Codebase_Function __static__Set_Default_Input_File_If_Unset "${key}"
    Print_Debug "${expected_filename} ==? ${HYBRID_software_default_input_filename[${key}]}"
    if [[ "${HYBRID_software_default_input_filename[${key}]}" != "${expected_filename}" ]]; then
        Print_Error 'Picking default input file failed for ' --emph "${key}" ' and IC version ' --emph "$1" '.'
        return 1
    fi
}

function Integration_Test__pick-correct-default-input-file()
{
    declare -A Hydro_cases=(
        [3.2]='SMASH_IC.dat'
        [3.3]='SMASH_IC_For_vHLLE.dat'
    )
    local v
    for v in "${!Hydro_cases[@]}"; do
        (__static__Test_Picked_Default_Input_File_For_Version "${v}" "${Hydro_cases[${v}]}" 'Hydro')
        if [[ $? -ne 0 ]]; then
            return 1
        fi
    done
}
