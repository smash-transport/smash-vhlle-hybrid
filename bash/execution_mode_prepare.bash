#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Do_Needed_Operation_For_Parameter_Scan()
{
    # This array is going to contain a map between the parameter and its list
    # of values. Since in general a scan run could request a scan in parameters
    # of different stages, here the parameter name is stored as a period-separated
    # list of keys as they appear in the Hybrid Handler configuration file, and
    # precisely in the 'Software_keys' sections. For example a scan in Hydro 'etaS'
    # would be stored here in the component with key 'Hydro.Software_keys.etaS'.
    # This syntax is handy when it comes to prepare all the configuration files
    # as it naturally interacts well with yq. The value is a YAML sequence of the
    # parameter values.
    declare -A list_of_parameters_values
    Format_Scan_Parameters_Lists
    Print_Info 'Validating input scan parameters values'
    Validate_And_Store_Scan_Parameters
    Print_Info 'Collecting parameters scan values'
    Create_List_Of_Parameters_Values
    Print_Info 'Preparing scan configuration files:'
    Create_And_Populate_Scan_Folder
}
