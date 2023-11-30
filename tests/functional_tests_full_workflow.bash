#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__do-everything-without-spectators()
{
    __static__Test_Full_Workflow 'FALSE'
}

function Functional_Test__do-everything-with-spectators()
{
    __static__Test_Full_Workflow 'TRUE'
}

function __static__Test_Full_Workflow()
{
    shopt -s nullglob
    local -r config_filename='Handler_config.yaml'\
             mocks_folder="${HYBRIDT_tests_folder}/mocks"
    __static__Prepare_Full_Handler_Configuration_File "$1"
    __static__Create_Auxiliaries_For_Hydro
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running full workflow with Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}"
    __static__Check_Outcome_Of_Full_Run $?
}

function __static__Create_Auxiliaries_For_Hydro()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty mocks_folder
    # Make a symlink to the python mock such that the eos folder doesn't have to be created in the mock folder
    ln -s "${mocks_folder}/vhlle_black-box.py" "vhlle_black-box.py"
    mkdir 'eos'
}

function __static__Prepare_Full_Handler_Configuration_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty config_filename mocks_folder
    printf '
      IC:
        Executable: %s/smash_IC_black-box.py
      Hydro:
        Executable: %s/vhlle_black-box.py
      Sampler:
        Executable: %s/sampler_black-box.py
      Afterburner:
        Executable: %s/smash_afterburner_black-box.py
        Add_spectators_from_IC: %s
        Software_keys:
          Modi:
            List:
              File_Directory: "."
    ' "${mocks_folder}" "$(pwd)" "${mocks_folder}" "${mocks_folder}" "$1" > "${config_filename}"
}

function __static__Check_Outcome_Of_Full_Run()
{
    if [[ $1 -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    local block
    for block in IC Sampler Hydro Afterburner; do
        Check_If_Software_Produced_Expected_Output "${block}" "$(pwd)/${block}"
    done
}
