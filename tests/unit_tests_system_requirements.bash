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
#       external commands). As each fake command print the variable ${version} as version
#       number, it is then possible to mimic a system complying with the requirements and
#       another one violating them.

function __static__Fake_Command_Version()
{
    if [[ "$3" = "$1" ]]; then
        printf "$2\n"
    else
        Print_Fatal_And_Exit "Wrong usage of ${FUNCNAME[1]} function."
    fi
}

function __static__Inhibit_Commands_Version()
{
    function awk()
    {
        __static__Fake_Command_Version '--version' "GNU Awk ${version}, API: 3.0 (GNU MPFR 4.1.0, GNU MP 6.2.1)" "$@"
    }
    function sed()
    {
        __static__Fake_Command_Version '--version' "sed (GNU sed) ${version} Packaged by Debian" "$@"
    }
    function tput()
    {
        __static__Fake_Command_Version '-V' "ncurses ${version}" "$@"
    }
    function yq()
    {
       __static__Fake_Command_Version '--version' "yq (https://github.com/mikefarah/yq/) version v${version}" "$@"
    }
}

function Unit_Test__system-requirements()
{
    __static__Inhibit_Commands_Version
    local good_version='999.0.0' bad_version='0.0'
    local version=${good_version}
    ( Check_System_Requirements )
    if [[ $? -ne 0 ]]; then
        Print_Error "Check system requirements of good system failed."
        return 1
    fi
    version=${bad_version}
    ( Check_System_Requirements &> /dev/null )
    if [[ $? -eq 0 ]]; then
        Print_Error "Check system requirements of bad system succeeded."
        return 1
    fi
}
