#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function __static__Fake_Command_Version()
{
    if [[ "$3" = "$1" ]]; then
        echo $2
    else
        Print_Fatal_And_Exit "wrong usage of ${FUNCNAME[1]}"
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

# This tests asks Check_System_Requirements first for success, in case of a 'good' input;
# and for failure, in case of a 'bad' one. Here 99.0.0 and 1.0 respectively should suffice 
# for most commands. Since the check only uses the commands to look for their version, they
# are faked here to only accept the specific version flag, and fail otherwise.  

function Unit_Test__system-requirements()
{
    __static__Inhibit_Commands_Version
    local good_version='99.0.0'
    local bad_version='1.0'

    local version=${good_version}
    ( Check_System_Requirements &> /dev/null )
    if [[ $? -ne 0 ]]; then
        Print_Error "${good_version} is lower than some requirements"
        return 1
    fi
    version=${bad_version}
    ( Check_System_Requirements &> /dev/null )
    if [[ $? -ne 1 ]]; then
        Print_Error "${bad_version} is higher than some requirements"
        return 1
    fi
}
