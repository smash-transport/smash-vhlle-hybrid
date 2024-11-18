#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Create_Superfluous_Symbolic_Link_To_External_Files_Ensuring_Their_Existence_FIST()
{
    local particle_list_file decays_list_file
    particle_list_file=$(Get_Path_Field_From_Sampler_Config_As_Global_Path 'particle_list_file')
    decays_list_file=$(Get_Path_Field_From_Sampler_Config_As_Global_Path 'decays_list_file')
    Ensure_Input_File_Exists_And_Alert_If_Unfinished "${particle_list_file}"
    Ensure_Input_File_Exists_And_Alert_If_Unfinished "${decays_list_file}"
    if [[ "$(dirname "${particle_list_file}")" != "${HYBRID_software_output_directory[Sampler]}" ]]; then
        ln -s "${particle_list_file}" \
            "${HYBRID_software_output_directory[Sampler]}/$(basename "${particle_list_file}")"
    fi
    if [[ "$(dirname "${decays_list_file}")" != "${HYBRID_software_output_directory[Sampler]}" ]]; then
        ln -s "${decays_list_file}" \
            "${HYBRID_software_output_directory[Sampler]}/$(basename "${decays_list_file}")"
    fi
}

function Transform_Relative_Paths_In_Sampler_Config_File_For_FIST()
{
    local hypersurface_path output_file particle_list_file decays_list_file
    hypersurface_path=$(Get_Path_Field_From_Sampler_Config_As_Global_Path 'hypersurface_file')
    output_file=$(Get_Path_Field_From_Sampler_Config_As_Global_Path 'output_file')
    particle_list_file=$(Get_Path_Field_From_Sampler_Config_As_Global_Path 'particle_list_file')
    decays_list_file=$(Get_Path_Field_From_Sampler_Config_As_Global_Path 'decays_list_file')
    Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
        'TXT' "${HYBRID_software_configuration_file[Sampler]}" \
        "$(printf "%s: %s\n" \
            'hypersurface_file' "${hypersurface_path}" \
            'output_file' "${output_file}" \
            'particle_list_file' "${particle_list_file}" \
            'decays_list_file' "${decays_list_file}")"
}

function Get_Surface_Path_Field_From_Sampler_Config_As_Global_Path_FIST()
{
    Get_Path_Field_From_Sampler_Config_As_Global_Path 'hypersurface_file'
}

function Validate_Configuration_File_Of_FIST()
{
    local -r config_file="${HYBRID_software_configuration_file[Sampler]}"
    local -r allowed_keys=(
        'fist_sampler_mode'
        'nevents'
        'randomseed'
        'particle_list_file'
        'decays_list_file'
        'Bcanonical'
        'Qcanonical'
        'Scanonical'
        'Ccanonical'
        'finite_widths'
        'decays'
        'hypersurface_filetype'
        'hypersurface_file'
        'rescaleTmu'
        'edens'
        'output_file'
        'use_idealHRG_for_means'
        'shear_correction'
        'bulk_correction'
        'speed_of_sound_squared'
        'output_format'
    )
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
            hypersurface_file | output_file | particle_list_file | decays_list_file)
                if [[ "${value}" = '=DEFAULT=' ]]; then
                    ((keys_to_be_found--))
                    continue
                fi
                ;;& # Continue matching other cases below
            hypersurface_file)
                cd "${HYBRID_software_output_directory[Sampler]}"
                if [[ ! -f "${value}" ]]; then
                    cd - > /dev/null
                    Print_Error 'Freeze-out surface file ' --emph "${value}" ' not found!'
                    return 1
                fi
                ((keys_to_be_found--))
                ;;
            particle_list_file)
                ((keys_to_be_found--))
                ;;
            decays_list_file)
                ((keys_to_be_found--))
                ;;
            output_file)
                cd "${HYBRID_software_output_directory[Sampler]}"
                dir_value=$(dirname "${value}")
                if [[ ! -d "${dir_value}" ]]; then
                    cd - > /dev/null
                    Print_Error 'Sampler output folder ' --emph "${value}" ' not found!'
                    return 1
                fi
                ((keys_to_be_found--))
                ;;
            Bcanonical | Qcanonical | Scanonical | Ccanonical | \
                finite_widths | use_idealHRG_for_means | rescaleTmu | shear_correction | bulk_correction)
                if [[ ! "${value}" =~ ^[01]$ ]]; then
                    Print_Error 'Key ' --emph "${key}" ' must be either ' \
                        --emph '0' ' or ' --emph '1' '.'
                    return 1
                fi
                ;;
            nevents)
                if [[ ! "${value}" =~ ^[1-9][0-9]*$ ]]; then
                    Print_Error 'Found not-integer or zero value ' --emph "${value}" \
                        ' for ' --emph "${key}" ' key.'
                    return 1
                fi
                ;;
            output_format | randomseed | decays | fist_sampler_mode | hypersurface_filetype)
                if [[ ! "${value}" =~ ^[0-9]+$ ]]; then
                    Print_Error 'Found not-integer value ' --emph "${value}" \
                        ' for ' --emph "${key}" ' key.'
                    return 1
                fi
                ;;
            *)
                if [[ ! "${value}" =~ ^[+-]?[0-9]+(\.[0-9]*)?$ ]]; then
                    Print_Error 'Found invalid value ' --emph "${value}" \
                        ' for ' --emph "${key}" ' key.'
                    return 1
                fi
                ;;
        esac
    done < "${config_file}"
    # Check that all required keys were found
    if [[ ${keys_to_be_found} -gt 0 ]]; then
        Print_Error 'Either ' --emph 'hypersurface_file' ', ' --emph 'output_file' \
            ' --emph 'particle_list_file' ' or ' ' --emph 'decays_list_file' \
            ' key is missing in sampler configuration file.'
        return 1
    fi
}

function Run_Sampler_Software_FIST()
{
    "${HYBRID_software_executable[Sampler]}" "${sampler_config_file_path}" &>> \
        "${HYBRID_software_output_directory[Sampler]}/${HYBRID_terminal_output[Sampler]}" \
        || Report_About_Software_Failure_For 'Sampler'
}

Make_Functions_Defined_In_This_File_Readonly
