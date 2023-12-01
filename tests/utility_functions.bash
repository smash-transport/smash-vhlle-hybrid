#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Define_Available_Tests_For()
{
    case "$1" in
        unit_tests)
            local -r files_prefix='unit_tests_'
            local -r functions_prefix='Unit_Test__'
            ;;
        functional_tests)
            local -r files_prefix='functional_tests_'
            local -r functions_prefix='Functional_Test__'
            ;;
        *)
            Print_Internal_And_Exit 'Wrong call to ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
    # Source all unit tests files to also deduce existing tests
    local string_to_restore_nullglob file_to_be_sourced files_to_be_sourced
    string_to_restore_nullglob=$(shopt -p nullglob)
    shopt -s nullglob
    files_to_be_sourced=(
        "${HYBRIDT_tests_folder}/${files_prefix}"*.bash
    )
    eval "${string_to_restore_nullglob}" # NOTE: This eval usage is fine
    if [[ ${#files_to_be_sourced[@]} -eq 0 ]]; then
        return
    fi
    for file_to_be_sourced in "${files_to_be_sourced[@]}"; do
        Print_Debug 'Sourcing ' --emph "${file_to_be_sourced}"
        source "${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    # Available tests are based on functions in this file whose names begins with "${functions_prefix}"
    local -r grep_regex='^function[[:space:]]+'"${functions_prefix}"'[-[:alnum:]_:]+\(\)[[:space:]]*$' \
        sed_regex='^function[[:space:]]+'"${functions_prefix}"'([^(]+)\(\)[[:space:]]*$'
    HYBRIDT_tests_to_be_run=(
        # Here word splitting can split names, no space allowed in function name!
        $(grep -hE "${grep_regex}" "${files_to_be_sourced[@]}" \
            | sed -E 's/'"${sed_regex}"'/\1/')
    )
}
