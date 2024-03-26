#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# ATTENTION: The code in this file might look here and there a bit "strange" and not
#            what one would write at first. However, this is due to the fact that
#            we want to check the availability of many system requirements without
#            using them, otherwise the output for those users missing features would
#            be more confusing than helpful. Please, keep this in mind if you are
#            going to modify this file and/or change requirements.

function __static__Declare_System_Requirements()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_top_level_path
    if ! declare -p HYBRID_version_regex &> /dev/null; then
        readonly HYBRID_version_regex='[0-9](.[0-9]+)*'
        readonly HYBRID_python_requirements_file="${HYBRID_top_level_path}/python/requirements.txt"
        readonly HYBRID_python_test_requirement_tool="${HYBRID_top_level_path}/python/test_requirement.py"
        declare -rgA HYBRID_versions_requirements=(
            [awk]='4.1'
            [bash]='4.4'
            [git]='1.8.5'
            [sed]='4.2.1'
            [tput]='5.7'
            [yq]='4.24.2'
            [python3]='3.0.0'
        )
        declare -rga HYBRID_programs_just_required=(
            cat
            column
            cut
            grep
            head
            realpath
            tail
        )
        declare -rga HYBRID_gnu_programs_required=(awk sed sort wc)
        declare -rga HYBRID_env_variables_required=(TERM)
        declare -gA HYBRID_python_requirements
        __static__Parse_Python_Requirements_Into_Global_Array
        readonly -A HYBRID_python_requirements
    fi
}

function Check_System_Requirements()
{
    __static__Declare_System_Requirements
    # NOTE: The following associative array will be used to store system information
    #       and since bash does not support arrays entries in associative arrays, then
    #       just strings with information will be used. Each entry of this array
    #       contains whether the command was found, its version and whether the version
    #       meets the requirement or not. A '|' is used to separate the fields in the
    #       string and '---' is used to indicate a negative outcome in the field.
    #       The same array is used to store the availability of programs that are just
    #       required, without any version requirement. For these, only the found field
    #       is stored (either 'found' or '---').
    #       The same array is used to store the availability of GNU tools. For these,
    #       the key is prefixed by 'GNU-' and the content has a first "field" that is
    #       'found' or '---' and a second one that is either 'OK' or '---' to indicate
    #       whether the GNU version of the command is in use or not.
    #       The same array is used for environment variables and, in this case,
    #       the content is either 'OK' or '---'.
    #       Finally, the same array is used for python requirements. The keys are the
    #       python requirements and the values have one field only which is either
    #       'OK' or '---' or '?' or 'wrong'.
    #
    # ATTENTION: The code relies on the "fields" in system_information elements not
    #            containing spaces. This assumption might be dropped, but that array
    #            is an implementation detail and we have full control on its content.
    declare -A system_information
    __static__Analyze_System_Properties
    __static__Exit_If_Some_GNU_Requirement_Is_Missing
    __static__Exit_If_Minimum_Versions_Are_Not_Available
    __static__Exit_If_Some_Needed_Environment_Variable_Is_Missing
    __static__Exit_If_Some_Needed_Python_Requirement_Is_Missing
}

function Check_System_Requirements_And_Make_Report()
{
    __static__Declare_System_Requirements
    local system_report=()
    local -r single_field_length=18 # This variable is used to prepare the report correctly formatted
    declare -A system_information   # Same use of this variable as in 'Check_System_Requirements' function
    __static__Analyze_System_Properties
    __static__Print_Report_Title
    __static__Print_Report_Of_Programs_With_Minimum_version
    __static__Prepare_Binary_Report_Array
    __static__Print_Formatted_Binary_Report
}

#===================================================================================================
# First level of Utility functions for functionality above

function __static__Parse_Python_Requirements_Into_Global_Array()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty HYBRID_python_requirements_file
    Ensure_That_Given_Variables_Are_Set HYBRID_python_requirements
    local line comment
    while read -r line; do
        line=${line%#*}               # Remove in-line comments
        line=${line##+([[:space:]])}  # Remove leading spaces
        line=${line%%+([[:space:]])}  # Remove trailing spaces
        if [[ ${line} =~ ^[[:space:]]*$ ]]; then
            continue
        fi
        case "${line}" in
            pyDOE* )
                comment='Required in "prepare-scan" mode with LHS enabled'
                ;;
            PyYAML* )
                comment='Required in "do" mode for afterburner with spectators'
                ;;
            * )
                comment='Always required'
        esac
        HYBRID_python_requirements["${line}"]="${comment}"
    done < "${HYBRID_python_requirements_file}"
}

function __static__Analyze_System_Properties()
{
    Ensure_That_Given_Variables_Are_Set system_information
    local program name return_code
    for program in "${!HYBRID_versions_requirements[@]}"; do
        if __static__Try_Find_Requirement "${program}"; then
            system_information[${program}]='found|'
        else
            system_information[${program}]='---|---|---'
            continue
        fi
        if ! __static__Try_Find_Version "${program}"; then # This writes to system_information
            continue
        fi
        if __static__Check_Version_Suffices "${program}"; then
            system_information[${program}]+='OK'
        else
            system_information[${program}]+='---'
        fi
    done
    for program in "${HYBRID_programs_just_required[@]}"; do
        if __static__Try_Find_Requirement "${program}"; then
            system_information["${program}"]='found'
        else
            system_information["${program}"]='---'
        fi
    done
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        if __static__Try_Find_Requirement "${program}"; then
            system_information["GNU-${program}"]='found|'
        else
            system_information["GNU-${program}"]='---|---'
            continue
        fi
        # Handling of function exit code must be done in this form because of errexit mode
        return_code=0
        __static__Is_Gnu_Version_In_Use "${program}" || return_code=$?
        case "${return_code}" in
            0)
                system_information["GNU-${program}"]+='OK'
                ;;
            2)
                system_information["GNU-${program}"]+='?'
                ;;
            *)
                system_information["GNU-${program}"]+='---'
                ;;
        esac
    done
    for name in "${HYBRID_env_variables_required[@]}"; do
        # Handling of function exit code must be done in this form because of errexit mode;
        # the subshell is needed because the function exits when the variable is unset or empty
        return_code=0
        (Ensure_That_Given_Variables_Are_Set_And_Not_Empty "${name}" &> /dev/null) || return_code=$?
        if [[ ${return_code} -eq 0 ]]; then
            system_information["${name}"]='OK'
        else
            system_information["${name}"]='---'
        fi
    done
    for program in "${!HYBRID_python_requirements[@]}"; do
        system_information["${program}"]="$(__static__Is_Python_Requirement_Satisfied "${program}")"
    done
    for program in "${!system_information[@]}"; do
        Print_Debug "${program} -> ${system_information[${program}]}"
    done
}

function __static__Exit_If_Some_GNU_Requirement_Is_Missing()
{
    local program errors=0 is_gnu
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[GNU-${program}]"
        is_gnu=$(__static__Get_Field_In_System_Information_String "GNU-${program}" 1)
        if [[ ${is_gnu} = '---' ]]; then
            Print_Error --emph "${program}" ' either not found or non-GNU version in use.' \
                'Please, ensure that ' --emph "${program}" ' is installed and in use.'
            ((errors++)) || true
        fi
    done
    if [[ ${errors} -ne 0 ]]; then
        Print_Fatal_And_Exit 'The GNU version of the above program(s) is needed.'
    fi
}

function __static__Exit_If_Minimum_Versions_Are_Not_Available()
{
    local program errors=0 min_version program_found version_found version_ok
    for program in "${!HYBRID_versions_requirements[@]}"; do
        Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[${program}]"
        min_version=${HYBRID_versions_requirements["${program}"]}
        program_found=$(__static__Get_Field_In_System_Information_String "${program}" 0)
        version_found=$(__static__Get_Field_In_System_Information_String "${program}" 1)
        version_ok=$(__static__Get_Field_In_System_Information_String "${program}" 2)
        if [[ "${program_found}" = '---' ]]; then
            Print_Error --emph "${program}" ' command not found! Minimum version ' \
                --emph "${min_version}" ' is required.'
            ((errors++)) || true
            continue
        fi
        if [[ ${version_found} = '---' ]]; then
            Print_Warning 'Unable to find version of ' --emph "${program}" ', skipping version check!' \
                'Please ensure that current version is at least ' --emph "${min_version}" '.'
            continue
        fi
        if [[ "${version_ok}" = '---' ]]; then
            Print_Error --emph "${program}" ' version ' --emph "${version_found}" \
                ' found, but version ' --emph "${min_version}" ' is required.'
            ((errors++)) || true
        fi
    done
    if [[ ${errors} -ne 0 ]]; then
        Print_Fatal_And_Exit 'Please install (maybe locally) the required versions of the above program(s).'
    fi
}

function __static__Exit_If_Some_Needed_Environment_Variable_Is_Missing()
{
    local name errors=0
    for name in "${HYBRID_env_variables_required[@]}"; do
        Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[${name}]"
        if [[ ${system_information[${name}]} = '---' ]]; then
            Print_Error --emph "${name}" ' environment variable either unset or empty.' \
                'Please, ensure that ' --emph "${name}" ' is properly set.'
            ((errors++)) || true
        fi
    done
    if [[ ${errors} -ne 0 ]]; then
        Print_Fatal_And_Exit 'Please, set the above environment variable(s) to appropriate value(s).'
    fi
}

function __static__Exit_If_Some_Needed_Python_Requirement_Is_Missing()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty \
        HYBRID_execution_mode HYBRID_scan_strategy HYBRID_optional_feature[Add_spectators_from_IC]
    local requirement errors=0 package_found version_found version_ok
    for requirement in "${!HYBRID_python_requirements[@]}"; do
        case "${requirement}" in
            pyDOE*)
                if [[ ${HYBRID_execution_mode} != 'prepare-scan' || ${HYBRID_scan_strategy} != 'LHS' ]]; then
                    continue
                fi
                ;;
            PyYAML*)
                if [[ ${HYBRID_execution_mode} != 'do' ]] \
                    || [[ ${HYBRID_optional_feature[Add_spectators_from_IC]} != 'TRUE' ]]; then
                    continue
                fi
                ;;
            *)
                ;;
        esac
        Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[${requirement}]"
        package_found=$(__static__Get_Field_In_System_Information_String "${requirement}" 0)
        version_found=$(__static__Get_Field_In_System_Information_String "${requirement}" 1)
        version_ok=$(__static__Get_Field_In_System_Information_String "${requirement}" 2)
        if [[ "${package_found}" = '?' ]]; then
            Print_Warning \
                'Unable to check python ' --emph "${program}" ' requirement!' \
                'Please ensure that it is satisfied.'
        elif [[ "${package_found}" = '---' ]]; then
            Print_Error \
                'Python requirement ' --emph "${requirement}" \
                ' not found, but needed in this run.'
            ((errors++)) || true
            continue
        fi
        if [[ ! ${version_found} =~ ${HYBRID_version_regex} ]]; then
            Print_Internal_And_Exit \
                'Unexpected version value ' --emph "${version_found}" ' found when checking for python '\
                --emph "${requirement}" ' requirement.'
        fi
        if [[ "${version_ok}" = '---' ]]; then
            Print_Error \
                'Python requirement ' --emph "${requirement}" \
                ' not met! Found version ' --emph "${version_found}" ' installed.'
            ((errors++)) || true
        fi
    done
    if [[ ${errors} -ne 0 ]]; then
        Print_Fatal_And_Exit 'Please install the above python requirement(s).'
    fi
}

function __static__Print_Report_Title()
{
    printf "\e[1m  System requirements overview:\e[0m\n\n"
}

function __static__Print_Report_Of_Programs_With_Minimum_version()
{
    local report_string program
    # NOTE: sort might not be available, hence put report in string and then optionally sort it
    report_string=''
    for program in "${!HYBRID_versions_requirements[@]}"; do
        report_string+=$(__static__Print_Requirement_Version_Report_Line "${program}")$'\n'
    done
    if hash sort &> /dev/null; then
        # The third column is that containing the program name; remember that the
        # 'here-string' adds a newline to the string when feeding it into the command
        sort -b -k3 <<< "${report_string%?}"
    else
        printf '%s' "${report_string}"
    fi
    printf '\n'
}

function __static__Prepare_Binary_Report_Array()
{
    Ensure_That_Given_Variables_Are_Set system_report
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty single_field_length
    for name in "${HYBRID_programs_just_required[@]}"; do
        system_report+=(
            "$(
                __static__Get_Single_Tick_Cross_Requirement_Report \
                    "PROG ${name}" \
                    "${system_information[${name}]}"
            )"
        )
    done
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        is_gnu=$(__static__Get_Field_In_System_Information_String "GNU-${program}" 1)
        system_report+=(
            "$(
                __static__Get_Single_Tick_Cross_Requirement_Report \
                    "GNU ${program}" \
                    "${is_gnu}"
            )"
        )
    done
    for name in "${HYBRID_env_variables_required[@]}"; do
        system_report+=(
            "$(
                __static__Get_Single_Tick_Cross_Requirement_Report \
                    "ENV ${name}" \
                    "${system_information[${name}]}"
            )"
        )
    done
}

function __static__Print_Formatted_Binary_Report()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty system_report
    # Because of coloured output, we cannot use a tool like 'column' here to format output
    # and we manually determine how many columns to use. Furthermore tput needs the TERM
    # environment variable to be set and, as tput is a requirement, we cannot rely on it
    # here. Although in some cases this might fail, we refresh and use COLUMNS variable
    # here (see https://stackoverflow.com/a/48016366/14967071 for more information).
    shopt -s checkwinsize # Do not assume it is on (as it usually is)
    (:)                   # Refresh LINES and COLUMNS, this happens when a child process exits
    local -r num_cols=$((${COLUMNS-100} / 2 / single_field_length))
    local index printf_descriptor
    printf_descriptor="%${single_field_length}s" # At least one column
    for ((index = 1; index < num_cols; index++)); do
        printf_descriptor+="  %${single_field_length}s"
    done
    printf "${printf_descriptor}\n" "${system_report[@]}"
}

#===================================================================================================
# Second level of Utility functions for functionality above

function __static__Try_Find_Requirement()
{
    if hash "$1" 2> /dev/null; then
        return 0
    else
        return 1
    fi
}

function __static__Try_Find_Version()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[$1]"
    if ! hash grep &> /dev/null && [[ $1 != 'bash' ]]; then
        system_information["$1"]+='?|---'
        return 1
    fi
    local found_version
    case "$1" in
        awk | git | sed | python3)
            found_version=$($1 --version)
            ;;& # Continue matching other cases
        awk | sed)
            found_version=$(__static__Get_First_Line_From_String "${found_version}")
            found_version=$(grep -oE "${HYBRID_version_regex}" <<< "${found_version}")
            found_version=$(__static__Get_First_Line_From_String "${found_version}")
            ;;
        bash)
            found_version="${BASH_VERSINFO[@]:0:3}"
            found_version="${found_version// /.}"
            ;;
        git | python3)
            found_version=$(grep -oE "${HYBRID_version_regex}" <<< "${found_version}")
            ;;
        tput)
            found_version=$(tput -V | grep -oE "${HYBRID_version_regex}")
            found_version=(${found_version//./ })                     # Use word split to separate version numbers
            found_version="${found_version[0]-}.${found_version[1]-}" # Use empty variables if 'tput -V' failed
            ;;
        yq)
            # Versions before v4.30.3 do not have the 'v' prefix
            found_version=$(yq --version \
                | grep -oE "version [v]?${HYBRID_version_regex}" \
                | grep -oE "${HYBRID_version_regex}")
            ;;
        *)
            Print_Internal_And_Exit 'Version finding for ' --emph "$1" ' to be added!'
            ;;
    esac
    if [[ ${found_version} =~ ^${HYBRID_version_regex}$ ]]; then
        system_information["$1"]+="${found_version}|"
    else
        system_information["$1"]+='---|---'
        return 1
    fi
}

function __static__Check_Version_Suffices()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[$1]"
    # Here we assume that the programs were found and their version, too
    local program version_required version_found newer_version
    program=$1
    version_required="${HYBRID_versions_requirements[${program}]}"
    version_found=$(__static__Get_Field_In_System_Information_String "${program}" 1)
    # If versions are equal, we're done
    if [[ "${version_required}" = "${version_found}" ]]; then
        return 0
    fi
    newer_version=$(__static__Get_Larger_Version ${version_required} ${version_found})
    if [[ ${newer_version} = ${version_required} ]]; then
        return 1
    else
        return 0
    fi
}

function __static__Is_Gnu_Version_In_Use()
{
    # This follows apparently common sense -> https://stackoverflow.com/a/61767587/14967071
    if ! hash grep &> /dev/null || ! "$1" --version &> /dev/null; then
        return 2
    elif [[ $("$1" --version | grep -c 'GNU') -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

function __static__Is_Python_Requirement_Satisfied()
{
    local requirement name version_specifier
    requirement=$1
    # According to PEP-440 this should be the symbols that separate the name from the version
    # specifiers -> see https://peps.python.org/pep-0440/#version-specifiers for more info.
    name="${requirement%%[~<>=\!]*}"
    name="${name%%*([[:space:]])}" # Trim possible trailing spaces
    version_specifier="${requirement//${name}/}"
    # Ignore exit code from the tool, as not needed here
    ${HYBRID_python_test_requirement_tool} "${name}" "${version_specifier}" || return 0
}

#===================================================================================================
# Third level of Utility functions for functionality above

function __static__Get_Larger_Version()
{
    local v1=$1 v2=$2 dots_of_v1 dots_of_v2
    if [[ ! "${v1}.${v2}" =~ ${HYBRID_version_regex} ]]; then
        Print_Internal_And_Exit 'Wrong arguments passed to ' --emph "${FUNCNAME}" '.'
    fi
    # Ensure versions are of the same length to make following algorithm work
    dots_of_v1=${v1//[^.]/}
    dots_of_v2=${v2//[^.]/}
    if [[ ${#dots_of_v1} -lt ${#dots_of_v2} ]]; then
        declare -n \
            shorter_version=v1 dots_of_shorter_version=dots_of_v1 dots_of_longer_version=dots_of_v2
    else
        declare -n \
            shorter_version=v2 dots_of_shorter_version=dots_of_v2 dots_of_longer_version=dots_of_v1
    fi
    while [[ ${#dots_of_shorter_version} -ne ${#dots_of_longer_version} ]]; do
        shorter_version+='.0'        # Add zeroes to shorter string
        dots_of_shorter_version+='.' # Add dot to keep counting accurate
    done
    # If versions are equal, we're done
    if [[ "${v2}" = "${v1}" ]]; then
        printf "${v1}"
        return
    fi
    # Split version strings into array of numbers replacing '.' by ' ' and let word splitting do the split
    local v{1,2}_array index
    v1_array=(${v1//./ })
    v2_array=(${v2//./ })
    # Now version arrays have same number of entries, compare them
    for index in ${!v1_array[@]}; do
        if [[ "${v1_array[index]}" -eq "${v2_array[index]}" ]]; then
            continue
        elif [[ "${v1_array[index]}" -lt "${v2_array[index]}" ]]; then
            printf "$2" # Print input version, unchanged
            return
        else
            printf "$1" # Print input version, unchanged
            return
        fi
    done
}

function __static__Print_Requirement_Version_Report_Line()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[$1]"
    local -r \
        emph_color='\e[96m' \
        red='\e[91m' \
        green='\e[92m' \
        yellow='\e[93m' \
        text_color='\e[38;5;38m' \
        default='\e[0m'
    local line found version_found version_ok tmp_array program=$1
    tmp_array=(${system_information[${program}]//|/ }) # Unquoted to let word splitting act
    found=${tmp_array[0]}
    version_found=${tmp_array[1]}
    version_ok=${tmp_array[2]}
    printf -v line "   ${text_color}Command ${emph_color}%8s${text_color}: ${default}" "${program}"
    if [[ ${found} = '---' ]]; then
        line+="${red}NOT "
    else
        line+="${green}    "
    fi
    line+=$(printf "found  ${text_color}Required version: ${emph_color}%6s${default}" \
        "${HYBRID_versions_requirements[${program}]}")
    if [[ ${found} != '---' ]]; then
        line+="  ${text_color}System version:${default} "
        if [[ ${version_found} =~ ^(---|\?)$ ]]; then
            line+="${yellow}Unable to recover"
        else
            if [[ ${version_ok} = '---' ]]; then
                line+="${red}"
            else
                line+="${green}"
            fi
            line+="${version_found}"
        fi
        line+="${default}"
    fi
    printf "${line}\n"
}

function __static__Get_Single_Tick_Cross_Requirement_Report()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty single_field_length
    local -r \
        emph_color='\e[96m' \
        red='\e[91m' \
        green='\e[92m' \
        yellow='\e[93m' \
        text_color='\e[38;5;38m' \
        default='\e[0m'
    local line name="$1" status=$2 name_string
    printf -v name_string "%s ${emph_color}%s" "${name% *}" "${name#* }"
    printf -v line " %*s${text_color}: ${default}" "${single_field_length}" "${name_string}"
    if [[ ${status} = '---' ]]; then
        line+="${red}✘"
    elif [[ ${status} = '?' ]]; then
        line+="${yellow}\e[1m?"
    else
        line+="${green}✔︎"
    fi
    printf "${line}${default}"
}

function __static__Get_Field_In_System_Information_String()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[$1]"
    local tmp_array=(${system_information[$1]//|/ }) # Unquoted to let word splitting act
    printf '%s' "${tmp_array[$2]}"
}

# This is basically a partial bash implementation of head, which we want to
# avoid using in this file as it is a requirement that we want to check
function __static__Get_First_Line_From_String()
{
    while IFS= read -r line; do
        printf "${line}"
        return
    done < <(printf '%s\n' "$1")
    # The \n in printf is important to avoid skipping the last line (which might be the only input)
}

Make_Functions_Defined_In_This_File_Readonly
