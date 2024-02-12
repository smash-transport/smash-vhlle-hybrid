#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Print_Progress_Bar
{
    __static__Validate_Progress_Bar_Input "$@"
    Print_Info -l -- "\e[K$(__static__Get_Progress_Bar $1 $2)\r\e[1A"
}

function Print_Final_Progress_Bar
{
    __static__Validate_Progress_Bar_Input "$@"
    Print_Info -l -- "\e[K$(__static__Get_Progress_Bar $1 $2)"
}

function __static__Validate_Progress_Bar_Input()
{
    if [[ $# -lt 2 ]] || [[ ! $1 =~ ^[0-9]+(.[0-9]+)*$ ]] || [[ ! $2 =~ ^[0-9]+(.[0-9]+)*$ ]]; then
        Print_Internal_And_Exit --emph "${FUNCNAME[1]}" ' wrongly called (' --emph "$1 $2" ').'
    fi
}

function __static__Get_Progress_Bar()
{
    local -r \
        done=$1 \
        total=$2 \
        prefix="${3-}" \
        suffix="${4-}" \
        bar="━" \
        half_bar_right="╸"
    local output="${prefix} " color
    local -r percentage=$(awk '{printf "%.0f", 100*$1/$2}' <<< "${done} ${total}")
    if [[ ${percentage} -lt 30 ]]; then
        color='\e[91m'
    elif [[ ${percentage} -lt 40 ]]; then
        color='\e[38;5;202m'
    elif [[ ${percentage} -lt 50 ]]; then
        color='\e[38;5;208m'
    elif [[ ${percentage} -lt 60 ]]; then
        color='\e[38;5;221m'
    elif [[ ${percentage} -lt 70 ]]; then
        color='\e[38;5;191m'
    elif [[ ${percentage} -lt 80 ]]; then
        color='\e[38;5;148m'
    elif [[ ${percentage} -lt 90 ]]; then
        color='\e[38;5;118m'
    else
        color='\e[92m'
    fi
    output+=$(printf "${color}")
    for ((i = 0; i < ${percentage}; i++)); do
        output+="${bar}"
    done
    output+="${half_bar_right}"
    for ((i = ${percentage}; i < 100; i++)); do
        output+="\e[38;5;237m${bar}"
    done
    output+=$(printf '\e[96m %d%%\e[0m %s' ${percentage} "${suffix}")
    printf '%s' "${output}"
}
