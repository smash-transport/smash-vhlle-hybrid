#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================


function __static__Declare_System_Requirements()
{
    if ! declare -p HYBRID_versions_requirements &> /dev/null; then
        readonly HYBRID_version_regex='[0-9](.[0-9]+)*'
        declare -rgA HYBRID_versions_requirements=(
            [awk]='4.1'
            [bash]='4.4'
            [sed]='4.2.1'
            [tput]='5.7'
            [yq]='4.18.1'
        )
        declare -rga HYBRID_programs_just_required=(
            cat
            column
            cut
            grep
            head
            tail
        )
        declare -rga HYBRID_gnu_programs_required=( awk sed sort wc )
        declare -rga HYBRID_env_variables_required=( TERM )
    fi
}

function Check_System_Requirements()
{
    __static__Declare_System_Requirements
    local program requirements_present
    requirements_present=0
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
    #       Finally, the same array is used for environment variables and, in this case,
    #       the content is either 'OK' or '---'.
    #
    # ATTENTION: The code relies on the "fields" in system_information elements not
    #            containing spaces. This assumption might be dropped, but that array
    #            is an implementation detail and we have full control on its content.
    declare -A system_information
    __static__Analyze_System_Properties
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        local is_gnu=$(__static__Get_Field_In_System_Information_String "GNU-${program}" 1)
        if [[ ${is_gnu} = '---' ]]; then
            Print_Error --emph "${program}" ' either not found or non-GNU version in use.'\
                        'Please, ensure that ' --emph "${program}" ' is installed and in use.'
            requirements_present=1
        fi
    done
    if [[ ${requirements_present} -ne 0 ]]; then
        Print_Fatal_And_Exit 'The GNU version of the above programs is needed.'
    fi
    for program in "${!HYBRID_versions_requirements[@]}"; do
        local  min_version  program_found version_found version_ok
        min_version=${HYBRID_versions_requirements["${program}"]}
        program_found=$(__static__Get_Field_In_System_Information_String "${program}" 0)
        version_found=$(__static__Get_Field_In_System_Information_String "${program}" 1)
        version_ok=$(   __static__Get_Field_In_System_Information_String "${program}" 2)
        if [[ "${program_found}" = '---' ]]; then
            Print_Error --emph "${program}" ' command not found! Minimum version '\
                        --emph "${min_version}" ' is required.'
            requirements_present=1
            continue
        fi
        if [[ ${version_found} = '---' ]]; then
            Print_Warning 'Unable to find version of ' --emph "${program}" ', skipping version check!'\
                          'Please ensure that current version is at least ' --emph "${min_version}" '.'
            continue
        fi
        if [[ "${version_ok}" = '---' ]]; then
            Print_Error --emph "${program}" ' version ' --emph "${version_found}"\
                        ' found, but version ' --emph "${min_version}" ' is required.'
            requirements_present=1
        fi
    done
    if [[ ${requirements_present} -ne 0 ]]; then
        Print_Fatal_And_Exit 'Please install (maybe locally) the required versions of the above programs.'
    fi
    local name
    for name in "${HYBRID_env_variables_required[@]}"; do
        if [[ ${system_information[${name}]} = '---' ]]; then
            Print_Error --emph "${name}" ' environment variable either unset or empty.'\
                        'Please, ensure that ' --emph "${name}" ' is properly set.'
            requirements_present=1
        fi
    done
    if [[ ${requirements_present} -ne 0 ]]; then
        Print_Fatal_And_Exit 'Some needed environment variables are not correctly set.'
    fi
}

function Check_System_Requirements_And_Make_Report()
{
    __static__Declare_System_Requirements
    local program report_string name is_gnu system_report=()
    declare -A system_information
    __static__Analyze_System_Properties
    printf "\e[1m  System requirements overview:\e[0m\n\n"
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
    # This variable is used to prepare the report correctly formatted
    local -r single_field_length=15
    for name in "${HYBRID_programs_just_required[@]}"; do
        system_report+=(
            "$(__static__Get_Single_Tick_Cross_Requirement_Report\
                "PROG ${name}"\
                "${system_information[${name}]}"
            )"
        )
    done
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        is_gnu=$(__static__Get_Field_In_System_Information_String "GNU-${program}" 1)
        system_report+=(
            "$(__static__Get_Single_Tick_Cross_Requirement_Report\
                "GNU ${program}"\
                "${is_gnu}"
            )"
        )
    done
    for name in "${HYBRID_env_variables_required[@]}"; do
        system_report+=(
            "$(__static__Get_Single_Tick_Cross_Requirement_Report\
                "ENV ${name}"\
                "${system_information[${name}]}"
            )"
        )
    done
    # Because of coloured output, we cannot use a tool like 'column' here to format output
    # and we manually determine how many columns to use. Furthermore tput needs the TERM
    # environment variable to be set and, as tput is a requirement, we cannot rely on it
    # here. Although in some cases this might fail, we refresh and use COLUMNS variable
    # here (see https://stackoverflow.com/a/48016366/14967071 for more information).
    shopt -s checkwinsize # Do not assume it is on (as it usually is)
    ( : )  # Refresh LINES and COLUMNS, this happens when a child process exits
    local -r num_cols=$(( COLUMNS / 2 / single_field_length ))
    local index printf_descriptor
    printf_descriptor="%${single_field_length}s" # At least one column
    for ((index=1; index<num_cols; index++)); do
        printf_descriptor+="  %${single_field_length}s"
    done
    printf "${printf_descriptor}\n" "${system_report[@]}"
}

function __static__Analyze_System_Properties()
{
    Ensure_That_Given_Variables_Are_Set system_information
    local program name
    for program in "${!HYBRID_versions_requirements[@]}"; do
        min_version=${HYBRID_versions_requirements["${program}"]}
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
        # Needed handling of command exit code to be done in this form because of errexit mode
        local return_code=0
        __static__Is_Gnu_Version_In_Use "${program}" || return_code=$?
        case "${return_code}" in
            0)
                system_information["GNU-${program}"]+='OK' ;;
            2)
                system_information["GNU-${program}"]+='?' ;;
            *)
                system_information["GNU-${program}"]+='---' ;;
        esac
    done
    for name in "${HYBRID_env_variables_required[@]}"; do
        ( Ensure_That_Given_Variables_Are_Set_And_Not_Empty "${name}" &> /dev/null )
        if [[ $? -eq 0 ]]; then
            system_information["${name}"]='OK'
        else
            system_information["${name}"]='---'
        fi
    done
}

function __static__Try_Find_Requirement()
{
    if hash "$1" 2>/dev/null; then
        return 0
    else
        return 1
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

function __static__Try_Find_Version()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[$1]"
    if ! hash grep &> /dev/null; then
        system_information["$1"]+='?|---'
        return 1
    fi
    local found_version
    case "$1" in
        awk | sed )
            found_version=$($1 --version)
            found_version=$(__static__Get_First_Line_From_String "${found_version}")
            found_version=$(grep -oE "${HYBRID_version_regex}" <<< "${found_version}")
            found_version=$(__static__Get_First_Line_From_String "${found_version}")
            ;;
        bash )
            found_version="${BASH_VERSINFO[@]:0:3}"
            found_version="${found_version// /.}"
            ;;
        tput )
            found_version=$(tput -V | grep -oE "${HYBRID_version_regex}")
            found_version=( ${found_version//./ } ) # Use word split to separate version numbers
            found_version="${found_version[0]}.${found_version[1]}"
            ;;
        yq )
            # Versions before v4.30.3 do not have the 'v' prefix
            found_version=$(yq --version |\
                            grep -oE "version [v]?${HYBRID_version_regex}" |\
                            grep -oE "${HYBRID_version_regex}")
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

function __static__Print_Requirement_Version_Report_Line()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty "system_information[$1]"
    local -r emph_color='\e[96m'\
             red='\e[91m'\
             green='\e[92m'\
             yellow='\e[93m'\
             text_color='\e[38;5;38m'\
             default='\e[0m'
    local line found version_found version_ok tmp_array program=$1
    tmp_array=( ${system_information[${program}]//|/ } ) # Unquoted to let word splitting act
    found=${tmp_array[0]}
    version_found=${tmp_array[1]}
    version_ok=${tmp_array[2]}
    printf -v line "   ${text_color}Command ${emph_color}%6s${text_color}: ${default}" "${program}"
    if [[ ${found} = '---' ]]; then
        line+="${red}NOT "
    else
        line+="${green}    "
    fi
    line+=$(printf "found  ${text_color}Required version: ${emph_color}%6s${default}"\
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
    local -r emph_color='\e[96m'\
             red='\e[91m'\
             green='\e[92m'\
             yellow='\e[93m'\
             text_color='\e[38;5;38m'\
             default='\e[0m'
    local line name="$1" status=$2 name_string
    printf -v name_string "%s ${emph_color}%s" "${name% *}" "${name#* }"
    printf -v line "   %*s${text_color}: ${default}" "${single_field_length}" "${name_string}"
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
    local tmp_array=( ${system_information[$1]//|/ } ) # Unquoted to let word splitting act
    printf '%s' "${tmp_array[$2]}"
}

# This is basically a partial bash implementation of head, which we want avoid
# using in this file as it is a requirement that we want to check
function __static__Get_First_Line_From_String()
{
    while IFS= read -r line; do
        printf "${line}"
        return
    done < <(printf '%s\n' "$1")
    # The \n in printf is important to avoid skipping the last line (which might be the only input)
}

function __static__Get_Larger_Version()
{
    local v1=$1 v2=$2
    if [[ ! "${v1}.${v2}" =~ ${HYBRID_version_regex} ]]; then
        Print_Internal_And_Exit 'Wrong arguments passed to ' --emph "${FUNCNAME}" '.'
    fi
    # Ensure versions are of the same length to make following algorithm work
    if [[ ${#v1} -lt ${#v2} ]]; then
        declare -n shorter_array=v1
        declare -n longer_array=v2
    else
        declare -n shorter_array=v2
        declare -n longer_array=v1
    fi
    while [[ ${#v1[@]} -ne ${#v2[@]} ]]; do
        shorter_array+='.0' # Add zeroes to shorter string
    done
     # If versions are equal, we're done
     if [[ "${v2}" = "${v1}" ]]; then
         printf "${v1}"
     fi
    # Split version strings into array of numbers replacing '.' by ' ' and let word splitting do the split
    local v{1,2}_array index
    v1_array=( ${v1//./ } )
    v2_array=( ${v2//./ } )
    # Now version arrays have same number of entries, compare them
    for index in ${!v1_array[@]}; do
        if [[ "${v1_array[index]}" -eq "${v2_array[index]}" ]]; then
            continue
        elif [[ "${v1_array[index]}" -lt "${v2_array[index]}" ]]; then
            printf "$2"  # Print input version, unchanged
            return
        else
            printf "$1"  # Print input version, unchanged
            return
        fi
    done
}


Make_Functions_Defined_In_This_File_Readonly
