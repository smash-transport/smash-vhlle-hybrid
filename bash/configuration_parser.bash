#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: We do not want to change the config file, hence we read sections into
#       local (string) variables and then use these as input to yq to read keys
#       and deleting the key from the variable content.
function Validate_And_Parse_Configuration_File()
{
    Ensure_Given_Files_Exist \
        'A configuration file is needed to run the hybrid handler.' '--' \
        "${HYBRID_configuration_file}"
    __static__Abort_If_Configuration_File_Is_Not_A_Valid_YAML_File
    __static__Abort_If_Sections_Are_Violating_Any_Requirement
    __static__Exchange_Modules
    __static__Abort_If_Invalid_Keys_Were_Used
    __static__Parse_Section 'Hybrid_handler'
    __static__Parse_Section 'IC'
    __static__Parse_Section 'Hydro'
    __static__Parse_Section 'Sampler'
    __static__Parse_Section 'Afterburner'
}

function __static__Exchange_Modules()
{
    local yaml_section valid_key
    local -r yaml_config="$(< "${HYBRID_configuration_file}")"
    if Has_YAML_String_Given_Key "${yaml_config}" "Hybrid_handler"; then
        echo "1"
        yaml_section="$(Read_From_YAML_String_Given_Key "${yaml_config}" "Hybrid_handler")"
        if Has_YAML_String_Given_Key "${yaml_section}" 'Sampler_module'; then
            echo "2"
            __static__Exchange_Sampler_Module
        else
            echo "3"
            Copy_Associative_Array HYBRID_smash_hadron_sampler_valid_keys HYBRID_sampler_valid_keys
        fi
    else 
        echo "4"
        Copy_Associative_Array HYBRID_smash_hadron_sampler_valid_keys HYBRID_sampler_valid_keys
    fi
}

function __static__Abort_If_Configuration_File_Is_Not_A_Valid_YAML_File()
{
    if ! yq "${HYBRID_configuration_file}" &> /dev/null; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
            'The handler configuration file does not contain valid YAML syntax.'
    fi
}

function __static__Abort_If_Sections_Are_Violating_Any_Requirement()
{
    local input_section_labels label index valid_software_label software_sections_indices
    # Here word splitting separates keys into array entries, hence we assume keys do not contain spaces!
    input_section_labels=($(yq 'keys | .[]' "${HYBRID_configuration_file}"))
    software_sections_indices=()
    for label in "${input_section_labels[@]}"; do
        if Element_In_Array_Equals_To "${label}" "${HYBRID_valid_auxiliary_configuration_sections[@]}"; then
            continue
        else
            for index in "${!HYBRID_valid_software_configuration_sections[@]}"; do
                valid_software_label=${HYBRID_valid_software_configuration_sections[index]}
                if [[ "${valid_software_label}" = "${label}" ]]; then
                    software_sections_indices+=(${index})
                    continue 2
                fi
            done
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
                'Invalid section ' --emph "${label}" ' found in the handler configuration file.'
        fi
    done
    # Here all given sections are valid. Check possible duplicates/holes and ordering using the stored indices
    if [[ ${#software_sections_indices[@]} -eq 0 ]]; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
            'No software section was specified in the handler configuration file.'
    elif [[ ${#software_sections_indices[@]} -gt 1 ]]; then
        local -r number_of_distinct_sections=$(sort -u <(printf '%d\n' "${software_sections_indices[@]}") | wc -l)
        if [[ ${number_of_distinct_sections} -ne ${#software_sections_indices[@]} ]]; then
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
                'The same software section in the handler configuration file cannot be repeated.'
        fi
        if ! sort -C <(printf '%d\n' "${software_sections_indices[@]}"); then
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
                'Software sections in the handler configuration file are out of order.'
        fi
        local gaps_between_indices
        gaps_between_indices=$(awk 'NR>1{print $1-x}{x=$1}' \
            <(printf '%d\n' "${software_sections_indices[@]}") | sort -u)
        if [[ "${gaps_between_indices}" != '1' ]]; then
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
                'Missing software section(s) in the handler configuration file.'
        fi
    fi
}

function __static__Abort_If_Invalid_Keys_Were_Used()
{
    local -r yaml_config="$(< "${HYBRID_configuration_file}")"
    local valid_keys invalid_report
    invalid_report=() # Use array entries to split lines to feed into logger
    # Hybrid_handler section
    valid_keys=("${!HYBRID_hybrid_handler_valid_keys[@]}")
    __static__Validate_Keys_Of_Section 'Hybrid_handler'
    # IC section
    valid_keys=("${!HYBRID_ic_valid_keys[@]}")
    __static__Validate_Keys_Of_Section 'IC'
    # Hydro section
    valid_keys=("${!HYBRID_hydro_valid_keys[@]}")
    __static__Validate_Keys_Of_Section 'Hydro'
    # Sampler section
    valid_keys=("${!HYBRID_sampler_valid_keys[@]}")
    __static__Validate_Keys_Of_Section 'Sampler'
    # Afterburner section
    valid_keys=("${!HYBRID_afterburner_valid_keys[@]}")
    __static__Validate_Keys_Of_Section 'Afterburner'
    # Abort if some validation failed
    if [[ "${#invalid_report[@]}" -ne 0 ]]; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
            'Following invalid keys found in the handler configuration file:' \
            '---------------------------------------------------------------' \
            "${invalid_report[@]/%/:}" \
            '---------------------------------------------------------------'
    fi
}

function __static__Validate_Keys_Of_Section()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty yaml_config
    Ensure_That_Given_Variables_Are_Set invalid_report valid_keys
    local -r section_label=$1
    local invalid_keys yaml_section
    if Has_YAML_String_Given_Key "${yaml_config}" "${section_label}"; then
        yaml_section="$(Read_From_YAML_String_Given_Key "${yaml_config}" "${section_label}")"
        invalid_keys=($(__static__Get_Top_Level_Invalid_Keys_In_Given_YAML_string "${yaml_section}"))
        if [[ ${#invalid_keys[@]} -ne 0 ]]; then
            invalid_report+=("  ${section_label}" "${invalid_keys[@]/#/    }")
        fi
    fi
}

# NOTE: It is assumed that keys do not contain spaces!
function __static__Get_Top_Level_Invalid_Keys_In_Given_YAML_string()
{
    Ensure_That_Given_Variables_Are_Set valid_keys
    local input_keys key invalid_keys
    input_keys=($(yq 'keys | .[]' <<< "$1"))
    invalid_keys=()
    for key in "${input_keys[@]}"; do
        if ! Element_In_Array_Equals_To "${key}" "${valid_keys[@]}"; then
            invalid_keys+=("${key}")
        fi
    done
    printf '%s ' "${invalid_keys[@]}"
}

function __static__Parse_Section()
{
    local -r \
        section_label=$1 \
        yaml_config="$(< "${HYBRID_configuration_file}")"
    local yaml_section valid_key
    if Has_YAML_String_Given_Key "${yaml_config}" "${section_label}"; then
        yaml_section="$(Read_From_YAML_String_Given_Key "${yaml_config}" "${section_label}")"
        if [[ ${section_label} = 'Hybrid_handler' ]]; then
            if Has_YAML_String_Given_Key "${yaml_section}" 'LHS_scan' \
                && [[ "${HYBRID_execution_mode}" != 'prepare-scan' ]]; then
                exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
                    'The ' --emph 'LHS_scan' ' key can only be specified in the ' \
                    --emph 'prepare-scan' ' execution mode!'
            fi
        else
            HYBRID_given_software_sections+=("${section_label}")
        fi
        declare -n reference_to_map="HYBRID_${section_label,,}_valid_keys"
        for valid_key in "${!reference_to_map[@]}"; do
            Ensure_That_Given_Variables_Are_Set "${reference_to_map[${valid_key}]}"
            __static__Parse_Key_And_Store_It "${valid_key}" "${reference_to_map[${valid_key}]}"
        done
        __static__YAML_section_must_be_empty "${yaml_section}" "${section_label}"
    fi
}

function __static__Exchange_Sampler_Module()
{
    HYBRID_handler_section_modus['Sampler']=$(Read_From_YAML_String_Given_Key "${yaml_section}" 'Sampler_module')
    if [[ ${HYBRID_handler_section_modus['Sampler']} != 'smash-hadron-sampler' && ${HYBRID_handler_section_modus['Sampler']} != 'FIST-sampler' ]]; then
        echo "A"
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            'The ' --emph 'Sampler_module' ' key must be set to ' \
            --emph 'smash-hadron-sampler' ' or ' --emph 'FIST-sampler' ' in the ' --emph 'Hybrid_handler' \
            ' section.'
    fi
    if [[ ${HYBRID_handler_section_modus['Sampler']} == 'smash-hadron-sampler' ]]; then 
        echo "B"
        Copy_Associative_Array HYBRID_smash_hadron_sampler_valid_keys HYBRID_sampler_valid_keys
    else
        echo "C"
        Copy_Associative_Array HYBRID_FIST_sampler_valid_keys HYBRID_sampler_valid_keys
        HYBRID_software_base_config_file['Sampler']="${HYBRID_default_configurations_folder}/fist_sampler"
    fi
}

function __static__Parse_Key_And_Store_It()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty yaml_section
    local key=$1
    declare -n store_variable=$2
    if Has_YAML_String_Given_Key "${yaml_section}" "${key}"; then
        store_variable=$(Read_From_YAML_String_Given_Key "${yaml_section}" "${key}")
        if Element_In_Array_Equals_To "${key}" "${HYBRID_boolean_keys[@]}"; then
            __static__Validate_Boolean_Value "${key}" "$2"
        fi
        yaml_section="$(Print_YAML_String_Without_Given_Key "${yaml_section}" "${key}")"
    fi
}

function __static__Validate_Boolean_Value()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty store_variable
    local -r key=$1
    if [[ ! "${store_variable^^}" =~ ^(TRUE|FALSE)$ ]]; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit \
            'Invalid value found at ' --emph "${key}: ${store_variable}" \
            '.' 'The value is expected to be a YAML 1.2 boolean one (e.g. ' \
            --emph 'true|false' ').'
    fi
    store_variable=${store_variable^^} # Ensure string is fully capitalized
}

function __static__YAML_section_must_be_empty()
{
    local yaml_section=$1
    if [[ "${yaml_section}" != '{}' ]]; then
        Print_Internal_And_Exit \
            'Not all keys in ' --emph "${2:-some}" ' section have been parsed. Remaining:' \
            --emph "\n${yaml_section}\n"
    fi
}

Make_Functions_Defined_In_This_File_Readonly
