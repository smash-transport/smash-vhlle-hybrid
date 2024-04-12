#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_Sampler()
{
    Create_Output_Directory_For 'Sampler'
    Ensure_Given_Files_Do_Not_Exist "${HYBRID_software_configuration_file[Sampler]}"
    Ensure_Given_Files_Exist "${HYBRID_software_base_config_file[Sampler]}"
    Copy_Base_Configuration_To_Output_Folder_For 'Sampler'
    Replace_Keys_In_Configuration_File_If_Needed_For 'Sampler'
    __static__Validate_Sampler_Config_File
    __static__Check_If_Sampler_Configuration_Is_Consistent_With_Hydro
    __static__Transform_Relative_Paths_In_Sampler_Config_File
    __static__Create_Superfluous_Symbolic_Link_To_Freezeout_File_Ensuring_Its_Existence
}

function Ensure_All_Needed_Input_Exists_Sampler()
{
    Ensure_Given_Folders_Exist "${HYBRID_software_output_directory[Sampler]}"
    Ensure_Given_Files_Exist "${HYBRID_software_configuration_file[Sampler]}"
    # This is already done preparing the input file, but it's logically belonging here.
    # Therefore, we repeat the validation, as its cost is substantially negligible.
    __static__Validate_Sampler_Config_File
}

function Ensure_Run_Reproducibility_Sampler()
{
    Copy_Hybrid_Handler_Config_Section 'Sampler' \
        "${HYBRID_software_output_directory[Sampler]}" \
        "$(dirname "$(realpath "${HYBRID_software_executable[Sampler]}")")"
}

function Run_Software_Sampler()
{
    Separate_Terminal_Output_For 'Sampler'
    local -r sampler_config_file_path="${HYBRID_software_configuration_file[Sampler]}"
    cd "${HYBRID_software_output_directory[Sampler]}"
    "${HYBRID_software_executable[Sampler]}" 'events' '1' \
        "${sampler_config_file_path}" &>> \
        "${HYBRID_software_output_directory[Sampler]}/${HYBRID_terminal_output[Sampler]}" \
        || Report_About_Software_Failure_For 'Sampler'
}

#===================================================================================================

function __static__Validate_Sampler_Config_File()
{
    if ! __static__Is_Sampler_Config_Valid; then
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            "The sampler configuration file is invalid."
    fi
}

function __static__Transform_Relative_Paths_In_Sampler_Config_File()
{
    local freezeout_path output_directory
    freezeout_path=$(__static__Get_Path_Field_From_Sampler_Config_As_Global_Path 'surface')
    output_directory=$(__static__Get_Path_Field_From_Sampler_Config_As_Global_Path 'spectra_dir')
    Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
        'TXT' "${HYBRID_software_configuration_file[Sampler]}" \
        "$(printf "%s: %s\n" \
            'surface' "${freezeout_path}" \
            'spectra_dir' "${output_directory}")"
}

# The following symbolic link is not needed by the sampler, as the sampler only refers to information
# specified in its input file. However, we want to have all input for a software in the output folder
# for future easier reproducibility (and we do so for all software handled in the codebase).
function __static__Create_Superfluous_Symbolic_Link_To_Freezeout_File_Ensuring_Its_Existence()
{
    local freezeout_path
    freezeout_path=$(__static__Get_Path_Field_From_Sampler_Config_As_Global_Path 'surface')
    Ensure_Input_File_Exists_And_Alert_If_Unfinished "${freezeout_path}"
    if [[ "$(dirname "${freezeout_path}")" != "${HYBRID_software_output_directory[Sampler]}" ]]; then
        ln -s "${freezeout_path}" \
            "${HYBRID_software_output_directory[Sampler]}/freezeout.dat"
    fi
}

#===================================================================================================

function __static__Is_Sampler_Config_Valid()
{
    local -r config_file="${HYBRID_software_configuration_file[Sampler]}"
    # Remove empty lines from configuration file
    if ! sed -i '/^[[:space:]]*$/d' "${config_file}"; then
        Print_Internal_And_Exit "Empty lines removal in ${FUNCNAME} failed."
    fi
    # Check if the config file is empty
    if [[ ! -s "${config_file}" ]]; then
        Print_Error 'Sampler configuration file is empty.'
        return 1
    fi
    # Check for two columns in each line
    if [[ $(awk 'NF!=2 {exit 1}' "${config_file}") ]]; then
        Print_Error 'Each line should consist of two columns.'
        return 1
    fi
    # Check that no key is repeated
    if [[ $(awk '{print $1}' "${config_file}" | sort | uniq -d) != '' ]]; then
        Print_Error 'Found repeated key in sampler configuration file.'
        return 1
    fi
    # Define allowed keys as an array
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

function __static__Check_If_Sampler_Configuration_Is_Consistent_With_Hydro()
{
    local -r config_sampler="${HYBRID_software_configuration_file[Sampler]}"
    if Element_In_Array_Equals_To 'Hydro' "${HYBRID_given_software_sections[@]}"; then
        local -r config_hydro="${HYBRID_software_configuration_file[Hydro]}"
        local shear_hydro shear_hydro_param bulk_hydro bulk_hydro_param \
            ecrit_hydro
        shear_hydro=0
        shear_hydro_param=0
        bulk_hydro=0
        bulk_hydro_param=0
        ecrit_hydro=0.5
        while read key value; do
            case "${key}" in
                etaS)
                    shear_hydro=$(bc -l <<< "${value}>0")
                    ;;
                etaSparam)
                    shear_hydro_param=$(bc -l <<< "${value}>0")
                    ;;
                zetaS)
                    bulk_hydro=$(bc -l <<< "${value}>0")
                    ;;
                zetaSparam)
                    bulk_hydro_param=$(bc -l <<< "${value}>0")
                    ;;
                e_crit)
                    ecrit_hydro=${value}
                    ;;
            esac
        done < "${config_hydro}"
        local is_hydro_shear is_hydro_bulk
        is_hydro_shear=0
        is_hydro_bulk=0
        if [[ "${shear_hydro}" -eq 1 || "${shear_hydro_param}" -eq 1 ]]; then
            is_hydro_shear=1
        fi
        if [[ "${bulk_hydro}" -eq 1 || "${bulk_hydro_param}" -eq 1 ]]; then
            is_hydro_bulk=1
        fi
        local is_sampler_shear is_sampler_bulk \
            ecrit_sampler
        is_sampler_shear=1
        is_sampler_bulk=0
        ecrit_sampler=0.5
        while read key value; do
            case "${key}" in
                shear)
                    is_sampler_shear=${value}
                    ;;
                bulk)
                    is_sampler_bulk=${value}
                    ;;
                ecrit)
                    ecrit_sampler=${value}
                    ;;
            esac
        done < "${config_sampler}"
        if [[ "${is_hydro_shear}" -eq 1 && "${is_sampler_shear}" -eq 0 ]]; then
            __static__State_Inconsistency_Of_Sampler_With_Hydro 'shear'
        fi
        if [[ "${is_hydro_bulk}" -eq 1 && "${is_sampler_bulk}" -eq 0 ]]; then
            __static__State_Inconsistency_Of_Sampler_With_Hydro 'bulk'
        fi
        if ! awk '{if($1==$2){exit 0}else{exit 1}}' <<< "${ecrit_hydro} ${ecrit_sampler}" &> /dev/null; then
            Print_Attention 'The threshold energy density in the sampler (' \
                --emph "${ecrit_sampler}" ')\nis not equal to the threshold energy density in hydrodynamics (' \
                --emph "${ecrit_hydro}" ').\n' \
                --emph 'ecrit' ' in the sampler configuration file is reset to ' --emph "${ecrit_hydro}" '!'
            Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File \
                'TXT' "${config_sampler}" \
                "$(printf "%s    %s\n" 'ecrit' "${ecrit_hydro}")"
        fi
    fi
}

function __static__State_Inconsistency_Of_Sampler_With_Hydro()
{
    PrintAttention 'The sampler and hydrodynamics parameters' \
        'are inconsistent in values for ' --emph "$1" ' correction.' \
        'Viscous corrections are present in hydrodynamic stage,' \
        'but will not be applied in the Cooper-Frye sampling,' \
        'Please, ensure that this is desired behavior.'
}

function __static__Get_Path_Field_From_Sampler_Config_As_Global_Path()
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

Make_Functions_Defined_In_This_File_Readonly
