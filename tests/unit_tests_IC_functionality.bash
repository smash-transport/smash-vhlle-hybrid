#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Make_Test_Preliminary_Operations__IC-create-input-file()
{
    local file_to_be_sourced list_of_files
    list_of_files=(
        'IC_functionality.bash'
        'global_variables.bash'
    )
    for file_to_be_sourced in "${list_of_files[@]}"; do
        source "${HYBRIDT_repository_top_level_path}/bash/${file_to_be_sourced}" || exit ${HYBRID_fatal_builtin}
    done
    HYBRID_repository_global_path="${HYBRIDT_repository_top_level_path}"
    Define_Further_Global_Variables
}

function Unit_Test__IC-create-input-file()
{
    HYBRID_output_directory="./test_dir_IC"
    if [[ -d "${HYBRID_output_directory}" ]]; then
        rm -r "${HYBRID_output_directory}"
    fi
    mkdir "${HYBRID_output_directory}"
    Prepare_Software_Input_File_IC
    IC_config_name=$(basename "${HYBRID_software_base_config_file[IC]}")
    IC_input_file_path="${HYBRID_output_directory}/IC/${IC_config_name}"
    if [[ ! -f "${IC_input_file_path}" ]]; then
        Print_Error 'File was not created.'
        return 1
    fi
}
