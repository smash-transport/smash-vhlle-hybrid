#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# These variable declarations are gathered in a function in order to allow for
# reuse when implementing in-terminal manuals and/or autocompletion.
#
# NOTE: Since this file is sourced by the autocompletion code in the user
#       environment, it is important to keep to the minimum any pollution there.
#       Therefore this function has a prefix and it starts by '_'. Furthermore
#       this function is not marked as readonly to avoid errors in case the user
#       sources this file multiple times e.g. through their ~/.bashrc file.
function _HYBRID_Declare_Allowed_Command_Line_Options()
{
    # This associative array is meant to map execution modes to allowed options
    # in such a mode. A single associative array instead of many different arrays
    # makes it cleaner for the user environment. However, it is then needed to
    # assume that no option contains spaces and use word splitting from the caller.
    # This is a very reasonable assumption, though.
    declare -rgA HYBRID_allowed_command_line_options=(
        ['help']=''
        ['version']=''
        ['do']='--output-directory --configuration-file --id'
        ['prepare-scan']='--output-directory --configuration-file --scan-name'
    )
}
