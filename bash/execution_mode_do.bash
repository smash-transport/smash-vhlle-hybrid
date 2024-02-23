#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Do_Needed_Operations_For_Given_Software()
{
    printf '\e[1A' # Just aesthetics to 'skip' newline for first loop iteration
    local software_section
    for software_section in "${HYBRID_given_software_sections[@]}"; do
        # Here abuse the logger to simply indent date
        Print_Info -l -- "\n$(printf '\e[0m%s' "$(date)")"
        Prepare_Software_Input_File "${software_section}"
        Ensure_All_Needed_Input_Exists "${software_section}"
        Ensure_Run_Reproducibility "${software_section}"
        Run_Software "${software_section}"
    done
}
