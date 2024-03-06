#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__scan-create-list()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'global_variables.bash'
        'scan_values_operations.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__scan-create-list()
{
    declare -A list_of_parameters_values=(
        ['IC.Software_keys.Modi.Collider.Sqrtsnn']='{Values: [4.3, 7.7]}'
        ['Hydro.Software_keys.etaS']='{Values: [0.13, 0.15, 0.17]}'
    )
    Call_Codebase_Function Create_List_Of_Parameters_Values
    if [[ "${list_of_parameters_values[IC.Software_keys.Modi.Collider.Sqrtsnn]}" != '[4.3, 7.7]' ]] \
        || [[ "${list_of_parameters_values[Hydro.Software_keys.etaS]}" != '[0.13, 0.15, 0.17]' ]]; then
        Print_Error 'Parameters values list was not correctly created.'
        return 1
    fi
}
