#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__scan-create-single-file()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'global_variables.bash'
        'scan_files_operations.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__scan-create-single-file()
{
    declare -A list_of_parameters_values=(
        ['IC.Software_keys.Modi.Collider.Sqrtsnn']='[4.3, 7.7]'
        ['Hydro.Software_keys.etaS']='[0.13, 0.15, 0.17]'
    )
    printf '
    IC:
      Software_keys:
        Modi:
          Collider:
            Sqrtsnn: {Scan: {Values: [4.3, 7.7]}}
    Hydro:
      Software_keys:
        etaS: {Scan: {Values: [0.13, 0.15, 0.17]}}
    ' > 'config.yaml'
    HYBRID_scan_directory='scan_test'
    Call_Codebase_Function Create_And_Populate_Scan_Folder
    cd "${HYBRID_scan_directory}"
    shopt -s nullglob
    local -r list_of_files=(*)
    if [[ ${#list_of_files[@]} -ne 6 ]]; then
        Print_Error 'Expected ' --emph '6' ' files to be created, but ' --emph "${#list_of_files[@]}" ' found.'
        return 1
    fi
    local file values sqrt_snn eta_s
    set -- "4.3 0.13" "4.3 0.15" "4.3 0.17" "7.7 0.13" "7.7 0.15" "7.7 0.17"
    for file in "${list_of_files[@]}"; do
        if [[ ! "${file}" =~ ^${HYBRID_scan_directory}_[1-6]\.yaml$ ]]; then
            Print_Error 'Filename ' --emph "${file}" ' not matching expected name.'
            return 1
        fi
        values=( $1 ) # Use word splitting to split values
        shift
        sqrt_snn=$(Read_From_YAML_String_Given_Key "$(< "${file}")" 'IC' 'Software_keys' 'Modi' 'Collider' 'Sqrtsnn')
        if [[ "${sqrt_snn}" != "${values[0]}" ]]; then
            Print_Error 'Value of ' --emph 'Sqrtsnn' ' wrongly set in output file.'
            return 1
        fi
        eta_s=$(Read_From_YAML_String_Given_Key "$(< "${file}")" 'Hydro' 'Software_keys' 'etaS')
        if [[ "${eta_s}" != "${values[1]}" ]]; then
            Print_Error 'Value of ' --emph 'etaS' ' wrongly set in output file.'
            return 1
        fi
    done
}
