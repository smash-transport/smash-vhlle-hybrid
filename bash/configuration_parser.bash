#===================================================
#
#    Copyright (c) 2023
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
    Remove_Comments_In_File "${HYBRID_configuration_file}"  # This checks for existence, too
    __static__Abort_If_Configuration_File_Is_Not_A_Valid_YAML_File
    __static__Abort_If_Sections_Are_Violating_Any_Requirement
    __static__Abort_If_Invalid_Keys_Were_Used
    __static__Parse_Section 'Hybrid-handler'
    __static__Parse_Section 'IC'
    __static__Parse_Section 'Hydro'
    __static__Parse_Section 'Sampler'
    __static__Parse_Section 'Afterburner'
    # Needed steps:
    #  6. Validate software to be later run for the given software sections (?)
    #
}

function __static__Abort_If_Configuration_File_Is_Not_A_Valid_YAML_File()
{
    if ! yq "${HYBRID_configuration_file}" &> /dev/null; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
            'The handler configuration file does not contain valid YAML syntax.'
    fi
}

function __static__Abort_If_Sections_Are_Violating_Any_Requirement()
{
    local input_section_labels label index valid_software_label software_sections_indices
    # Here word splitting separates keys into array entries, hence we assume keys do not contain spaces!
    input_section_labels=( $(yq 'keys | .[]' "${HYBRID_configuration_file}") )
    for label in "${input_section_labels[@]}"; do
        if Element_In_Array_Equals_To "${label}" "${HYBRID_valid_auxiliary_configuration_sections[@]}"; then
            continue
        else
            for index in "${!HYBRID_valid_software_configuration_sections[@]}"; do
                valid_software_label=${HYBRID_valid_software_configuration_sections[index]}
                if [[ "${valid_software_label}" = "${label}" ]]; then
                    software_sections_indices+=( ${index} )
                    continue 2
                fi
            done
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
                "Invalid section \"${label}\" found in the handler configuration file."
        fi
    done
    # Here all given sections are valid. Check possible duplicates/holes and ordering using the stored indices
    if [[ ${#software_sections_indices[@]} -eq 0 ]]; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
            'No software section was specified in the handler configuration file.'
    elif [[ ${#software_sections_indices[@]} -gt 1 ]]; then
        if [[ $(sort -u <(printf '%d\n' "${software_sections_indices[@]}") | wc -l)\
                -ne ${#software_sections_indices[@]} ]]; then
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
                'The same software section in the handler configuration file cannot be repeated.'
        fi
        if ! sort -C <(printf '%d\n' "${software_sections_indices[@]}"); then
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
                'Software sections in the handler configuration file are out of order.'
        fi
        local gaps_between_indices
        gaps_between_indices=$(awk 'NR>1{print $1-x}{x=$1}'\
                                <(printf '%d\n' "${software_sections_indices[@]}") | sort -u)
        if [[ "${gaps_between_indices}" != '1' ]]; then
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
                'Missing software section(s) in the handler configuration file.'
        fi
    fi
}

function __static__Abort_If_Invalid_Keys_Were_Used()
{
    local -r yaml_config="$(< "${HYBRID_configuration_file}")"
    local valid_keys invalid_report
    invalid_report=() # Use array entries to split lines to feed into logger
    # Hybrid-Handler section
    valid_keys=(
        "${HYBRID_hybrid_handler_valid_keys[@]}"
    )
    __static__Validate_Keys_Of_Section 'Hybrid-handler'
    # IC section
    valid_keys=(
        "${HYBRID_valid_common_software_keys[@]}"
        "${HYBRID_ic_valid_keys[@]}"
    )
    __static__Validate_Keys_Of_Section 'IC'
    # Hydro section
    valid_keys=(
        "${HYBRID_valid_common_software_keys[@]}"
        "${HYBRID_hydro_valid_keys[@]}"
    )
    __static__Validate_Keys_Of_Section 'Hydro'
    # Sampler section
    valid_keys=(
        "${HYBRID_valid_common_software_keys[@]}"
        "${HYBRID_sampler_valid_keys[@]}"
    )
    __static__Validate_Keys_Of_Section 'Sampler'
    # Afterburner section
    valid_keys=(
        "${HYBRID_valid_common_software_keys[@]}"
        "${HYBRID_afterburner_valid_keys[@]}"
    )
    __static__Validate_Keys_Of_Section 'Afterburner'
    # Abort if some validation failed
    if [[ "${#invalid_report[@]}" -ne 0 ]]; then
        exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
            'Following invalid keys found in the handler configuration file:'\
            '---------------------------------------------------------------'\
            "${invalid_report[@]/%/:}"\
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
        invalid_keys=( $(__static__Get_Top_Level_Invalid_Keys_In_Given_YAML_string "${yaml_section}") )
        if [[ ${#invalid_keys[@]} -ne 0 ]]; then
            invalid_report+=( "  ${section_label}" "${invalid_keys[@]/#/    }")
        fi
    fi
}

# NOTE: It is assumed that keys do not contain spaces!
function __static__Get_Top_Level_Invalid_Keys_In_Given_YAML_string()
{
    Ensure_That_Given_Variables_Are_Set valid_keys
    local input_keys key invalid_keys
    input_keys=( $(yq 'keys | .[]' <<< "$1") )
    invalid_keys=()
    for key in "${input_keys[@]}"; do
        if ! Element_In_Array_Equals_To "${key}" "${valid_keys[@]}"; then
            invalid_keys+=( "${key}" )
        fi
    done
    printf '%s ' "${invalid_keys[@]}"
}

function __static__Parse_Section()
{
    local -r\
        section_label=$1\
        yaml_config="$(< "${HYBRID_configuration_file}")"
    local yaml_section
    if Has_YAML_String_Given_Key "${yaml_config}" "${section_label}"; then
        yaml_section="$(Read_From_YAML_String_Given_Key "${yaml_config}" "${section_label}")"
        Call_Function_If_Existing_Or_Exit\
            __static__Parse_Section_${section_label} "${yaml_section}"
    fi
}

function __static__Parse_Section_Hybrid-handler()
{
    local yaml_section=$1
    # No key to be parsed for the moment
    __static__YAML_section_must_be_empty "${yaml_section}" 'Hybrid-handler'
}

function __static__Parse_Section_IC()
{
    local yaml_section key
    yaml_section=$1
    HYBRID_given_software_section+=( "${yaml_section}" )
    __static__Parse_Key_And_Store_It 'Executable' HYBRID_software_executable[IC]
    __static__Parse_Key_And_Store_It 'Input_file' HYBRID_software_base_config_file[IC]
    __static__Parse_Key_And_Store_It 'Software_keys' HYBRID_software_new_input_keys[IC]
    __static__YAML_section_must_be_empty "${yaml_section}" 'IC'
}

function __static__Parse_Section_Hydro()
{
    local yaml_section key
    yaml_section=$1
    HYBRID_given_software_section+=( "${yaml_section}" )
    __static__Parse_Key_And_Store_It 'Executable' HYBRID_software_executable[Hydro]
    __static__Parse_Key_And_Store_It 'Input_file' HYBRID_software_base_config_file[Hydro]
    __static__Parse_Key_And_Store_It 'Software_keys' HYBRID_software_new_input_keys[Hydro]
    __static__YAML_section_must_be_empty "${yaml_section}" 'Hydro'
}

function __static__Parse_Section_Sampler()
{
    local yaml_section key
    yaml_section=$1
    HYBRID_given_software_section+=( "${yaml_section}" )
    __static__Parse_Key_And_Store_It 'Executable' HYBRID_software_executable[Sampler]
    __static__Parse_Key_And_Store_It 'Input_file' HYBRID_software_base_config_file[Sampler]
    __static__Parse_Key_And_Store_It 'Software_keys' HYBRID_software_new_input_keys[Sampler]
    __static__YAML_section_must_be_empty "${yaml_section}" 'Sampler'
}

function __static__Parse_Section_Afterburner()
{
    local yaml_section key
    yaml_section=$1
    HYBRID_given_software_section+=( "${yaml_section}" )
    __static__Parse_Key_And_Store_It 'Executable' HYBRID_software_executable[Afterburner]
    __static__Parse_Key_And_Store_It 'Input_file' HYBRID_software_base_config_file[Afterburner]
    __static__Parse_Key_And_Store_It 'Software_keys' HYBRID_software_new_input_keys[Afterburner]
    __static__YAML_section_must_be_empty "${yaml_section}" 'Afterburner'
}

function __static__Parse_Key_And_Store_It()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty yaml_section
    local key=$1
    declare -n store_variable=$2
    if Has_YAML_String_Given_Key "${yaml_section}" "${key}"; then
        store_variable=$(Read_From_YAML_String_Given_Key "${yaml_section}" "${key}")
        yaml_section="$(Print_YAML_String_Without_Given_Key "${yaml_section}" "${key}")"
    fi
}

function __static__YAML_section_must_be_empty()
{
    local yaml_section=$1
    if [[ "${yaml_section}" != '{}' ]]; then
        Print_Internal_And_Exit\
            "Not all keys in ${2:-some} section have been parsed. Remaining:"\
            "\n${yaml_section}\n"
    fi
}
