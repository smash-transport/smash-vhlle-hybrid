#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__do-everything()
{
    shopt -s nullglob
    local -r config_filename='Handler_config.yaml'\
             mocks_folder="${HYBRIDT_repository_top_level_path}/tests/mocks"
    printf '
    IC:
      Executable: %s/smash_IC_black-box.py
    Hydro:
      Executable: %s/vhlle_black-box.py
    Sampler:
      Executable: %s/sampler_black-box.py
    Afterburner:
      Executable: %s/smash_afterburner_black-box.py
      Add_spectators_from_IC: FALSE
      Software_keys:
        Modi:
          List:
            File_Directory: "."
    ' "${mocks_folder}" "${mocks_folder}" "${mocks_folder}" "${mocks_folder}" > "${config_filename}"
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running full workflow with Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    if [[ $? -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    local block
    for block in IC Sampler Hydro Afterburner; do
        Check_If_Software_Produced_Expected_Output "${block}" "$(pwd)/${block}"
    done
}
