#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================
#
# This file has been taken from the BashLogger project (v0.2)
#   https://github.com/AxelKrypton/BashLogger
# and, as requested, its original license header is reported here below.
#
#----------------------------------------------------------------------------------------
#
#  Copyright (c) 2019,2023
#    Alessandro Sciarra <sciarra@itp.uni-frankfurt.de>
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
# The logger will print output to the chosen file descriptor (by default 42). This is
# done (instead of simply let it print to standard output) to be able to use the logger
# in functions that "return" by printing to stdout and that are meant to be called in $().
#
# ATTENTION: It might be checked if the chosen fd exists and in case open it in the Logger
#            function itself. However, if the first Logger call is done in a subshell, then
#            the chosen fd would not be open globally for the script and following calls to
#            the Logger would fail. Hence, we open the fd at source time and not close it
#            in the Logger.
#
# NOTE: Nothing is done if this file is executed and not sourced!
#
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    BSHLGGR_outputFd=42
    BSHLGGR_defaultExitCode=1
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fd )
                if [[ ! $2 =~ ^[1-9][0-9]*$ ]] || (( $2>254 )); then
                    printf "Error sourcing BashLogger. '$1' option needs an integer value between 1 and 254.\n"
                    return 1
                else
                    BSHLGGR_outputFd=$2
                    shift 2
                fi
                ;;
            --default-exit-code )
                if [[ ! $2 =~ ^[0-9]+$ ]] || (( $2>255 )); then
                    printf "Error sourcing BashLogger. '$1' option needs an integer value between 0 and 255.\n"
                    return 1
                else
                    BSHLGGR_defaultExitCode=$2
                    shift 2
                fi
                ;;
            *)
                printf "Error sourcing BashLogger. Unknown option '$1'.\n"
                return 1
                ;;
        esac
    done
    # Probably redundant check, but we want guarantee that 'eval' is safe to use here
    # e.g. that the BSHLGGR_outputFd cannot be set to '; rm -rf /; #' (AAARGH!).
    if [[ ! ${BSHLGGR_outputFd} =~ ^[1-9][0-9]*$ ]]; then
        printf "Unexpected error sourcing BashLogger. Please contact developers.\n"
        return 1
    else
        eval "exec ${BSHLGGR_outputFd}>&1"
    fi
    readonly BSHLGGR_outputFd BSHLGGR_defaultExitCode
fi

function PrintTrace()
{
    __static__Logger 'TRACE' "$@"
}
function Print_Trace()
{
    PrintTrace "$@"
}

function PrintDebug()
{
    __static__Logger 'DEBUG' "$@"
}
function Print_Debug()
{
    PrintDebug "$@"
}

function PrintInfo()
{
    __static__Logger 'INFO' "$@"
}
function Print_Info()
{
    PrintInfo "$@"
}

function PrintAttention()
{
    __static__Logger 'ATTENTION' "$@"
}
function Print_Attention()
{
    PrintAttention "$@"
}

function PrintWarning()
{
    __static__Logger 'WARNING' "$@"
}
function Print_Warning()
{
    PrintWarning "$@"
}

function PrintError()
{
    __static__Logger 'ERROR' "$@"
}
function Print_Error()
{
    PrintError "$@"
}

function PrintFatalAndExit()
{
    __static__Logger 'FATAL' "$@"
}
function Print_Fatal_And_Exit()
{
    PrintFatalAndExit "$@"
}

function PrintInternalAndExit()
{
    __static__Logger 'INTERNAL' "$@"
}
function Print_Internal_And_Exit()
{
    PrintInternalAndExit "$@"
}

function __static__Logger()
{
    if [[ $# -lt 1 ]]; then
        __static__Logger 'INTERNAL' "${FUNCNAME} called without label!"
    fi
    local label labelLength labelToBePrinted color emphColor finalEndline restoreDefault
    finalEndline='\n'
    restoreDefault='\e[0m'
    labelLength=10
    label="$1"; shift
    labelToBePrinted=$(printf "%${labelLength}s" "${label}:")
    if [[ ! ${label} =~ ^(INTERNAL|FATAL|ERROR|WARNING|ATTENTION|INFO|DEBUG|TRACE)$ ]]; then
        __static__Logger 'INTERNAL' "${FUNCNAME} called with unknown label '${label}'!"
    fi
    __static__IsLevelOn "${label}" || return 0
    exec 4>&1 # duplicate fd 1 to restore it later
    case "${label}" in
        ERROR|FATAL )
            # ;;& means go on in case matching following patterns
            color='\e[91m' ;;&
        INTERNAL )
            color='\e[38;5;202m' ;;&
        ERROR|FATAL|INTERNAL )
            emphColor='\e[93m'
            exec 1>&2 ;; # here stdout to stderr!
        INFO )
            color='\e[92m'
            emphColor='\e[96m' ;;&
        ATTENTION )
            color='\e[38;5;200m'
            emphColor='\e[38;5;141m' ;;&
        WARNING )
            color='\e[93m'
            emphColor='\e[38;5;202m' ;;&
        DEBUG )
            color='\e[38;5;38m'
            emphColor='\e[38;5;48m' ;;&
        TRACE )
            color='\e[38;5;247m'
            emphColor='\e[38;5;256m' ;;&
        * )
            exec 1>&"${BSHLGGR_outputFd}" ;; # here stdout to chosen fd
    esac
    if __static__IsElementInArray '--' "$@"; then
        while [[ "$1" != '--' ]]; do
            case "$1" in
                -n )
                    finalEndline=''
                    shift ;;
                -l )
                    labelToBePrinted="$(printf "%${labelLength}s" '')"
                    shift ;;
                -d )
                    restoreDefault=''
                    shift ;;
                * )
                    __static__Logger 'INTERNAL' "${FUNCNAME} called with unknown option \"$1\"!" ;;
            esac
        done
        shift
    fi
    # Print out initial new-lines before label suppressing first argument if it was endlines only
    while [[ $1 =~ ^\\n ]]; do
        printf '\n'
        if [[ "${1/#\\n/}" = '' ]]; then
            shift
        else
            set -- "${1/#\\n/}" "${@:2}"
        fi
    done
    # Ensure something to print was given
    if [[ $# -eq 0 ]]; then
        __static__Logger 'INTERNAL' "${FUNCNAME} called without message (or with new lines only)!"
    fi
    # Parse all arguments and save messages for later, possibly modified
    local messagesToBePrinted emphNextString lastStringWasEmph indentation index
    messagesToBePrinted=()
    emphNextString='FALSE'
    lastStringWasEmph='FALSE'
    indentation=''
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --emph )
                # Here two cases should be handled: either '--emph' is an option or a string
                #   -> it is literal if the last command line option or if following the option
                #   -> it is an option otherwise
                # Use a fallthrough to continue matching in the case construct and use *) case
                # to print. However, shift and continue must be given if '--emph' was an option.
                if [[ $# -eq 1 || ${emphNextString} = 'TRUE' ]]; then
                    :
                else
                    emphNextString='TRUE'
                    shift
                    continue
                fi
                ;;&
            *)
                if [[ ${#messagesToBePrinted[@]} -gt 0 ]]; then
                    indentation="${labelToBePrinted//?/ } "
                fi
                # Set color and replace % by %% for later printf
                if [[ ${emphNextString} = 'TRUE' ]]; then
                    messagesToBePrinted+=( "${emphColor}${1//%/%%}" )
                    lastStringWasEmph='TRUE'
                else
                    if [[ ${lastStringWasEmph} = 'FALSE' ]]; then
                        if [[ ${#messagesToBePrinted[@]} -gt 0 ]]; then
                            messagesToBePrinted[-1]+='\n'
                        fi
                    else
                        indentation=''
                    fi
                    messagesToBePrinted+=( "${indentation}${color}${1//%/%%}" )
                    lastStringWasEmph='FALSE'
                fi
                emphNextString='FALSE'
                ;;
        esac
        shift
    done
    # Last message has no endline, add 'finalEndline' to it
    messagesToBePrinted[-1]+="${finalEndline}"
    set -- "${messagesToBePrinted[@]}"
    # Print first line
    printf "\e[1m${color}${labelToBePrinted}\e[0m $1"
    shift
    # Print possible additional lines
    while [[ $# -gt 0 ]]; do
        printf "$1"
        shift
    done
    if [[ ${label} = 'INTERNAL' ]]; then
        printf "${labelToBePrinted//?/ } Please, contact developers.\n"
    fi
    printf "${restoreDefault}"
    exec 1>&4- # restore fd 1 and close fd 4 and not close chosen fd (it must stay open, see top of the file!)
    if [[ ${label} =~ ^(FATAL|INTERNAL)$ ]]; then
        exit "${exit_code:-${BSHLGGR_defaultExitCode}}"
    fi
}

function __static__IsLevelOn()
{
    local label
    label="$1"
    # FATAL and INTERNAL always on
    if [[ ${label} =~ ^(FATAL|INTERNAL)$ ]]; then
        return 0
    fi
    # VERBOSE environment variable defines how verbose the output should be:
    #  - unset, empty, invalid value -> till INFO (no DEBUG TRACE)
    #  - numeric -> till that level (1=ERROR, 2=WARNING, ...)
    #  - string  -> till that level
    local loggerLevels loggerLevelsOn level index
    loggerLevels=( [1]='ERROR' [2]='WARNING' [3]='ATTENTION' [4]='INFO' [5]='DEBUG' [6]='TRACE' )
    loggerLevelsOn=()
    if [[ ${VERBOSE-} =~ ^[0-9]+$ ]]; then
        loggerLevelsOn=( "${loggerLevels[@]:1:VERBOSE}" )
    elif [[ ${VERBOSE-} =~ ^(ERROR|WARNING|ATTENTION|INFO|DEBUG|TRACE)$ ]]; then
        for level in "${loggerLevels[@]}"; do
            loggerLevelsOn+=( "${level}" )
            if [[ ${VERBOSE-} = "${level}" ]]; then
                break
            fi
        done
    elif [[ ${VERBOSE-} =~ ^(FATAL|INTERNAL)$ ]]; then
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

function __static__IsElementInArray()
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
         PrintTrace \
         PrintDebug \
         PrintInfo \
         PrintAttention \
         PrintWarning \
         PrintError \
         PrintFatalAndExit \
         PrintInternalAndExit \
         Print_Trace \
         Print_Debug \
         Print_Info \
         Print_Attention \
         Print_Warning \
         Print_Error \
         Print_Fatal_And_Exit \
         Print_Internal_And_Exit \
         __static__Logger \
         __static__IsLevelOn \
         __static__IsElementInArray
