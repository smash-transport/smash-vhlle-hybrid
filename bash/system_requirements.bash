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
    declare -gA HYBRID_systemRequirements=(
        ['bash']='4.4.0'
        ['awk']='4.1.0'
        ['sed']='4.2.1'
	['tput']='5.9.0' # the last number is a date
	['yq']='4.0'
    )
}

function Check_System_Requirements()
{
    local program requirements_present
    requirements_present=0
    declare -A system_found_versions
    __static__Declare_System_Requirements
    for program in "${!HYBRID_systemRequirements[@]}"; do
        if ! __static__Try_Find_Requirement "${program}"; then
	    Print_Error "${program}" 'not found! Minimum version' "${HYBRID_systemRequirements[${program}]}" 'is required.'
	    requirements_present=1
	    continue
	fi
	if ! __static__Try_Find_Version "${program}"; then
	    Print_Warning "Unable to find version of ${program}, skipping version check! Please ensure that current version is at least ${HYBRID_systemRequirements[${program}]}." 
	    continue
	fi
	if ! __static__Check_Version_Suffices "${program}"; then
	    Print_Error "${program} version ${system_found_versions[${program}]} found, but version ${HYBRID_systemRequirements[${program}]} is required."
	    requirements_present=1
        fi
    done
    if [[ ${requirements_present} -ne 0 ]]; then
        Print_Fatal_And_Exit 'Please install (maybe locally) the required versions of the above programs.'
    else
	return ${requirements_present}
    fi
}

function __static__Try_Find_Requirement()
{
    if hash $1 2>/dev/null; then
        return 0
    else
	return 1
    fi
}

function __static__Try_Find_Version()
{
    local found_version
    case "$1" in
        bash )
            found_version="${BASH_VERSINFO[@]:0:3}"
            found_version="${found_version// /.}"
	    ;;
	awk )
	    found_version=$(awk --version | head -n1 | grep -o "[0-9.]\+" | head -n1)
	    ;;
	sed )
	    found_version=$(sed --version | head -n1 | grep -o "[0-9.]\+" | head -n1)
	    ;;
	tput )
	    found_version=$(tput -V | grep -o "[0-9.]\+" | cut -d'.' -f1,2)
	    ;;
	yq )
	    found_version=$(yq --version | grep -o "v[0-9.]\+" | cut -d'v' -f2)
	    ;;
    *)
	return 1
    esac    
    if [[ ${found_version} =~ ^[0-9]([.0-9])*$ ]]; then
        system_found_versions["$1"]="${found_version}"
    else
        return 1
    fi
}

function __static__Check_Version_Suffices()
{
    # Here we assume that the programs follow the semantic versioning standard
    local required found versioning
    required=($(echo "${HYBRID_systemRequirements[$1]}" | tr '.' ' '))
    found=($(echo "${system_found_versions[$1]}" | tr '.' ' '))
    if [[ "${required[${versioning}]}" -eq "${found[${versioning}]}" ]]; then
	return 0
    fi
    for versioning in ${!required[@]}; do
        if [[ "${required[${versioning}]}" -lt "${found[${versioning}]}" ]]; then
	    return 0
	fi
    done
    return 1
}
