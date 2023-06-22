#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Print_Software_Version()
{
    Ensure_That_Given_Variables_Are_Set HYBRID_codebase_version
    # First handle cases where git is not available, or codebase downloaded as archive and not cloned
    # NOTE: Git introduced -C option in version 1.8.5
    if ! hash git &> /dev/null ||\
       ! git -C "${HYBRID_top_level_path}" rev-parse --is-inside-work-tree &> /dev/null ||\
       __static__Is_Git_Version_Older_Than '1.8.3'; then
        __static__Print_Pretty_Version_Line "${HYBRID_codebase_version}"
        return 0
    fi
    local git_tag_short git_tag_long tag_date
    if ! git_tag_long=$(git -C "${HYBRID_top_level_path}" describe --tags 2> /dev/null); then
        Print_Warning "It was not possible to obtain the version in use!"\
                      "This probably (but not necessarily) means that you are"\
                      "behind any release in the Hybrid-handler history.\n"
        __static__Print_Pretty_Version_Line "${HYBRID_codebase_version}"
        return 0
    fi
    if ! git_tag_short=$(git -C "${HYBRID_top_level_path}" describe --tags --abbr=0 2> /dev/null); then
        Print_Internal_And_Exit "Unexpected error in \"${FUNCNAME}\" trying to obtain the closest git tag."
    fi
    tag_date=$(date -d "$(git -C "${HYBRID_top_level_path}" log -1 --format=%ai "${git_tag_short}")" +'%d %B %Y')
    if [[ "${git_tag_short}" != "${git_tag_long}" ]]; then
        if __static__Is_Git_Version_Older_Than '2.13'; then
            git_tag_long=$(git -C "${HYBRID_top_level_path}" describe --tags --dirty 2>/dev/null)
        else
            git_tag_long=$(git -C "${HYBRID_top_level_path}" describe --tags --dirty --broken 2>/dev/null)
        fi
        local last_stable_release_string=$(printf '\e[38;5;202m%s (%s)' "${git_tag_short}" "${tag_date}")
        Print_Warning "You are not using an official release of the Hybrid-handler."\
                      "Unless you have a reason not to do so, it would be better"\
                      "to checkout a stable release. The last stable release behind"\
                      "the commit you are using is: ${last_stable_release_string}\n"\
                      "The repository state is $(printf '\e[38;5;202m%s\e[93m' "${git_tag_long}")"\
                      "(see git-describe documentation for more information)."
    else
        __static__Print_Pretty_Version_Line "${git_tag_short}" "${tag_date}"
    fi
}

function __static__Print_Pretty_Version_Line()
{
    local version_name=$1 release_date=${2-}
    printf '\e[96mThis is \e[38;5;85m%s\e[96m' "${version_name}"
    if [[ ${release_date} != '' ]]; then
        printf ' released on \e[93m%s' "${release_date}"
    fi
    printf '\e[0m\n'
}

function __static__Is_Git_Version_Older_Than()
{
    local required_version older_version
    required_version="git version $1"
    older_version=$(printf '%s\n%s\n' "$(git --version)" "${required_version}" | sort -V | head -n 1)
    if [[ "${older_version}" == "${required_version}" ]]; then
        return 1
    else
        return 0
    fi
}
