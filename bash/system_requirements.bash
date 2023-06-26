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
            [bash]='4.4'
            [awk]='4.1'
            [sed]='4.2.1'
            [tput]='5.7'
            [yq]='4.18.1'
        )
        declare -rga HYBRID_gnu_programs_required=( awk sed sort wc )
        declare -rga HYBRID_env_variables_required=( TERM )
    fi
}

function Check_System_Requirements()
{
    __static__Declare_System_Requirements
    local program requirements_present min_version version_found name
    requirements_present=0
    # NOTE: The following associative array will be used to store system information
    #       and since bash does not support arrays entries in associative arrays, then
    #       just strings with information will be used. Each entry of this array
    #       contains whether the command was found, its version and whether the version
    #       meets the requirement or not. A '|' is used to separate the fields in the
    #       string and '---' is used to indicate a negative outcome in the field.
    #       The same array is used to store the availability of GNU tools. For these,
    #       the key is prefixed by 'GNU-' and the content has a first "field" that is
    #       'found' or '---' and a second one that is either 'OK' or '---' to indicate
    #       whether the GNU version of the command is in use or not.
    #       Finally, the same array is used for environment variables and, in this case,
    #       the content is either 'OK' or '---'.
    declare -A system_information
    __static__Analyze_System_Properties
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        if [[ $(cut -d'|' -f2 <<< "${system_information[GNU-${program}]}") = '---' ]]; then
            Print_Error --emph "${program}" ' either not found or non-GNU version in use.'\
                        'Please, ensure that ' --emph "${program}" ' is installed and in use.'
            requirements_present=1
        fi
    done
    if [[ ${requirements_present} -ne 0 ]]; then
        Print_Fatal_And_Exit 'The GNU version of the above programs is needed.'
    fi
    for program in "${!HYBRID_versions_requirements[@]}"; do
        min_version=${HYBRID_versions_requirements["${program}"]}
        if [[ $(cut -d'|' -f1 <<< "${system_information[${program}]}") = '---' ]]; then
            Print_Error --emph "${program}" ' command not found! Minimum version '\
                        --emph "${min_version}" ' is required.'
            requirements_present=1
            continue
        fi
        version_found=$(cut -d'|' -f2 <<< "${system_information[${program}]}")
        if [[ ${version_found} = '---' ]]; then
            Print_Warning 'Unable to find version of ' --emph "${program}" ', skipping version check!'\
                          'Please ensure that current version is at least ' --emph "${min_version}" '.'
            continue
        fi
        if [[ $(cut -d'|' -f3 <<< "${system_information[${program}]}") = '---' ]]; then
            Print_Error --emph "${program}" ' version ' --emph "${version_found}"\
                        ' found, but version ' --emph "${min_version}" ' is required.'
            requirements_present=1
        fi
    done
    if [[ ${requirements_present} -ne 0 ]]; then
        Print_Fatal_And_Exit 'Please install (maybe locally) the required versions of the above programs.'
    fi
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
    local program name gnu_env_report=()
    declare -A system_information
    __static__Analyze_System_Properties
    printf "\e[1m  System requirements overview:\e[0m\n\n"
    for program in "${!HYBRID_versions_requirements[@]}"; do
        __static__Print_Requirement_Version_Report_Line "${program}"
    done | sort -b -k3 # the third column is that containing the program name
    printf '\n'
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        gnu_env_report+=(
            "$(__static__Get_Single_Tick_Cross_Requirement_Report\
                "GNU ${program}"\
                "$(cut -d'|' -f2 <<< "${system_information["GNU-${program}"]}")"
            )"
        )
    done
    for name in "${HYBRID_env_variables_required[@]}"; do
        gnu_env_report+=(
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
    cat /dev/null # Refresh LINES and COLUMNS
    local -r num_cols=$(( COLUMNS / 2 / single_field_length ))
    local index printf_descriptor
    printf_descriptor="%${single_field_length}s" # At least one column
    for ((index=1; index<num_cols; index++)); do
        printf_descriptor+="  %${single_field_length}s"
    done
    printf "${printf_descriptor}\n" "${gnu_env_report[@]}"
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
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        if __static__Try_Find_Requirement "${program}"; then
            system_information["GNU-${program}"]='found|'
        else
            system_information["GNU-${program}"]='---|---'
            continue
        fi
        if __static__Is_Gnu_Version_In_Use "${program}"; then
            system_information["GNU-${program}"]+='OK'
        else
            system_information["GNU-${program}"]+='---'
        fi
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
    if [[ $("$1" --version | grep -c 'GNU') -gt 0 ]]; then
        return 0
    else
        return 1
    fi
}

function __static__Try_Find_Version()
{
    Ensure_That_Given_Variables_Are_Set system_information
    local found_version
    case "$1" in
        bash )
            found_version="${BASH_VERSINFO[@]:0:3}"
            found_version="${found_version// /.}"
            ;;
        awk )
            found_version=$(awk --version | head -n1 | grep -oE "${HYBRID_version_regex}" | head -n1)
            ;;
        sed )
            found_version=$(sed --version | head -n1 | grep -oE "${HYBRID_version_regex}" | head -n1)
            ;;
        tput )
            found_version=$(tput -V | grep -oE "${HYBRID_version_regex}" | cut -d'.' -f1,2)
            ;;
        yq )
            # Versions before v4.30.3 do not have the 'v' prefix
            found_version=$(yq --version |\
                            grep -oE "version [v]?${HYBRID_version_regex}" |\
                            grep -oE "${HYBRID_version_regex}")
            ;;
        *)
            return 1
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
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty system_information
    # Here we assume that the programs were found and their version, too
    local program version_required version_found newer_version
    program=$1
    version_required="${HYBRID_versions_requirements[${program}]}"
    version_found=$(cut -d'|' -f2 <<< "${system_information[${program}]}")
    # If versions are equal, we're done
    if [[ "${version_required}" = "${version_found}" ]]; then
        return 0
    fi
    newer_version=$(printf '%s\n%s' ${version_required} ${version_found} | sort -V | tail -n 1)
    if [[ ${newer_version} = ${version_required} ]]; then
        return 1
    else
        return 0
    fi
}

function __static__Print_Requirement_Version_Report_Line()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty system_information
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
        if [[ ${version_found} = '---' ]]; then
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
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty system_information
    local -r emph_color='\e[96m'\
             red='\e[91m'\
             green='\e[92m'\
             text_color='\e[38;5;38m'\
             default='\e[0m'
    local line name="$1" status=$2
    printf -v line "   ${emph_color}%6s${text_color}: ${default}" "${name}"
    if [[ ${status} = '---' ]]; then
        line+="${red}✘"
    else
        line+="${green}✔︎"
    fi
    printf "${line}${default}"
}
