#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Prepare_Software_Input_File_Sampler()
{
    mkdir -p "${HYBRID_software_output_directory[Sampler]}" || exit ${HYBRID_fatal_builtin}
     if [[ -f "${HYBRID_software_configuration_file[Sampler]}" ]]; then
         exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit\
             'Configuration file ' --emph "${HYBRID_software_configuration_file[Sampler]}" ' is already existing.'
     elif [[ ! -f "${HYBRID_software_base_config_file[Sampler]}" ]]; then
         exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
             'Base configuration file ' --emph "${HYBRID_software_base_config_file[Sampler]}" ' was not found.'
     fi

     cp "${HYBRID_software_base_config_file[Sampler]}"\
        "${HYBRID_software_output_directory[Sampler]}" || exit ${HYBRID_fatal_builtin}
     if [[ "${HYBRID_software_new_input_keys[Sampler]}" != '' ]]; then
         Remove_Comments_And_Replace_Provided_Keys_In_Provided_Input_File\
             'TXT' "${HYBRID_software_configuration_file[Sampler]}" "${HYBRID_software_new_input_keys[Sampler]}"
     fi
}

function Ensure_All_Needed_Input_Exists_Sampler()
{
   if [[ ! -d "${HYBRID_software_output_directory[Sampler]}" ]]; then
         exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
             'Folder ' --emph "${HYBRID_software_output_directory[Sampler]}" ' does not exist.'
     fi
     if [[ ! -f "${HYBRID_software_configuration_file[Sampler]}" ]]; then
         exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
             'Configuration file ' --emph "${HYBRID_software_configuration_file[Sampler]}" ' was not found.'
     fi
     if [[ ! -f "${HYBRID_software_output_directory[Hydro]}/freezeout.dat" ]]; then
         exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
             'Freezeout hypersurface ' --emph "${HYBRID_software_output_directory[Hydro]}/freezeout.dat" ' does not exist.'
     fi
}

function Run_Software_Sampler()
{
    local -r Sampler_config_file_path="${HYBRID_software_configuration_file[Sampler]}"\
              Sampler_terminal_output="${HYBRID_software_output_directory[Sampler]}/Terminal_Output.txt"
     "${HYBRID_software_executable[Sampler]}" "events"  1 \
     "${Sampler_config_file_path}" >> "${Sampler_terminal_output}"
}


Make_Functions_Defined_In_This_File_Readonly
