#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__configuration-validate-existence()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'configuration_parser.bash'
        'global_variables.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    Define_Further_Global_Variables
}

function Unit_Test__configuration-validate-existence()
{
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation not existing file succeeded.'
        return 1
    fi
}

#-------------------------------------------------------------------------------

function Make_Test_Preliminary_Operations__configuration-validate-YAML()
{
    Make_Test_Preliminary_Operations__configuration-validate-existence
}

function Unit_Test__configuration-validate-YAML()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    printf 'Scalar\nKey: Value\n' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of invalid YAML in configuration file succeeded.'
        return 1
    fi
    rm "${HYBRID_configuration_file}"
}

#-------------------------------------------------------------------------------

function Make_Test_Preliminary_Operations__configuration-validate-section-labels()
{
    Make_Test_Preliminary_Operations__configuration-validate-existence
}

function Unit_Test__configuration-validate-section-labels()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    printf 'Invalid: Value\n' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of configuration file with invalid section succeeded.'
        return 1
    fi
    printf 'Afterburner: Values\nIC: Values\nHydro: Values\n' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of configuration file with sections in wrong order succeeded.'
        return 1
    fi
    printf 'IC: Values\nSampler: Values\nIC: Again\n' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of configuration file with repeated section succeeded.'
        return 1
    fi
    printf 'IC: Values\nSampler: Values\n' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of configuration file with missing sections succeeded.'
        return 1
    fi
    printf 'Hybrid_handler: Values\n' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of configuration file with no software section succeeded.'
        return 1
    fi
    rm "${HYBRID_configuration_file}"
}

#-------------------------------------------------------------------------------

function Make_Test_Preliminary_Operations__configuration-validate-all-keys()
{
    Make_Test_Preliminary_Operations__configuration-validate-existence
}

function Unit_Test__configuration-validate-all-keys()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    printf '
    Hybrid_handler:
      Try: 1
    IC:
      Fake: Values
      Invalid: 42
    Hydro:
      Foo: Bar
      Bar: Foo
    Sampler:
      Key: Value
      Invalid: 17
    Afterburner:
      Nope: 13
      Maybe: False
    ' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of configuration file with only invalid keys succeeded.'
        return 1
    fi
    printf '
    Hybrid_handler: {}
    IC:
      Executable: /path/to/exec
      Invalid: 42
    ' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File &> /dev/null
    if [[ $? -eq 0 ]]; then
        Print_Error 'Validation of configuration file with invalid keys succeeded.'
        return 1
    fi
    printf '
    Hybrid_handler: {}
    IC:
      Executable: /path/to/exec
    Hydro:
      Input_file: /path/to/file
    ' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File
    if [[ $? -ne 0 ]]; then
        Print_Error 'Validation of configuration file failed.'
        return 1
    fi
    rm "${HYBRID_configuration_file}"
}

#-------------------------------------------------------------------------------

function Make_Test_Preliminary_Operations__configuration-parse-general-section()
{
    Make_Test_Preliminary_Operations__configuration-validate-existence
}

function Unit_Test__configuration-parse-general-section()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    printf 'Hybrid_handler: {}\nIC:\n  Executable: foo\n' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell Validate_And_Parse_Configuration_File
    if [[ $? -ne 0 ]]; then
        Print_Error 'Parsing of general section failed.'
        return 1
    fi
    rm "${HYBRID_configuration_file}"
}

#-------------------------------------------------------------------------------

function __static__Test_Section_Parsing_In_Subshell()
(
    local section executable input_file new_keys
    section=$1
    executable=$2
    config_file=$3
    input_file=$4
    new_keys=$5
    Call_Codebase_Function Validate_And_Parse_Configuration_File
    if [[ "${#HYBRID_given_software_sections[@]}" -ne 1 ]] ||\
       [[ "${HYBRID_given_software_sections[0]}" != "${section}" ]]; then
        Print_Fatal_And_Exit 'Parsing of ' --emph "${section}" ' section failed (section storing).'
    fi
    if [[ ${HYBRID_software_executable[${section}]} != "${executable}" ]]; then
        Print_Fatal_And_Exit 'Parsing of ' --emph "${section}" ' section failed (software executable).'
    fi
    if [[ ${HYBRID_software_base_config_file[${section}]} != "${config_file}" ]]; then
        Print_Fatal_And_Exit 'Parsing of ' --emph "${section}" ' section failed (config file).'
    fi
    if [[ ${section} != 'IC' ]] && [[ ${section} != 'Sampler' ]]; then
        if [[ ${HYBRID_software_default_input_file[${section}]} != "${input_file}" ]]; then
            Print_Fatal_And_Exit 'Parsing of ' --emph "${section}" ' section failed (input file).'
        fi
    fi
    if [[ ${HYBRID_software_new_input_keys[${section}]} != "${new_keys}" ]]; then
        Print_Fatal_And_Exit 'Parsing of ' --emph "${section}" ' section failed (software keys).'
    fi
)

function Make_Test_Preliminary_Operations__configuration-parse-IC-section()
{
    Make_Test_Preliminary_Operations__configuration-validate-existence
}

function Unit_Test__configuration-parse-IC-section()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    printf '
    IC:
      Executable: foo
      Config_file: bar
      Software_keys:
        General:
          Randomseed: 12345
    ' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell __static__Test_Section_Parsing_In_Subshell\
        'IC' 'foo' 'bar' '' $'General:\n  Randomseed: 12345'
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    rm "${HYBRID_configuration_file}"
}

#-------------------------------------------------------------------------------

function Make_Test_Preliminary_Operations__configuration-parse-Hydro-section()
{
    Make_Test_Preliminary_Operations__configuration-validate-existence
}

function Unit_Test__configuration-parse-Hydro-section()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    printf '
    Hydro:
      Executable: foo
      Config_file: bar
      Input_file: ket
      Software_keys:
        etaS: 0.12345
    ' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell __static__Test_Section_Parsing_In_Subshell\
        'Hydro' 'foo' 'bar' 'ket' 'etaS: 0.12345'
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    rm "${HYBRID_configuration_file}"
}

#-------------------------------------------------------------------------------

function Make_Test_Preliminary_Operations__configuration-parse-Sampler-section()
{
    Make_Test_Preliminary_Operations__configuration-validate-existence
}

function Unit_Test__configuration-parse-Sampler-section()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    printf '
    Sampler:
      Executable: foo
      Config_file: bar
      Software_keys:
        shear: 1.2345
    ' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell __static__Test_Section_Parsing_In_Subshell\
        'Sampler' 'foo' 'bar' '' 'shear: 1.2345'
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    rm "${HYBRID_configuration_file}"
}

#-------------------------------------------------------------------------------

function Make_Test_Preliminary_Operations__configuration-parse-Afterburner-section()
{
    Make_Test_Preliminary_Operations__configuration-validate-existence
}

function Unit_Test__configuration-parse-Afterburner-section()
{
    HYBRID_configuration_file=${HYBRIDT_folder_to_run_tests}/${FUNCNAME}.yaml
    printf '
    Afterburner:
      Executable: foo
      Config_file: bar
      Input_file: ket
      Software_keys:
        General:
          End_Time: 42000
    ' > "${HYBRID_configuration_file}"
    Call_Codebase_Function_In_Subshell __static__Test_Section_Parsing_In_Subshell\
        'Afterburner' 'foo' 'bar' 'ket' $'General:\n  End_Time: 42000'
    if [[ $? -ne 0 ]]; then
        return 1
    fi
    rm "${HYBRID_configuration_file}"
}
