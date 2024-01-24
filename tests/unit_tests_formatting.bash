#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Unit_Test__codebase-formatting()
{
    local formatter_found='FALSE'
    if hash shfmt &> /dev/null; then
        formatter_found='TRUE'
    else
        Print_Error 'Command ' --emph 'shfmt' \
            ' not available, unable to fully check codebase formatting.'
    fi
    local -r max_length=120
    local list_of_source_files files_with_too_long_lines files_with_wrong_formatting file
    list_of_source_files=(
        "${HYBRIDT_repository_top_level_path}"/Hybrid-handler
        "${HYBRIDT_repository_top_level_path}"/**/*.bash
    )
    files_with_too_long_lines=()
    for file in "${list_of_source_files[@]}"; do
        if [[ $(wc -L < "${file}") -gt ${max_length} ]]; then
            files_with_too_long_lines+=("${file}")
            continue
        fi
    done
    if [[ ${formatter_found} = 'TRUE' ]]; then
        # Quoting shfmt manual:
        # "If a given path is a directory, all shell scripts found under that directory will be used."
        files_with_wrong_formatting=(
            $(shfmt -l -ln bash -i 4 -bn -ci -sr -fn "${HYBRIDT_repository_top_level_path}")
        )
    fi
    # Now some nice report to user
    local report_before='FALSE'
    if [[ ${#files_with_too_long_lines[@]} -gt 0 ]]; then
        Print_Error \
            'There are ' --emph "${#files_with_too_long_lines[@]}" ' file(s) with lines longer than ' \
            --emph "${max_length}" ' characters:'
        for file in "${files_with_too_long_lines[@]}"; do
            Print_Error -l -- ' - ' \
                --emph "$(realpath --relative-base="${HYBRIDT_repository_top_level_path}" "${file}")"
        done
        Print_Info '\nPlease adjust too long lines in the above mentioned files.'
        report_before='TRUE'
    fi
    if [[ ${#files_with_wrong_formatting[@]} -gt 0 ]]; then
        if [[ ${report_before} = 'TRUE' ]]; then
            printf '\n'
        fi
        Print_Error \
            'There are ' --emph "${#files_with_wrong_formatting[@]}" ' file(s) wrongly formatted:'
        for file in "${files_with_wrong_formatting[@]}"; do
            Print_Error -l -- ' - ' \
                --emph "$(realpath --relative-base="${HYBRIDT_repository_top_level_path}" "${file}")"
        done
        Print_Info '\nRun ' --emph 'Hybrid-handler format' ' to correctly format the codebase.'
    fi
    if ((${#files_with_too_long_lines[@]} + ${#files_with_wrong_formatting[@]} > 0)) \
        || [[ ${formatter_found} = 'FALSE' ]]; then
        return 1
    fi
}
