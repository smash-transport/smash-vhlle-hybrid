#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: Here it is assumed that the 'list_of_parameters_values' is containing the
#       full period-separated list of YAML keys as array keys and the "scan object"
#       as values. This function will replace the array values with plain lists of
#       parameter values.
function Create_List_Of_Parameters_Values()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    local parameter
    case "${HYBRID_scan_strategy}" in
        'LHS')
            declare -A list_of_parameters_ranges
            for parameter in "${!list_of_parameters_values[@]}"; do
                __static__Generate_And_Store_Parameter_Ranges "${parameter}"
            done
            # Here the python script which generates the parameters values is assumed to print
            # lists of values in the form: 'parameter.name=[x1,x2,x3,...]' and this is parsed
            # back into the 'list_of_parameters_values' array in a while-read construct.
            local key value
            while IFS='=' read -r key value; do
                if Element_In_Array_Equals_To "${key}" "${!list_of_parameters_values[@]}"; then
                    list_of_parameters_values["${key}"]="${value}"
                else
                    Print_Internal_And_Exit \
                        'Processing of parameters failed in ' --emph "${FUNCNAME}" ' function.'
                fi
            done < <(${HYBRID_external_python_scripts[Latin_hypercube_sampling]} \
                --parameter_names "${!list_of_parameters_ranges[@]}" \
                --parameter_ranges "${list_of_parameters_ranges[@]}" \
                --num_samples ${HYBRID_number_of_samples})
            ;;
        'Combinations')
            for parameter in "${!list_of_parameters_values[@]}"; do
                __static__Generate_And_Store_Parameter_List_Of_Values "${parameter}"
            done
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown scan strategy in ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}

function __static__Generate_And_Store_Parameter_List_Of_Values()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    __static__Extract_Parameter_Attribute_And_Store_It 'Values' "$1" 'list_of_parameters_values'
}

function __static__Generate_And_Store_Parameter_Ranges()
{
    Ensure_That_Given_Variables_Are_Set list_of_parameters_ranges
    __static__Extract_Parameter_Attribute_And_Store_It 'Range' "$1" 'list_of_parameters_ranges'
}

function __static__Extract_Parameter_Attribute_And_Store_It()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    local -r \
        entity=$1 \
        parameter=$2 \
        scan_map="${list_of_parameters_values[$2]}"
    declare -n reference_to_storage=$3
    local sorted_scan_keys
    sorted_scan_keys="$(yq '. | keys | sort | .. style="flow"' <<< "${scan_map}")"
    readonly sorted_scan_keys
    case "${sorted_scan_keys}" in
        "[Range]" | "[Values]")
            reference_to_storage["${parameter}"]=$(
                yq '.'"${entity}"' | .. style="flow"' <<< "${scan_map}"
            )
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown ' --emph "${sorted_scan_keys}" 'scan in ' --emph "${FUNCNAME[1]}" ' function.'
            ;;
    esac
}
