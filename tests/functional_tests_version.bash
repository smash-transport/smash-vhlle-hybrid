#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__version()
{
    local version_output git_describe
    version_output=$(Run_Hybrid_Handler_With_Given_Options_In_Subshell 'version')
    if [[ $? -ne 0 ]]; then
        Print_Fatal_And_Exit 'Execution of version mode unexpectedly failed.'
    fi
    git_describe=$(
        cd "${HYBRIDT_repository_top_level_path}"
        git describe --abbrev=0
    )
    printf "${version_output}\n"
    if [[ $(grep -c "${git_describe}" <<< "${version_output}") -gt 0 ]]; then
        return 0
    else
        Print_Error 'Version string is not containing ' --emph "${git_describe}" ' as expected.'
        return 1
    fi
}
