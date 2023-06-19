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
            [yq]='4'
        )
        declare -rga HYBRID_gnu_programs_required=( awk sed sort wc )
    fi
}

function Check_System_Requirements()
{
    __static__Declare_System_Requirements
    local program requirements_present min_version
    requirements_present=0
    # NOTE: The following associative array will be used to store system information
    #       and since bash does not support arrays entries in associative arrays, then
    #       just strings with information will be used. Each entry of this array
    #       contains whether the command was found, its version and whether the version
    #       meets the requirement or not. A '|' is used to separate the fields in the
    #       string and '---' is used to indicate a negative outcome in the field.
    #       It has been decided to use the same array to store the availability of GNU
    #       tools. For these, the key is prefixed by 'GNU-' and the content has a first
    #       "field" that is 'found' or '---' and a second one that is either 'OK' or '---'
    #       to indicate whether the GNU version of the command is in use or not.
    declare -A system_information
    __static__Analyze_System_Properties
    for program in "${!HYBRID_versions_requirements[@]}"; do
        min_version=${HYBRID_versions_requirements["${program}"]}
        if [[ $(cut -d'|' -f1 <<< "${system_information[${program}]}") = '---' ]]; then
            Print_Error "'${program}' command not found! Minimum version ${min_version} is required."
            requirements_present=1
            continue
        fi
        if [[ $(cut -d'|' -f2 <<< "${system_information[${program}]}") = '---' ]]; then
            Print_Warning "Unable to find version of '${program}', skipping version check!"\
                "Please ensure that current version is at least ${min_version}."
            continue
        fi
        if [[ $(cut -d'|' -f3 <<< "${system_information[${program}]}") = '---' ]]; then
            Print_Error "'${program}' version ${system_information[${program}]} found,"\
                " but version ${min_version} is required."
            requirements_present=1
        fi
    done
    if [[ ${requirements_present} -ne 0 ]]; then
        Print_Fatal_And_Exit 'Please install (maybe locally) the required versions of the above programs.'
    fi
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        if [[ $(cut -d'|' -f2 <<< "${system_information[${program}]}") = '---' ]]; then
            Print_Error "'${program#GNU-}' either not found or non-GNU version in use."\
                        "Please, ensure that '${program}' is installed and in use."
            requirements_present=1
        fi
    done
    if [[ ${requirements_present} -ne 0 ]]; then
        Print_Fatal_And_Exit 'The GNU version of the above programs is needed.'
    fi
}

function Check_System_Requirements_And_Make_Report()
{
    __static__Declare_System_Requirements
    local program gnu_report=()
    declare -A system_information
    __static__Analyze_System_Properties
    printf "\n \e[93mSystem requirements overview:${default}\n\n"
    for program in "${!HYBRID_versions_requirements[@]}"; do
        __static__Print_Requirement_Version_Report_Line "${program}"
    done
    printf '\n'
    for program in "${HYBRID_gnu_programs_required[@]}"; do
        gnu_report+=( "$(__static__Get_Gnu_Requirement_Report_For_Single_Program "${program}")" )
    done
    # Because of coloured output, we cannot use a tool like 'column' here and
    # we manually determine how many columns to use.
    local -r single_field_length=15
    local -r num_cols=$(( $(tput cols) * 4 / 5 / single_field_length ))
    local index printf_descriptor
    printf_descriptor="%${single_field_length}s" # At least one column
    for ((index=1; index<num_cols; index++)); do
        printf_descriptor+="  %${single_field_length}s"
    done
    printf "${printf_descriptor}\n" "${gnu_report[@]}"
}

function __static__Analyze_System_Properties()
{
    Ensure_That_Given_Variables_Are_Set system_information
    local program
    for program in "${!HYBRID_versions_requirements[@]}"; do
        min_version=${HYBRID_versions_requirements["${program}"]}
        if __static__Try_Find_Requirement "${program}"; then
            system_information[${program}]='found|'
        else
            system_information[${program}]='---||' # Empty following fields
            continue
        fi
        if ! __static__Try_Find_Version "${program}"; then
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
            # Old versions close to 4.0.0 do not have the 'v' prefix
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
        system_information["$1"]+='---|'
        return 1
    fi
}

# NOTE: This function would be almost a one-liner using 'sort -V', but at the moment we do not
#       impose to have GNU coreutils installed, which we should probably do next...
function __static__Check_Version_Suffices()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty system_information
    # Here we assume that the programs were found and their version, too
    local program version_required version_found index
    program=$1
    version_required="${HYBRID_versions_requirements[${program}]}"
    version_found=$(cut -d'|' -f2 <<< "${system_information[${program}]}")
    if [[ ! ${version_found}    =~ ^${HYBRID_version_regex}$ ]] ||\
       [[ ! ${version_required} =~ ^${HYBRID_version_regex}$ ]]; then
        Print_Internal_And_Exit "Wrong syntax in version strings in ${FUNCNAME}."
    fi
    # Ensure versions are of the same length to make following algorithm work
    if [[ ${#version_found} -ne ${#version_required} ]]; then
        if [[ ${#version_found} -lt ${#version_required} ]]; then
            declare -n shorter_array=version_found
            declare -n longer_array=version_required
        else
            declare -n shorter_array=version_required
            declare -n longer_array=version_found
        fi
        while [[ ${#version_found[@]} -ne ${#version_required[@]} ]]; do
            shorter_array+='.0' # Add zeroes to shorter string
        done
    fi
    # If versions are equal, we're done
    if [[ "${version_required}" = "${version_found}" ]]; then
        return 0
    fi
    # Split version strings into array of numbers replacing '.' by ' ' and let word splitting do the split
    version_required=( ${version_required//./ } )
    version_found=( ${version_found//./ } )
    # Now version arrays have same number of entries, compare them
    for index in ${!version_required[@]}; do
        if [[ "${version_required[index]}" -eq "${version_found[index]}" ]]; then
            continue
        elif [[ "${version_required[index]}" -lt "${version_found[index]}" ]]; then
            return 0
        else
            return 1
        fi
    done
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
    line+=$(printf "found  ${text_color}Required version: ${emph_color}%5s${default}"\
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

function __static__Get_Gnu_Requirement_Report_For_Single_Program()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty system_information
    local -r emph_color='\e[96m'\
             red='\e[91m'\
             green='\e[92m'\
             yellow='\e[93m'\
             text_color='\e[38;5;38m'\
             default='\e[0m'
    local line program="GNU-$1"
    printf -v line "   ${emph_color}%6s${text_color}: ${default}" "${program}"
    if [[ $(cut -d'|' -f2 <<< "${system_information[${program}]}") = '---' ]]; then
        line+="${red}✘"
    else
        line+="${green}✔︎"
    fi
    printf "${line}${default}"
}
