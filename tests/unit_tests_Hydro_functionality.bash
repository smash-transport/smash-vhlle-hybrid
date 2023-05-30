#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations_Hydro_test()
{
    source "${HYBRIDT_repository_top_level_path}"/bash/Hydro_functionality.bash\
    || exit "${HYBRID_fatal_builtin}"
}

function Unit_Test__Prepare-Software-Input-File-Hydro()
{
    Make_Test_Preliminary_Operations_Hydro_test
    Prepare_Software_Input_File_Hydro
}