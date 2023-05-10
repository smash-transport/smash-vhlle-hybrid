#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================
#
# This file has been taken and adapted from the BashLogger project
# and therefore its original license header is reported here below.
#
#----------------------------------------------------------------------------------------
#
#  Copyright (c) 2019 Alessandro Sciarra <sciarra@itp.uni-frankfurt.de>
#
#  This file is part of BashLogger.
#
#  BashLogger is free software: you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  BashLogger is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with BashLogger. If not, see <https://www.gnu.org/licenses/>.
#
#----------------------------------------------------------------------------------------
#
# The logger will print output to new file descriptor 3 to be able to use the logger in
# functions that "return" printing to stdout to be called in $().
#
# ATTENTION: It might be checked if fd 3 exists and in case open it in the Logger itself.
#            However, if the first Logger call is done in a subshell, the fd 3 is not
#            open globally for the script and, therefore, we should ensure to open the
#            fd 3 for the script. We do then this at source time.
#
# NOTE: Nothing is done if this file is executed and not sourced!
#
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    exec 3>&1
fi

function Print_Trace()
{
    __static__Logger 'TRACE' "$@"
}

function Print_Debug()
{
    __static__Logger 'DEBUG' "$@"
}

function Print_Info()
{
    __static__Logger 'INFO' "$@"
}

function Print_Attention()
{
    __static__Logger 'ATTENTION' "$@"
}

function Print_Warning()
{
    __static__Logger 'WARNING' "$@"
}

function Print_Error()
{
    __static__Logger 'ERROR' "$@"
}

function Print_Fatal_And_Exit()
{
    __static__Logger 'FATAL' "$@"
}

function Print_Internal_And_Exit()
{
    __static__Logger 'INTERNAL' "$@"
}

function __static__Logger()
{
    if [[ $# -lt 1 ]]; then
        __static__Logger 'INTERNAL' "${FUNCNAME} called without label!"
    fi
    local label label_length label_to_be_printed color string final_endline restore_default
    final_endline='\n'
    restore_default='\e[0m'
    label_length=10
    label="$1"; shift
    label_to_be_printed=$(printf "%${label_length}s" "${label}:")
    if [[ ! ${label} =~ ^(INTERNAL|FATAL|ERROR|WARNING|ATTENTION|INFO|DEBUG|TRACE)$ ]]; then
        __static__Logger 'INTERNAL' "${FUNCNAME} called with unknown label '${label}'!"
    fi
    __static__Is_Level_On "${label}" || return 0
    exec 4>&1 # duplicate fd 1 to restore it later
    case "${label}" in
        ERROR|FATAL )
            color='\e[91m'
            exec 1>&2 ;; # here stdout to stderr!
        INTERNAL )
            color='\e[38;5;202m' ;;& # ;;& means go on in case matching following -> do *)
        INFO )
            color='\e[92m' ;;&
        ATTENTION )
            color='\e[38;5;200m' ;;&
        WARNING )
            color='\e[93m' ;;&
        DEBUG )
            color='\e[38;5;38m' ;;&
        TRACE )
            color='\e[38;5;247m' ;;&
        * )
            exec 1>&3 ;; # here stdout to fd 3!
    esac
    if __static__Is_Element_In_Array '--' "$@"; then
        while [[ "$1" != '--' ]]; do
            case "$1" in
                -n )
                    final_endline=''
                    shift ;;
                -l )
                    label_to_be_printed="$(printf "%${label_length}s" '')"
                    shift ;;
                -d )
                    restore_default=''
                    shift ;;
                * )
                    __static__Logger 'INTERNAL' "${FUNCNAME} called with unknown option \"$1\"!" ;;
            esac
        done
        shift
    fi
    if [[ $# -eq 0 ]]; then
        __static__Logger 'INTERNAL' "${FUNCNAME} called without message!"
    fi
    while [[ $1 =~ ^\\n ]]; do
        printf '\n'
        set -- "${1/#\\n/}" "${@:2}"
    done
    printf "\e[1m${color}${label_to_be_printed}\e[22m ${1//%/%%}"
    shift
    if [[ $# -eq 0 ]]; then
        printf "${final_endline}" # If nothing more to print use 'final_endline'
    else
        printf '\n'
        while [[ $# -gt 1 ]]; do
            printf "${label_to_be_printed//?/ } ${1//%/%%}\n"
            shift
        done
        printf "${label_to_be_printed//?/ } ${1//%/%%}${final_endline}"
    fi
    if [[ ${label} = 'INTERNAL' ]]; then
        printf "${label_to_be_printed//?/ } Please, contact developers.\n"
    fi
    printf "${restore_default}"
    exec 1>&4- # restore fd 1 and close fd 4 and not close fd 3 (it must stay open, see top of the file!)
    if [[ ${label} =~ ^(FATAL|INTERNAL)$ ]]; then
        exit "${user_fatal_exit_code:-1}"
    fi
}

function __static__Is_Level_On()
{
    local label
    label="$1"
    # FATAL and INTERNAL always on
    if [[ ${label} =~ ^(FATAL|INTERNAL)$ ]]; then
        return 0
    fi
    # VERBOSE environment variable defines how verbose the output should be:
    #  - unset or empty -> till INFO (no DEBUG TRACE)
    #  - numeric -> till that level (1=ERROR, 2=WARNING, ...)
    #  - string  -> till that level
    local loggerLevels loggerLevelsOn level index
    loggerLevels=( [1]='ERROR' [2]='WARNING' [3]='ATTENTION' [4]='INFO' [5]='DEBUG' [6]='TRACE' )
    loggerLevelsOn=()
    if [[ ${VERBOSE} =~ ^[0-9]+$ ]]; then
        loggerLevelsOn=( "${loggerLevels[@]:1:VERBOSE}" )
    elif [[ ${VERBOSE} =~ ^(ERROR|WARNING|ATTENTION|INFO|DEBUG|TRACE)$ ]]; then
        for level in "${loggerLevels[@]}"; do
            loggerLevelsOn+=( "${level}" )
            if [[ ${VERBOSE} = "${level}" ]]; then
                break
            fi
        done
    elif [[ ${VERBOSE} =~ ^(FATAL|INTERNAL)$ ]]; then
        loggerLevelsOn=( 'FATAL' )
    else
        loggerLevelsOn=( 'FATAL' 'ERROR' 'WARNING' 'ATTENTION' 'INFO' )
    fi
    for level in "${loggerLevelsOn[@]}"; do
        if [[ ${label} = "${level}" ]]; then
            return 0
        fi
    done
    return 1
}

function __static__Is_Element_In_Array()
{
    # ATTENTION: Since this function is used in the middle of the logger, the
    #            logger cannot be used in this function otherwise fd 4 is closed!
    local elementToBeFound arrayEntry
    elementToBeFound="$1"
    for arrayEntry in "${@:2}"; do
        if [[ "${arrayEntry}" = "${elementToBeFound}" ]]; then
            return 0
        fi
    done
    return 1
}

#-----------------------------------------------------------------#
#Set functions readonly to avoid possible redefinitions elsewhere
readonly -f \
         Print_Trace \
         Print_Debug \
         Print_Info \
         Print_Attention \
         Print_Warning \
         Print_Error \
         Print_Fatal_And_Exit \
         Print_Internal_And_Exit \
         __static__Logger \
         __static__Is_Level_On \
         __static__Is_Element_In_Array
