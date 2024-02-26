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
    readonly HYBRID_scan_parameters
}

function Validate_And_Store_Scan_Parameters()
{
    Ensure_That_Given_Variables_Are_Set list_of_parameters_values
    # Manually set the array in order to check at the end if it stayed empty.
    # NOTE: In 'set -u' mode this is needed, otherwise accessing the size would fail for empty arrays.
    list_of_parameters_values=()
    local key parameters parameter counter=0
    for key in "${!HYBRID_scan_parameters[@]}"; do
        if [[ "${HYBRID_scan_parameters["${key}"]}" = '' ]]; then
            continue
        else
            # Here the --unwrapScalar option of yq is meant to strip quotes and colors to properly
            # store the content in a bash array. The yq input is assumed to be a sequence, which
            # is basically true by construction, see 'Format_Scan_Parameters_Lists' function.
            readarray -t parameters < <(yq --unwrapScalar '.[]' <<< "${HYBRID_scan_parameters["${key}"]}")
            for parameter in "${parameters[@]}"; do
                if ! __static__Is_Parameter_To_Be_Scanned \
                    "${parameter}" "${HYBRID_software_new_input_keys["${key}"]}"; then
                    ((counter++)) || true
                else
                    parameter_value=$(
                        Read_From_YAML_String_Given_Key \
                            "${HYBRID_software_new_input_keys["${key}"]}" "${parameter}"
                    )
                    # Get rid of YAML top-level 'Scan' key
                    list_of_parameters_values["${key}.Software_keys.${parameter}"]=$(
                        yq '.Scan' <<< "${parameter_value}"
                    )
                fi
            done
        fi
    done
    if [[ ${counter} -ne 0 ]]; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
            '\nThe hybrid handler configuration file contains ' \
            --emph "${counter}" ' invalid scan specifications.'
    elif [[ ${#list_of_parameters_values[@]} -eq 0 ]]; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
            'The hybrid handler configuration file does not properly specify scan parameters.' \
            'Make sure to specify the ' --emph 'Scan_parameters' ' key in the appropriate sections.'
    fi
}

function __static__Is_Parameter_To_Be_Scanned()
{
    local -r key="$1" yaml_section="$2"
    if ! Has_YAML_String_Given_Key "${yaml_section}" "${key}"; then
        Print_Error \
            'The ' --emph "${key}" ' parameter is asked to be scanned but its value' \
            'was not specified in the corresponding ' --emph 'Software_keys' '.'
        return 1
    fi
    local parameter_value
    parameter_value=$(Read_From_YAML_String_Given_Key "${yaml_section}" "${key}")
    if ! __static__Is_Given_Key_Value_A_Valid_Scan "${parameter_value}"; then
        Print_Error -l -- 'The ' --emph "${key}" \
            ' parameter is asked to be scanned but its value was not properly specified as a scan.'
        return 1
    fi
}

function __static__Is_Given_Key_Value_A_Valid_Scan()
{
    local -r given_scan="$1"
    __static__Check_If_Given_Scan_Is_A_YAML_Map || return 1
    __static__Check_If_Given_Scan_Is_A_YAML_Map_With_Scan_Key_Only || return 1
    # Now the scan keys can be safely extracted. Note that here we need to take into
    # account that the Scan keys might be given by the user in an arbitrary order
    # and therefore we need to sort them before comparison
    local -r sorted_scan_keys=$(__static__Get_Sorted_Scan_Keys)
    __static__Check_If_Given_Scan_Keys_Are_Allowed || return 1
    __static__Check_If_Keys_Of_Given_Scan_Have_Correct_Values || return 1
}

function __static__Check_If_Given_Scan_Is_A_YAML_Map()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty given_scan
    if [[ $(yq '. | tag' <<< "${given_scan}") != '!!map' ]]; then
        Print_Error 'The given scan\n' --emph "${given_scan}" '\nis not a YAML map.'
        return 1
    fi
}

function __static__Check_If_Given_Scan_Is_A_YAML_Map_With_Scan_Key_Only()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty given_scan
    if [[ $(yq '. | keys | .. style="flow"' <<< "${given_scan}") != '[Scan]' ]]; then
        Print_Error \
            'The given scan\n' --emph "${given_scan}" '\nis not a YAML map containing only the ' \
            --emph 'Scan' ' key at top level.'
        return 1
    fi
}

function __static__Get_Sorted_Scan_Keys()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty given_scan
    yq '.Scan | keys | sort | .. style="flow"' <<< "${given_scan}"
}

function __static__Check_If_Given_Scan_Keys_Are_Allowed()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty given_scan sorted_scan_keys
    if ! Element_In_Array_Equals_To "${sorted_scan_keys}" "${HYBRID_valid_scan_specification_keys[@]}"; then
        Print_Error \
            'The value\n' --emph "${sorted_scan_keys}" '\ndoes not define a valid scan.' \
            'Refer to the documentation to see which are valid scan specifications.'
        return 1
    fi
}

function __static__Check_If_Keys_Of_Given_Scan_Have_Correct_Values()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty given_scan sorted_scan_keys
    if ! __static__Has_Valid_Scan_Correct_Values; then
        Print_Error -l -- 'The given scan\n' --emph "${given_scan}" '\nis allowed but its specification is invalid.'
        return 1
    fi
}

function __static__Has_Valid_Scan_Correct_Values()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty given_scan sorted_scan_keys
    case "${sorted_scan_keys}" in
        "[Values]")
            if [[ $(yq '.Scan.Values | tag' <<< "${given_scan}") != '!!seq' ]]; then
                Print_Error \
                    'The value ' --emph "$(yq '.Scan.Values' <<< "${given_scan}")" \
                    ' of the ' --emph 'Values' ' key is not a list of parameter values.'
                return 1
            fi
            local list_of_value_types
            list_of_value_types=($(yq '.Scan.Values[] | tag' <<< "${given_scan}" | sort -u))
            # If there is more than a type it is in general an error, unless there are exactly two,
            # which are 'int' and 'float' (this is accepted). Note that the test is done on the
            # concatenation of the values against 'float int' as the types are guaranteed to be sorted.
            if [[ ${#list_of_value_types[@]} -ne 1 ]]; then
                if [[ ${#list_of_value_types[@]} -ne 2 || "${list_of_value_types[*]//!!/}" != 'float int' ]]; then
                    Print_Error \
                        'The parameter values have different YAML types: ' \
                        --emph "${list_of_value_types[*]//!!/}" '.'
                    return 1
                fi
            elif [[ ! ${list_of_value_types[0]} =~ ^!!(bool|int|float)$ ]]; then
                Print_Error \
                    'Parameter scans with values of ' --emph "${list_of_value_types[0]//!!/}" \
                    ' type are not allowed.' 'Valid parameter types are ' --emph 'bool int float' ', only.'
                return 1
            fi
            ;;
        "[Range]")
            if [[ $(yq '.Scan.Range | tag' <<< "${given_scan}") != '!!seq' ]]; then
                Print_Error \
                    'The value ' --emph "$(yq '.Scan.Range' <<< "${given_scan}")" \
                    ' of the ' --emph 'Values' ' key is not a list of parameter values.'
                return 1
            fi
            local list_of_value_types num_values first_value second_value
            list_of_value_types=($(yq '.Scan.Range[] | tag' <<< "${given_scan}" | sort -u))
            # If there is more than a type it is in general an error, unless there are exactly two,
            # which are 'int' and 'float' (this is accepted). Note that the test is done on the
            # concatenation of the values against 'float int' as the types are guaranteed to be sorted.
            if [[ ${#list_of_value_types[@]} -ne 1 ]]; then
                if [[ ${#list_of_value_types[@]} -ne 2 || "${list_of_value_types[*]//!!/}" != 'float int' ]]; then
                    Print_Error \
                        'The parameter values have different YAML types: ' \
                        --emph "${list_of_value_types[*]//!!/}" '.'
                    return 1
                fi
            elif [[ ! ${list_of_value_types[0]} =~ ^!!(bool|int|float)$ ]]; then
                Print_Error \
                    'Parameter scans with values of ' --emph "${list_of_value_types[0]//!!/}" \
                    ' type are not allowed.' 'Valid parameter types are ' --emph 'bool int float' ', only.'
                return 1
            fi
            num_values=$(yq '.Scan.Range | length' <<< "${given_scan}")
            if ((num_values != 2)); then
                Print_Error \
                    'Exactly two values are expected for the range. ' \
                    'The given range is ' --emph "${num_values}" ' long.'
                return 1
            fi
            first_value=$(yq '.Scan.Range[0]' <<< "${given_scan}")
            second_value=$(yq '.Scan.Range[1]' <<< "${given_scan}")
            if [[ $(awk 'BEGIN{print ('$first_value' < '$second_value') ? "true" : "false"}') == "false" ]]; then
                Print_Error \
                    'The first value must be smaller than the second value in the Range. '
                return 1
            fi
            ;;
        *)
            Print_Internal_And_Exit \
                'Unknown scan passed to ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
}
