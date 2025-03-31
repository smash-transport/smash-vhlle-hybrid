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
    # To make sure this test is always sound, we set here a fake fall-back
    # version number in the following variable. If Git history is available this
    # is not used, but for example on GitHub in the self-hosted actions it will
    # be used as the repository is locally checked out effectively as a
    # black-box archive. Testing using a regex should cover all cases.
    HYBRID_codebase_version='SMASH-vHLLE-hybrid-42.666.1'
    HYBRID_codebase_version_regex='SMASH-vHLLE-hybrid-[0-9]+([.][0-9]+)?'
    local std_output
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
    if [[ $? -ne 0 || $(grep -cE "${HYBRID_codebase_version_regex}" <<< "${std_output}") -eq 0 ]]; then
        Print_Error "Version printing with git failed."
        return 1
    fi
}
