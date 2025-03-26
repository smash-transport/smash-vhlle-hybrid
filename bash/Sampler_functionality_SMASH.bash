#===================================================
#
#    Copyright (c) 2024-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Create_Superfluous_Symbolic_Link_To_External_Files_Ensuring_Their_Existence_For_SMASH()
{
    # There is nothing to be done for SMASH, as the only external input file is the freezout surface
    # which is treated separately.
    :
}

function Transform_Relative_Paths_In_Sampler_Config_File_For_SMASH()
{
    local surface_key output_dir_key freezeout_path output_directory
    if Is_Version "${HYBRID_software_version[Sampler]}" -lt '3.2'; then
        surface_key='surface'
        output_dir_key='spectra_dir'
    else
        surface_key='surface_file'
        output_dir_key='output_dir'
    fi
    freezeout_path=$(Get_Path_Field_From_Sampler_Config_As_Global_Path "${surface_key}")
    output_directory=$(Get_Path_Field_From_Sampler_Config_As_Global_Path "${output_dir_key}")
    Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
        'TXT' "${HYBRID_software_configuration_file[Sampler]}" \
        "$(printf "%s: %s\n" \
            "${surface_key}" "${freezeout_path}" \
            "${output_dir_key}" "${output_directory}")"
}

function Get_Surface_Path_Field_From_Sampler_Config_As_Global_Path_For_SMASH()
{
    local surface_key
    if Is_Version "${HYBRID_software_version[Sampler]}" -lt '3.2'; then
        surface_key='surface'
    else
        surface_key='surface_file'
    fi
    Get_Path_Field_From_Sampler_Config_As_Global_Path "${surface_key}"
}

function Validate_Configuration_File_Of_SMASH()
{
    local -r config_file="${HYBRID_software_configuration_file[Sampler]}"
    local allowed_keys=(
        'number_of_events'
        'shear'
        'bulk'
        'ecrit'
        'cs2'
        'ratio_pressure_energydensity'
    )
    local surface_key output_dir_key
    if Is_Version "${HYBRID_software_version[Sampler]}" -lt '3.2'; then
        surface_key='surface'
        output_dir_key='spectra_dir'
    else
        surface_key='surface_file'
        output_dir_key='output_dir'
        allowed_keys+=('create_root_output')
    fi
    allowed_keys+=("${surface_key}" "${output_dir_key}")
    readonly allowed_keys
    local keys_to_be_found
    keys_to_be_found=4
    while read key value comment; do
        if [[ "${key}" =~ ^# ]]; then
            continue
        fi
        if ! Element_In_Array_Equals_To "${key}" "${allowed_keys[@]}"; then
            Print_Error 'Invalid key ' --emph "${key}" ' found in sampler configuration file.'
            return 1
        fi
        case "${key}" in
            "${surface_key}" | "${output_dir_key}")
                if [[ "${value}" = '=DEFAULT=' ]]; then
                    ((keys_to_be_found--))
                    continue
                fi
                ;;& # Continue matching other cases below
            number_of_events | ecrit)
                ((keys_to_be_found--))
                ;;&
            "${surface_key}")
                cd "${HYBRID_software_output_directory[Sampler]}"
                if [[ ! -f "${value}" ]]; then
                    cd - > /dev/null
                    Print_Error 'Freeze-out surface file ' --emph "'${value}'" ' not found!'
                    return 1
                fi
                ((keys_to_be_found--))
                ;;
            "${output_dir_key}")
                cd "${HYBRID_software_output_directory[Sampler]}"
                if [[ ! -d "${value}" ]]; then
                    cd - > /dev/null
                    Print_Error 'Sampler output folder ' --emph "'${value}'" ' not found!'
                    return 1
                fi
                ((keys_to_be_found--))
                ;;
            shear | bulk | create_root_output)
                if [[ ! "${value}" =~ ^[01]$ ]]; then
                    Print_Error 'Key ' --emph "${key}" ' must be either ' \
                        --emph '0' ' or ' --emph '1' '.'
                    return 1
                fi
                ;;
            number_of_events)
                if [[ ! "${value}" =~ ^[1-9][0-9]*$ ]]; then
                    Print_Error 'Found non-integer value ' --emph "'${value}'" \
                        ' for ' --emph "${key}" ' key.'
                    return 1
                fi
                ;;
            *)
                if [[ ! "${value}" =~ ^[+-]?[0-9]+(\.[0-9]*)?$ ]]; then
                    Print_Error 'Found invalid value ' --emph "'${value}'" \
                        ' for ' --emph "${key}" ' key.'
                    return 1
                fi
                ;;
        esac
    done < "${config_file}"
    # Check that all required keys were found
    if [[ ${keys_to_be_found} -gt 0 ]]; then
        Print_Error 'One or more mandatory keys are missing in sampler configuration file.'
        return 1
    fi
}

function Run_Sampler_Software_For_SMASH()
{
    if Is_Version "${HYBRID_software_version[Sampler]}" -lt '3.2'; then
        command_line_options=('events' '1' "${sampler_config_file_path}")
    else
        command_line_options=('--config' "${sampler_config_file_path}" '--num' '1')
    fi
    "${HYBRID_software_executable[Sampler]}" "${command_line_options[@]}" &>> \
        "${HYBRID_software_output_directory[Sampler]}/${HYBRID_terminal_output[Sampler]}" \
        || Report_About_Software_Failure_For 'Sampler'
}

Make_Functions_Defined_In_This_File_Readonly
