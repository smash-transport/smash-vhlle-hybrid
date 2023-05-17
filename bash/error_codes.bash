#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# Standard bash exit codes
readonly HYBRID_success_exit_code=0
readonly HYBRID_failure_exit_code=1

# Variables for exit codes (between 64 and 113)
#   -> http://tldp.org/LDP/abs/html/exitcodes.html
readonly HYBRID_fatal_builtin=64
readonly HYBRID_fatal_file_not_found=65
readonly HYBRID_fatal_wrong_config_file=66
readonly HYBRID_fatal_command_line=67
readonly HYBRID_fatal_value_error=68
readonly HYBRID_fatal_logic_error=110
readonly HYBRID_fatal_missing_feature=111
readonly HYBRID_fatal_variable_unset=112
readonly HYBRID_internal=113
