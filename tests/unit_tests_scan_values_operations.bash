#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__scan-create-list()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'global_variables.bash'
        'scan_values_operations.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__scan-create-list()
{
    declare -A list_of_parameters_values=(
        ['IC.Software_keys.Modi.Collider.Sqrtsnn']='{Values: [4.3, 7.7]}'
        ['Hydro.Software_keys.etaS']='{Values: [0.13, 0.15, 0.17]}'
    )
    Call_Codebase_Function Create_List_Of_Parameters_Values
    if [[ "${list_of_parameters_values[IC.Software_keys.Modi.Collider.Sqrtsnn]}" != '[4.3, 7.7]' ]] \
        || [[ "${list_of_parameters_values[Hydro.Software_keys.etaS]}" != '[0.13, 0.15, 0.17]' ]]; then
        Print_Error 'Parameters values list was not correctly created.'
        return 1
    fi
}

function Make_Test_Preliminary_Operations__scan-create-list-LHS()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'global_variables.bash'
        'scan_values_operations.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
    HYBRID_number_of_samples=3
    HYBRID_scan_strategy='LHS'
}

function Unit_Test__scan-create-list-LHS()
{
    declare -A list_of_parameters_values=(
        ['IC.Software_keys.Modi.Collider.Sqrtsnn']='{Range: [4.3, 7.7]}'
        ['Hydro.Software_keys.etaS']='{Range: [-0.13, 0.17]}'
    )
    declare -A ranges=(
        ['IC.Software_keys.Modi.Collider.Sqrtsnn']='[4.3, 7.7]'
        ['Hydro.Software_keys.etaS']='[-0.13, 0.17]'
    )
    Call_Codebase_Function Create_List_Of_Parameters_Values
    for key in "${!list_of_parameters_values[@]}"; do
        local temp_array lower_bound upper_bound actual_values value_count
        temp_array=($(printf "%s" "${ranges[$key]}" | grep -o '[0-9.-]*'))
        lower_bound="${temp_array[0]}"
        upper_bound="${temp_array[1]}"
        actual_values="${list_of_parameters_values[$key]}"
        value_count=$(grep -o ',' <<< "${actual_values}" | wc -l)
        if [ "$value_count" -ne 2 ]; then
            Print_Error "Key ${key} does not have exactly three values in its list."
            return 1
        fi
        IFS=',' read -r -a actual_values <<< "${actual_values:1:-1}"
        for value in "${actual_values[@]}"; do
            if (($(bc <<< "${value} < ${lower_bound}"))) || (($(bc <<< "${value} > ${upper_bound}"))); then
                Print_Error "Parameter values list for key ${key} was not correctly created."
                return 1
            fi
        done
    done
}
