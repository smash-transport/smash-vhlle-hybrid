#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Parse_Specific_Mode_Options_prepare-scan()
{
    set -- "${HYBRID_command_line_options_to_parse[@]}"
    HYBRID_command_line_options_to_parse=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --scan-name)
                if [[ ${2-} =~ ^(-|$) ]]; then
                    Print_Option_Specification_Error_And_Exit "$1"
                else
                    readonly HYBRID_scan_directory="${HYBRID_output_directory}/$2"
                fi
                shift 2
                ;;
            *)
                HYBRID_command_line_options_to_parse+=("$1")
                shift
                ;;
        esac
    done

}
