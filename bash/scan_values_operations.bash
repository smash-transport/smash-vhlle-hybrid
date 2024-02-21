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
    echo "${list_of_parameters_values[@]}"
    case "${HYBRID_scan_strategy}" in
        'LHS')
            local parameter
            for parameter in "${!list_of_parameters_values[@]}"; do
                __static__Generate_And_Store_Parameter_List_Of_Ranges "${parameter}"
            done
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
    echo "${list_of_parameters_values[@]}"
}

function __static__Generate_And_Store_Parameter_List_Of_Values()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    local -r parameter=$1 scan_map="${list_of_parameters_values["$1"]}"
    local -r sorted_scan_keys="$(yq '. | keys | sort | .. style="flow"' <<< "${scan_map}")"
    case "${sorted_scan_keys}" in
        "[Values]")
            list_of_parameters_values["${parameter}"]=$(
                yq '.Values | .. style="flow"' <<< "${scan_map}"
            )
            ;;
        "[Range]")
            Print_Internal_And_Exit \
                'A range of sample values is currently only supported in Latin Hypercube Sampling.'
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown scan in ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}

function __static__Generate_And_Store_Parameter_List_Of_Ranges()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    local -r parameter=$1 scan_map="${list_of_parameters_values["$1"]}"
    local -r sorted_scan_keys="$(yq '. | keys | sort | .. style="flow"' <<< "${scan_map}")"
    case "${sorted_scan_keys}" in
        "[Values]")
            Print_Internal_And_Exit \
                'Explicit values are not allowed for Latin Hypercube Sampling.'
            ;;
        "[Range]")
            # local values num_elements
            # values=$(
            #     yq '.Values | .. style="flow"' <<< "${scan_map}"
            # )
            # num_elements=$(tr -cd ',' <<< "${values}" | wc -c)
            # if (( num_elements != 2 )); then
            #     Print_Internal_And_Exit \
            #         'The range has to be defined by a lower and an upper bound'
            # fi
            
            # local first_element=${values%%,*}  # Extract first element before comma
            # local second_element=${values#*,}  # Extract substring after the first comma
            # if (( first_element >= second_element )); then
            #     Print_Internal_And_Exit \
            #         'The lower boundary has to be smaller than the upper boundary.'
            # fi

            list_of_parameters_values["${parameter}"]=$(
                yq '.Range | .. style="flow"' <<< "${scan_map}"
            )
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown scan in ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}

