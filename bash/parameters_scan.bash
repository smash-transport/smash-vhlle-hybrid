#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# Since it is not know here how the user has specified the list of scan parameters
# in the YAML configuration, we enforce here the "flow" yq-style, i.e.  '[...]'
#  -> https://mikefarah.gitbook.io/yq/operators/style#set-flow-quote-style
function Format_Scan_Parameters_Lists()
{
    local key
    for key in "${!HYBRID_scan_parameters[@]}"; do
        HYBRID_scan_parameters["${key}"]=$(yq '.. style="flow"' <<< "${HYBRID_scan_parameters["${key}"]}")
    done
}

function __static__Is_Given_Key_Value_A_Valid_Scan()
{
    local -r value="$1"
    if [[ $(yq '. | type' <<< "${value}") != '!!map' ]]; then
        Print_Error 'The given scan\n' --emph "${value}" '\nis not a YAML map.'
        return 1
    elif [[ $(yq '. | keys | .. style="flow"' <<< "${value}") != '[Scan]' ]]; then
        Print_Error \
            'The given scan\n' --emph "${value}" '\nis not a YAML map containing only the ' \
            --emph 'Scan' ' key at top level.'
        return 1
    fi
    local -r scan_keys=$(yq '.Scan | keys | .. style="flow"' <<< "${value}")
    if ! __static__Are_Given_Scan_Keys_Allowed; then
        Print_Error \
            'The value\n' --emph "${value}" '\ndoes not define a valid scan.' \
            'Refer to the documentation to see which are valid scan specifications.'
        return 1
    elif ! __static__Has_Valid_Scan_Correct_Values; then
        Print_Error -l --\
            'The given scan\n' --emph "${value}" '\nis allowed but its specification is invalid.'
        return 1
    fi
}

function __static__Are_Given_Scan_Keys_Allowed()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty scan_keys
    # Here we need to take into account that the Scan keys might be given by the
    # user in an arbitrary order and therefore we need to sort them before comparison
    local given_keys=$(yq '. | sort | .. style="flow"' <<< "${scan_keys}")
    Element_In_Array_Equals_To "${given_keys}" "${HYBRID_valid_scan_specification_keys[@]}"
}

function __static__Has_Valid_Scan_Correct_Values()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty value scan_keys
    case "${scan_keys}" in
        "[Values]" )
            if [[ $(yq '.Scan.Values | type' <<< "${value}") != '!!seq' ]]; then
                Print_Error \
                    'The value ' --emph "$(yq '.Scan.Values' <<< "${value}")" \
                    ' of the ' --emph 'Values' ' key is not a list of parameter values.'
                return 1
            fi
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown scan passed to values validation function' --emph "${FUNCNAME}" '.'
            ;;
    esac
}
