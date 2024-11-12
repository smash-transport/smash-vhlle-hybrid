#===================================================
#
#    Copyright (c) 22024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function __static__Create_Superfluous_Symbolic_Link_To_External_Files_Ensuring_Their_Existence_SMASH()
{
    :
}

function __static__Transform_Relative_Paths_In_Sampler_Config_File_For_SMASH()
{
    local freezeout_path output_directory
    freezeout_path=$(__static__Get_Path_Field_From_Sampler_Config_As_Global_Path_SMASH 'surface')
    output_directory=$(__static__Get_Path_Field_From_Sampler_Config_As_Global_Path_SMASH 'spectra_dir')
    Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
        'TXT' "${HYBRID_software_configuration_file[Sampler]}" \
        "$(printf "%s: %s\n" \
            'surface' "${freezeout_path}" \
            'spectra_dir' "${output_directory}")"
}

function __static__Get_Surface_Path_Field_From_Sampler_Config_As_Global_Path_SMASH()
{
    __static__Get_Path_Field_From_Sampler_Config_As_Global_Path_SMASH 'surface'
}

function __static__Get_Path_Field_From_Sampler_Config_As_Global_Path_SMASH()
{
    local field value
    field="$1"
    # We assume here that the configuration file is fine as it was validated before
    value=$(awk -v name="${field}" '$1 == name {print $2; exit}' \
        "${HYBRID_software_configuration_file[Sampler]}")
    if [[ "${value}" = '=DEFAULT=' ]]; then
        case "${field}" in
            surface)
                printf "${HYBRID_software_output_directory[Hydro]}/freezeout.dat"
                ;;
            spectra_dir)
                printf "${HYBRID_software_output_directory[Sampler]}"
                ;;
        esac
    else
        cd "${HYBRID_software_output_directory[Sampler]}" || exit ${HYBRID_fatal_builtin}
        # If realpath succeeds, it prints the path that is the result of the function
        if ! realpath "${value}" 2> /dev/null; then
            exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
                'Unable to transform relative path ' --emph "${value}" ' into global one.'
        fi
        cd - > /dev/null || exit ${HYBRID_fatal_builtin}
    fi
}

function __static__Check_For_Required_Keys_SMASH()
{
    local -r config_file="${HYBRID_software_configuration_file[Sampler]}"
    local -r allowed_keys=(
        'surface'
        'spectra_dir'
        'number_of_events'
        'rescatter'
        'weakContribution'
        'shear'
        'bulk'
        'ecrit'
        'Nbins'
        'q_max'
        'cs2'
        'ratio_pressure_energydensity'
    )
    local keys_to_be_found
    keys_to_be_found=2
    while read key value; do
        if ! Element_In_Array_Equals_To "${key}" "${allowed_keys[@]}"; then
            Print_Error 'Invalid key ' --emph "${key}" ' found in sampler configuration file.'
            return 1
        fi
        case "${key}" in
            surface | spectra_dir)
                if [[ "${value}" = '=DEFAULT=' ]]; then
                    ((keys_to_be_found--))
                    continue
                fi
                ;;& # Continue matching other cases below
            surface)
                cd "${HYBRID_software_output_directory[Sampler]}"
                if [[ ! -f "${value}" ]]; then
                    cd - > /dev/null
                    Print_Error 'Freeze-out surface file ' --emph "${value}" ' not found!'
                    return 1
                fi
                ((keys_to_be_found--))
                ;;
            spectra_dir)
                cd "${HYBRID_software_output_directory[Sampler]}"
                if [[ ! -d "${value}" ]]; then
                    cd - > /dev/null
                    Print_Error 'Sampler output folder ' --emph "${value}" ' not found!'
                    return 1
                fi
                ((keys_to_be_found--))
                ;;
            rescatter | weakContribution | shear | bulk)
                if [[ ! "${value}" =~ ^[01]$ ]]; then
                    Print_Error 'Key ' --emph "${key}" ' must be either ' \
                        --emph '0' ' or ' --emph '1' '.'
                    return 1
                fi
                ;;
            number_of_events | Nbins)
                if [[ ! "${value}" =~ ^[1-9][0-9]*$ ]]; then
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
        Print_Error 'Either ' --emph 'surface' ' or ' --emph 'spectra_dir' \
            ' key is missing in sampler configuration file.'
        return 1
    fi
}

function __static__Run_Sampler_Software_SMASH()
{
    "${HYBRID_software_executable[Sampler]}" 'events' '1' \
        "${sampler_config_file_path}" &>> \
        "${HYBRID_software_output_directory[Sampler]}/${HYBRID_terminal_output[Sampler]}" \
        || Report_About_Software_Failure_For 'Sampler'
}

Make_Functions_Defined_In_This_File_Readonly
