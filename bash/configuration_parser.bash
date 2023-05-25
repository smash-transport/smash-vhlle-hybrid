#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Validate_And_Parse_Configuration_File()
{
    Print_Not_Implemented_Function_Error
    # Needed steps:
    #  1. Check existence 'HYBRID_configuration_file'
    #  2. Validate YAML using yq (remove all comments first)
    #  3. Validate top-level sections against 'HYBRID_valid_configuration_sections'
    #      -> here also the ordering should be validated
    #  4. Extract and parse 'Hybrid-handler' section
    #  5. Parse software sections setting all needed variables
    #      -> see global_variables.bash
    #      -> the software input keys must not be validated but simply put into 'HYBRID_software_input'
    #  6. Validate software to be later run for the given software sections (?)
}
