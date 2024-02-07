#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# Since it is not know here how the user has specified the list of scan parameters
# in the YAML configuration, we enforce here the "flow" yq-style, i.e.  '[...]'
#  -> https://mikefarah.gitbook.io/yq/operators/style#set-flow-quote-style
function Format_Scan_Parameters_Lists()
{
    local key
    for key in "${!HYBRID_scan_parameters[@]}"; do
        HYBRID_scan_parameters["${key}"]=$(yq '.. style="flow"' <<< "${HYBRID_scan_parameters["${key}"]}")
    done
}
