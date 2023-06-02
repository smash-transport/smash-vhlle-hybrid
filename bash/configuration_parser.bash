#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Validate_And_Parse_Configuration_File()
{
    Remove_Comments_In_File "${HYBRID_configuration_file}"  # This checks for existence, too
    # NOTE: We do not want to change the config file, hence we read sections into
    #       local (string) variables and then use these as input to yq to read keys
    #       and deleting the key from the variable content.
    __static__Abort_If_Configuration_File_Is_Not_A_Valid_YAML_File
    __static__Abort_If_Sections_Are_Violating_Any_Requirement
    __static__Abort_If_Invalid_Keys_Were_Used
    # Needed steps:
    #  3. Move valid keys to global constant arrays (?)
    #  4. Parse 'Hybrid-handler' section
    #  5. Parse software sections setting all needed variables
    #      -> see global_variables.bash
    #      -> the software input keys must not be validated but simply put into 'HYBRID_software_input'
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
        gaps_between_indices=$(awk 'NR>1{print $1-x}{x=$1}' <(printf '%d\n' "${software_sections_indices[@]}") | sort -u)
        if [[ "${gaps_between_indices}" != '1' ]]; then
            exit_code=${HYBRID_fatal_wrong_config_file} Print_Fatal_And_Exit\
                'Missing software section(s) in the handler configuration file.'
        fi
    fi
}

function __static__Abort_If_Invalid_Keys_Were_Used()
{
    local -r common_software_keys=(
        'Executable'
        'Input_file'
        'Input_keys'
    )
    local -r yaml_config="$(< "${HYBRID_configuration_file}")"
    local valid_keys invalid_report
    invalid_report=() # Use array entries to split lines to feed into logger
    # Hybrid-Handler section
    valid_keys=()
    # IC section
    valid_keys=(
        "${common_software_keys[@]}"
    )
    __static__Validate_Keys_Of_Section 'IC'
    # Hydro section
    valid_keys=(
        "${common_software_keys[@]}"
    )
    __static__Validate_Keys_Of_Section 'Hydro'
    # Sampler section
    valid_keys=(
        "${common_software_keys[@]}"
    )
    __static__Validate_Keys_Of_Section 'Sampler'
    # Afterburner section
    valid_keys=(
        "${common_software_keys[@]}"
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
    Ensure_That_Given_Variables_Are_Set invalid_report
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
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty valid_keys
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
