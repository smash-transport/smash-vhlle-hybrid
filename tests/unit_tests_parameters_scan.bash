#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__parameters-scan-format-lists()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'global_variables.bash'
        'parameters_scan.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__parameters-scan-format-lists()
{
    HYBRID_scan_parameters=(
        [IC]=$'- General.Randomseed\n- General.End_Time'
        [Hydro]='[etaS,e_crit]'
        [Sampler]='[shear, bulk]'
        [Afterburner]=''
    )
    Call_Codebase_Function Format_Scan_Parameters_Lists
    declare -Ar reference_values=(
        [IC]='[General.Randomseed, General.End_Time]'
        [Hydro]='[etaS, e_crit]'
        [Sampler]='[shear, bulk]'
        [Afterburner]=''
    )
    local key counter=0
    for key in "${!reference_values[@]}"; do
        if [[ "${HYBRID_scan_parameters["${key}"]}" != "${reference_values["${key}"]}" ]]; then
            Print_Error 'Formatting of ' --emph "${key}" ' scan parameters failed.'
            ((counter++))
        fi
    done
    return ${counter}
}
