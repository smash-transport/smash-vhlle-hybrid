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
        'progress_bar.bash'
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
    cat > ref_scan_combinations.dat << EOF
# Parameter_1: IC.Software_keys.Modi.Collider.Sqrtsnn
# Parameter_2: Hydro.Software_keys.etaS
#
#___Run  Parameter_1  Parameter_2
      1          4.3         0.13
      2          4.3         0.15
      3          4.3         0.17
      4          7.7         0.13
      5          7.7         0.15
      6          7.7         0.17
EOF
    HYBRID_scan_directory='scan_test'
    Call_Codebase_Function Create_And_Populate_Scan_Folder &> /dev/null 9>&1 # Suppress progress bar, too
    cd "${HYBRID_scan_directory}"
    shopt -s nullglob
    local -r list_of_files=(*)
    if [[ ${#list_of_files[@]} -ne 7 ]]; then
        Print_Error 'Expected ' --emph '7' ' files to be created, but ' --emph "${#list_of_files[@]}" ' found.'
        return 1
    fi
    local file values sqrt_snn eta_s
    set -- "4.3 0.13" "4.3 0.15" "4.3 0.17" "7.7 0.13" "7.7 0.15" "7.7 0.17"
    for file in "${list_of_files[@]}"; do
        if [[ "${file}" = "${HYBRID_scan_combinations_filename}" ]]; then
            if ! diff -q "${file}" '../ref_scan_combinations.dat' &> /dev/null; then
                Print_Error 'Scan combinations file expected different.\n'
                diff "${file}" '../ref_scan_combinations.dat'
                return 1
            fi
            continue
        fi
        if [[ ! "${file}" =~ ^${HYBRID_scan_directory}_run_[1-6]\.yaml$ ]]; then
            Print_Error 'Filename ' --emph "${file}" ' not matching expected name.'
            return 1
        fi
        values=($1) # Use word splitting to split values
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

function Make_Test_Preliminary_Operations__scan-create-single-file-LHS()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'global_variables.bash'
        'progress_bar.bash'
        'scan_files_operations.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__scan-create-single-file-LHS()
{
    declare -A list_of_parameters_values=(
        ['IC.Software_keys.Modi.Collider.Sqrtsnn']='[4.3, 7.7]'
        ['Hydro.Software_keys.etaS']='[0.13, 0.17]'
    )
    HYBRID_scan_strategy='LHS'
    HYBRID_number_of_samples=2
    printf '
    Hybrid_handler:
       Scan_strategy: LHS
       Number_of_Samples: 2
    IC:
      Software_keys:
        Modi:
          Collider:
            Sqrtsnn: {Scan: {Range: [4.3, 7.7]}}
    Hydro:
      Software_keys:
        etaS: {Scan: {Range: [0.13, 0.17]}}
    ' > 'config.yaml'
    HYBRID_scan_directory='scan_test'
    Call_Codebase_Function Create_And_Populate_Scan_Folder &> /dev/null 9>&1 # Suppress progress bar, too
    cd "${HYBRID_scan_directory}"
    shopt -s nullglob
    local -r list_of_files=(*)
    if [[ ${#list_of_files[@]} -ne 3 ]]; then
        Print_Error 'Expected ' --emph '3' ' files to be created, but ' --emph "${#list_of_files[@]}" ' found.'
        return 1
    fi
    local file values sqrt_snn eta_s sqrt_snn_gte sqrt_snn_lte eta_s_gte eta_s_lte
    for file in "${list_of_files[@]}"; do
        if [[ "${file}" = "${HYBRID_scan_combinations_filename}" ]]; then
            continue
        fi
        if [[ ! "${file}" =~ ^${HYBRID_scan_directory}_run_[1-2]\.yaml$ ]]; then
            Print_Error 'Filename ' --emph "${file}" ' not matching expected name.'
            return 1
        fi
        values=($(awk 'NR > 3 {print $2, $3}' "${HYBRID_scan_combinations_filename}"))
        sqrt_snn="${values[0]}"
        eta_s="${values[1]}"
        sqrt_snn_gte=$(bc <<< "${sqrt_snn} >= \
        ${list_of_parameters_values['IC.Software_keys.Modi.Collider.Sqrtsnn']:1:-1}")
        sqrt_snn_lte=$(bc <<< "${sqrt_snn} <= \
        ${list_of_parameters_values['IC.Software_keys.Modi.Collider.Sqrtsnn']:1:-1}")
        eta_s_gte=$(bc <<< "${eta_s} >= ${list_of_parameters_values['Hydro.Software_keys.etaS']:1:-1}")
        eta_s_lte=$(bc <<< "${eta_s} <= ${list_of_parameters_values['Hydro.Software_keys.etaS']:1:-1}")

        if ((sqrt_snn_gte == 1 && sqrt_snn_lte == 1 && eta_s_gte == 1 && eta_s_lte == 1)); then
            Print_Error 'Values of ' --emph 'Sqrtsnn' ' or ' --emph 'etaS' ' wrongly set in output file.'
            return 1
        fi
    done
}
