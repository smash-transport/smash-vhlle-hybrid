#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function __static__Source_Codebase_Files()
{
    local list_of_files file_to_be_sourced
    # Source error codes and fail with hard-coded generic error
    source "${HYBRID_top_level_path}/bash/error_codes.bash" || exit 1
    # Source logger using fd 9 (not too small and still smaller than 10 as bash manual suggests)
    source "${HYBRID_top_level_path}/bash/logger.bash" \
        --fd 9 --default-exit-code ${HYBRID_internal_exit_code} || exit ${HYBRID_fatal_builtin}
    # Source utility functions to be able to mark all functions as readonly
    # when sourcing the codebase files (otherwise this would not work)
    source "${HYBRID_top_level_path}/bash/utility_functions.bash" || exit ${HYBRID_fatal_builtin}
    list_of_files=(
        'Afterburner_functionality.bash'
        'command_line_parsers/helper.bash'
        'command_line_parsers/main_parser.bash'
        'command_line_parsers/sub_parser.bash'
        'common_functionality.bash'
        'configuration_parser.bash'
        'dispatch_functions.bash'
        'execution_mode_do.bash'
        'formatter.bash'
        'global_variables.bash'
        'Hydro_functionality.bash'
        'IC_functionality.bash'
        'Sampler_functionality.bash'
        'sanity_checks.bash'
        'software_input_functionality.bash'
        'system_requirements.bash'
        'version.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRID_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
}

# Call the function above and source the codebase files when this script is sourced
if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    __static__Source_Codebase_Files
    Make_Functions_Defined_In_This_File_Readonly
fi
