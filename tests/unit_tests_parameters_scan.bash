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
        'parameters_scan_validation.bash'
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

function Make_Test_Preliminary_Operations__parameters-scan-YAML-scan-syntax()
{
    Make_Test_Preliminary_Operations__parameters-scan-format-lists
}

function Unit_Test__parameters-scan-YAML-scan-syntax()
{
    local value values
    values=(
        'scalar' '[a,b,c]' 'True' '42' # Not a map
        '{Scan: XX, Wrong: YY}'        # Not a map with Scan only
        # Wrong scans
        '{Scan: {Wrong: XX}}'
        '{Scan: {Values: String}}'
        '{Scan: {Values: True}}'
        '{Scan: {Values: 42}}'
        '{Scan: {Values: [42, False, 3.14]}}'
        '{Scan: {Values: [42, 3.14]}}'
        '{Scan: {Values: ["Hi", "Bye"]}}'
    )
    for value in "${values[@]}" ; do
        Call_Codebase_Function __static__Is_Given_Key_Value_A_Valid_Scan "${value}" #&> /dev/null
        if [[ $? -eq 0 ]]; then
            Print_Error 'Scan syntax validation for\n' --emph "${value}" '\nunexpectedly succeeded.'
            return 1
        fi
    done
    value='{Scan: {Values: [1,2,3]}}'
    Call_Codebase_Function __static__Is_Given_Key_Value_A_Valid_Scan "${value}"
    if [[ $? -ne 0 ]]; then
        Print_Error 'Scan syntax validation unexpectedly failed (' --emph "${value}" ').'
        return 1
    fi
}

function Make_Test_Preliminary_Operations__parameters-scan-single-validation()
{
    Make_Test_Preliminary_Operations__parameters-scan-format-lists
}

function __static__Test_Validation_Of_Parameter()
{
    local -r section=$1 key=$2 new_keys=$3 expect=$4
    if [[ "${expect}" = 'EXPECT_SUCCESS' ]]; then
        Call_Codebase_Function __static__Is_Parameter_To_Be_Scanned "${key}" "${new_keys}"
        if [[ $? -ne 0 ]]; then
            Print_Error 'Validation of ' --emph "${section}" ' parameter unexpectedly failed.'
            return 1
        fi
    else
        Call_Codebase_Function __static__Is_Parameter_To_Be_Scanned "${key}" "${new_keys}" &> /dev/null
        if [[ $? -eq 0 ]]; then
            Print_Error 'Validation of ' --emph "${section}" ' parameter unexpectedly succeeded.'
            return 1
        fi
    fi
}

function Unit_Test__parameters-scan-single-validation()
{
    HYBRID_software_new_input_keys=(
        [IC]=$'Modi:\n  Collider:\n    Sqrtsnn: {Scan: {Values: [4.3, 7.7]}}'
        [Hydro]='etaS: {Scan: {Values: [0.13, 0.15, 0.17]}}'
        [Sampler]='shear: 1.'
        [Afterburner]=''
    )
    __static__Test_Validation_Of_Parameter \
        'IC' 'Modi.Collider.Sqrtsnn' "${HYBRID_software_new_input_keys[IC]}" 'EXPECT_SUCCESS' || return 1
    __static__Test_Validation_Of_Parameter \
        'Hydro' 'etaS' "${HYBRID_software_new_input_keys[Hydro]}" 'EXPECT_SUCCESS' || return 1
    __static__Test_Validation_Of_Parameter \
        'Sampler' 'shear' "${HYBRID_software_new_input_keys[Sampler]}" 'EXPECT_FAILURE' || return 1
    __static__Test_Validation_Of_Parameter \
        'Afterburner ' 'General.Randomseed' \
        "${HYBRID_software_new_input_keys[Afterburner]}" 'EXPECT_FAILURE' || return 1
}

function Make_Test_Preliminary_Operations__parameters-scan-global-validation()
{
    Make_Test_Preliminary_Operations__parameters-scan-format-lists
}

function Unit_Test__parameters-scan-global-validation()
{
    HYBRID_scan_parameters[IC]='[Modi.Collider.Sqrtsnn]'
    HYBRID_scan_parameters[Hydro]='[etaS]'
    HYBRID_software_new_input_keys[IC]=$'Modi:\n  Collider:\n    Sqrtsnn: {Scan: {Values: [4.3, 7.7]}}'
    HYBRID_software_new_input_keys[Hydro]='etaS: {Scan: {Values: [0.13, 0.15, 0.17]}}'
    Call_Codebase_Function_In_Subshell Validate_Scan_Parameters
    if [[ $? -ne 0 ]]; then
        Print_Error 'Validation of scan parameters unexpectedly failed.'
        return 1
    fi
    HYBRID_scan_parameters=(
        [IC]=''
        [Hydro]=''
        [Sampler]='[shear]'
        [Afterburner]='[General.Randomseed]'
    )
    HYBRID_software_new_input_keys=(
        [IC]=''
        [Hydro]=''
        [Sampler]='shear: 1.'
        [Afterburner]=''
    )
    Call_Codebase_Function_In_Subshell Validate_Scan_Parameters #&> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of scan parameters unexpectedly succeeded.'
        return 1
    fi
}
