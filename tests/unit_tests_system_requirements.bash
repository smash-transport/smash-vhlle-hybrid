#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: The following unit test checks the system requirements code by defining functions
#       with the same name as the required system commands. This will make bash run these
#       instead of the system ones (remember that functions have higher priority than
#       external commands). As each fake command print the variable ${...version} as version
#       number, it is then possible to mimic a system complying with the requirements and
#       another one violating them. The same is valid for the ${gnu} variable.

function __static__Fake_Command_Version()
{
    if [[ "$3" = "$1" ]]; then
        printf "$2\n" # If version was requested print fake string
    else
        command ${FUNCNAME[1]} "${@:3}" # otherwise run original commands with given arguments
    fi
}

function __static__Inhibit_Commands_Version()
{
    function awk()
    {
        __static__Fake_Command_Version\
            '--version' "${gnu} Awk ${awk_version}, API: 3.0 (${gnu} MPFR 4.1.0, ${gnu} MP 6.2.1)" "$@"
    }
    function sed()
    {
        __static__Fake_Command_Version\
            '--version' "sed (${gnu} sed) ${sed_version} Packaged by Debian" "$@"
    }
    function tput()
    {
        __static__Fake_Command_Version\
            '-V' "ncurses ${tput_version}" "$@"
    }
    function yq()
    {
       __static__Fake_Command_Version\
            '--version' "yq (https://github.com/mikefarah/yq/) version v${yq_version}" "$@"
    }
}

function Unit_Test__system-requirements()
{
    __static__Inhibit_Commands_Version
    local gnu {awk,sed,tput,yq}_version
    gnu='GNU'
    awk_version=4.1
    sed_version=4.2.1
    tput_version=5.9
    yq_version=4
    ( Check_System_Requirements )
    if [[ $? -ne 0 ]]; then
        Print_Error "Check system requirements of good system failed."
        return 1
    fi
    ( Check_System_Requirements_And_Make_Report )
    if [[ $? -ne 0 ]]; then
        Print_Error "Check system requirements making report of good system failed."
        return 1
    fi
    gnu='BSD'
    awk_version=4.0.9
    sed_version=4.2.0
    tput_version=5.9
    yq_version=3.9.98
    ( Check_System_Requirements &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error "Check system requirements of bad system succeeded."
        return 1
    fi
    ( Check_System_Requirements_And_Make_Report )
    if [[ $? -ne 0 ]]; then
        Print_Error "Check system requirements making report of bad system failed."
        return 1
    fi
}
