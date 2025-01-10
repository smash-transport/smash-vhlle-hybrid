#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Check_If_Software_Produced_Expected_Output()
{
    local -r block="$1" folder="$2"
    local expected_output_files
    case "${block}" in
        IC | Hydro)
            expected_output_files=6
            ;;
        Sampler_SMASH)
            expected_output_files=5
            ;;
        Sampler_FIST)
            expected_output_files=7
            ;;
        Afterburner)
            expected_output_files=7
            ;;
        *)
            Print_Internal_And_Exit 'Invalid case branch entered in ' --emph "${FUNCNAME}."
            ;;
    esac
    local -r folder_content=("${folder}"/*)
    if [[ ${#folder_content[@]} -ne 1 || ! -d ${folder_content[0]} ]]; then
        exit_code=${HYBRID_failure_exit_code} Print_Fatal_And_Exit \
            'Not exactly one ID folder found in ' --emph "${folder}" '.'
    fi
    unfinished_files=("${folder}"/*/*.{unfinished,lock})
    output_files=("${folder}"/*/*)
    if [[ ${#unfinished_files[@]} -gt 0 ]]; then
        exit_code=${HYBRID_failure_exit_code} Print_Fatal_And_Exit \
            'Some unexpected ' --emph '.{unfinished,lock}' ' output file remained' \
            'in ' --emph "${folder}"
        return 1
    elif [[ ${#output_files[@]} -ne ${expected_output_files} ]]; then
        exit_code=${HYBRID_failure_exit_code} Print_Fatal_And_Exit \
            'Expected ' --emph "${expected_output_files}" ' output files in ' \
            --emph "${folder}" " folder, but ${#output_files[@]} found."
        return 1
    fi
}
