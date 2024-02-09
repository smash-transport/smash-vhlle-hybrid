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
    if false; then
        # This is where the Latin Hypercube Sampling algorithm has to be called
        # in order to call the Python script and use its output to fill the
        # 'list_of_parameters_values' array, e.g. in a 'while read' loop.
        # The if-clause above should be on a new boolean key to be given in the
        # generic Hybrid_handler section.
        :
    else
        local parameter
        for parameter in "${!list_of_parameters_values[@]}"; do
            __static__Generate_And_Store_Parameter_List_Of_Values "${parameter}"
        done
    fi
}

function __static__Generate_And_Store_Parameter_List_Of_Values()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    local -r parameter=$1 scan_map="${list_of_parameters_values["$1"]}"
    local -r sorted_scan_keys="$(yq '. | keys | sort | .. style="flow"' <<< "${scan_map}")"
    case "${sorted_scan_keys}" in
        "[Values]" )
            list_of_parameters_values["${parameter}"]=$(
                yq '.Values | .. style="flow"' <<< "${scan_map}"
            )
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown scan in ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}
