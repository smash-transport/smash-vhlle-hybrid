#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__version()
{
    source "${HYBRIDT_repository_top_level_path}"/bash/version.bash || exit "${HYBRID_fatal_builtin}"
}

function Unit_Test__version()
{
    HYBRID_codebase_version='SMASH-vHLLE-hybrid-1.0'
    local std_output expected_output
    # Unsetting PATH in the subshell so that 'git' will not be found
    std_output=$(
        PATH=''
        Call_Codebase_Function Print_Software_Version
    )
    if [[ $? -ne 0 ]] \
        || [[ $(Strip_ANSI_Color_Codes_From_String "${std_output}") != "This is ${HYBRID_codebase_version}" ]]; then
        Print_Error "Version printing without git available failed."
        return 1
    fi
    # We want to capture here a logger message that goes to fd 9
    std_output=$(Call_Codebase_Function Print_Software_Version 9>&1)
    if [[ $? -ne 0 || $(grep -c "${HYBRID_codebase_version}" <<< "${std_output}") -eq 0 ]]; then
        Print_Error "Version printing with git failed."
        return 1
    fi
}
