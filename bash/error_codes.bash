#===================================================
#
#    Copyright (c) 2023-2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# Standard bash exit codes (0 for success and 1 for generic failure) are not
# aliased to a variable here. This is an aware decision because they are so
# standard that hard-coding them in the codebase where needed is just fine.

# Variables for exit codes (between 64 and 113)
#   -> http://tldp.org/LDP/abs/html/exitcodes.html
readonly HYBRID_fatal_builtin=64
readonly HYBRID_fatal_file_not_found=65
readonly HYBRID_fatal_wrong_config_file=66
readonly HYBRID_fatal_command_line=67
readonly HYBRID_fatal_value_error=68
readonly HYBRID_fatal_missing_requirement=69
readonly HYBRID_fatal_software_failed=70
readonly HYBRID_fatal_logic_error=110
readonly HYBRID_fatal_missing_feature=111
readonly HYBRID_fatal_variable_unset=112
readonly HYBRID_internal_exit_code=113
