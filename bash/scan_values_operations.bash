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
    case "${HYBRID_scan_strategy}" in
        'LHS')
            local parameter
            declare -A list_of_parameters_ranges
            for parameter in "${!list_of_parameters_values[@]}"; do
                __static__Generate_And_Store_Parameter_List_Of_Ranges "${parameter}"
            done
            local key value
            while IFS='=' read -r key value; do
                if Element_In_Array_Equals_To "${key}" "${!list_of_parameters_values[@]}"; then
                    list_of_parameters_values["${key}"]="${value}"
                else
                    Print_Internal_And_Exit \
                        'Processing of parameters failed in ' --emph "${FUNCNAME}" ' function.'
                fi
            done < <(python3 ${HYBRID_python_folder}/latin_hypercube_sampling.py \
                --parameter_names "${!list_of_parameters_ranges[@]}" \
                --parameter_ranges "${list_of_parameters_ranges[@]}" \
                --num_samples ${HYBRID_number_of_samples})
            ;;
        'Combinations')
            local parameter
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
    local -r parameter=$1 scan_map="${list_of_parameters_values["$1"]}"
    local sorted_scan_keys
    sorted_scan_keys="$(yq '. | keys | sort | .. style="flow"' <<< "${scan_map}")"
    readonly sorted_scan_keys
    case "${sorted_scan_keys}" in
        "[Values]")
            list_of_parameters_values["${parameter}"]=$(
                yq '.Values | .. style="flow"' <<< "${scan_map}"
            )
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown ' --emph "${sorted_scan_keys}" 'scan in ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}

function __static__Generate_And_Store_Parameter_List_Of_Ranges()
{
    Ensure_That_Given_Variables_Are_Set list_of_parameters_ranges
    local -r parameter=$1 scan_map="${list_of_parameters_values["$1"]}"
    local sorted_scan_keys
    sorted_scan_keys="$(yq '. | keys | sort | .. style="flow"' <<< "${scan_map}")"
    readonly sorted_scan_keys
    case "${sorted_scan_keys}" in
        "[Range]")
            list_of_parameters_ranges["${parameter}"]=$(
                yq '.Range | .. style="flow"' <<< "${scan_map}"
            )
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown ' --emph "${sorted_scan_keys}" 'scan in ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}
