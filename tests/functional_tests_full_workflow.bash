#===================================================
#
#    Copyright (c) 2023-2026
#      Hybrid-handler Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Functional_Test__do-everything-wo-spectators-old-IC()
{
    __static__Set_IC_Software_Version_To 3.2
    __static__Test_Full_Workflow 'FALSE' 1
}

function Functional_Test__do-everything-wo-spectators-new-IC()
{
    __static__Set_IC_Software_Version_To 3.3
    __static__Test_Full_Workflow 'FALSE' 1
}

function __static__Set_IC_Software_Version_To()
{
    Print_Debug "Set IC software version to $1"
    export MOCK_IC_VERSION=$1
}

function Functional_Test__do-everything-with-spectators()
{
    __static__Test_Full_Workflow 'TRUE' 1
}

function __static__Test_Full_Workflow()
{
    shopt -s nullglob
    local -r \
        config_filename='Handler_config.yaml' \
        mocks_folder="${HYBRIDT_tests_folder}/mocks"
    __static__Prepare_Full_Handler_Configuration_File "$1"
    __static__Create_Auxiliaries_For_Hydro
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running full workflow with Hybrid-handler expecting success'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
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
        Software_keys:
            General:
                Nevents: %d
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
    ' "${mocks_folder}" "$2" "$(pwd)" "${mocks_folder}" "${mocks_folder}" "$1" > "${config_filename}"
}

function __static__Check_Outcome_Of_Full_Run()
{
    if [[ $1 -ne 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly failed.'
        return 1
    fi
    local block
    for block in IC Sampler_SMASH Hydro Afterburner; do
        if [[ "${block}" == "Sampler_SMASH" ]]; then
            Check_If_Software_Produced_Expected_Output "${block}" "$(pwd)/Sampler"
        else
            Check_If_Software_Produced_Expected_Output "${block}" "$(pwd)/${block}"
        fi
    done
}

function Functional_Test__do-everything-with-spectators-and-multiple-events()
{
    shopt -s nullglob
    local -r \
        config_filename='Handler_config.yaml' \
        mocks_folder="${HYBRIDT_tests_folder}/mocks"
    __static__Prepare_Full_Handler_Configuration_File 'TRUE' 42
    __static__Create_Auxiliaries_For_Hydro
    # Expect success and test absence of "SMASH" unfinished file
    Print_Info 'Running full workflow with Hybrid-handler expecting failure'
    Run_Hybrid_Handler_With_Given_Options_In_Subshell 'do' '-c' "${config_filename}" '-o' '.'
    if [[ $? -eq 0 ]]; then
        Print_Error 'Hybrid-handler unexpectedly succeeded with spectators and ' --emph 'IC Nevents>1' '.'
        return 1
    fi
}
