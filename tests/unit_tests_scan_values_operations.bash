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
}

function Unit_Test__scan-create-list-LHS()
{
    declare -A list_of_parameters_values=(
        ['IC.Software_keys.Modi.Collider.Sqrtsnn']='{Range: [4.3, 7.7]}'
        ['Hydro.Software_keys.etaS']='{Range: [0.13, 0.15, 0.17]}'
    )
    declare -A parameter_ranges=(
        ['IC.Software_keys.Modi.Collider.Sqrtsnn']='4.3:7.7'
        ['Hydro.Software_keys.etaS']='0.13:0.17'
    )
    HYBRID_number_of_samples=2
    HYBRID_scan_strategy='LHS'
    Call_Codebase_Function Create_List_Of_Parameters_Values
    function check_range()
    {
        local value=$1
        local range=$2
        local min=$(cut -d: -f1 <<< "$range")
        local max=$(cut -d: -f2 <<< "$range")
        (($(bc <<< "$value >= $min && $value <= $max")))
    }

    # Loop through each parameter and its values
    for param in "${!list_of_parameters_values[@]}"; do
        values="${list_of_parameters_values[$param]}"
        range="${parameter_ranges[$param]}"
        # Check if each value lies within the specified range
        for val in $(sed 's/[][]//g' <<< "$values" | tr ',' '\n'); do
            if ! check_range "$val" "$range"; then
                Print_Error "Value $val for parameter $param is not within the specified range $range.\
                LHS sampling has failed."
                return 1
            fi
        done
    done
}
