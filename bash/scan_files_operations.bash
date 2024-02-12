#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Create_And_Populate_Scan_Folder()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    local -r parameters=( "${!list_of_parameters_values[@]}" )
    local parameters_combinations
    readarray -t parameters_combinations < \
        <(__static__Get_Parameters_Combinations_For_New_Configuration_Files "${list_of_parameters_values[@]}")
    readonly parameters_combinations
    __static__Validate_And_Create_Scan_Folder
    __static__Create_Output_Files_In_Scan_Folder
}

function __static__Get_Parameters_Combinations_For_New_Configuration_Files()
{
    # NOTE: This is were multiple ways of doing combinations will be implemented:
    #       For example, cartesian product VS all first values, all second ones, etc.
    #       At the moment only the cartesian product approach is implemented, i.e.
    #       all possible combinations of parameters values are considered.
    __static__Get_All_Parameters_Combinations "$@"
}

function __static__Get_All_Parameters_Combinations()
{
    local values string_to_be_expanded
    for values in "$@"; do
        values=$(sed -e 's/ //g' -e 's/[[]/\{/' -e 's/[]]/\}/' <<< "${values}")
        string_to_be_expanded+="${values}_"
    done
    # NOTE: The following use of 'eval' is fine since the string that is expanded
    #       is guaranteed to be validated to contain only YAML int, bool or float.
    eval printf '%s\\\n' "${string_to_be_expanded%?}" | sed 's/_/ /g'
}

function __static__Validate_And_Create_Scan_Folder()
{
    Ensure_Given_Folders_Do_Not_Exist \
        'The scan output folder is meant to be freshly created by the handler.' '--' \
        "${HYBRID_scan_directory}"
    mkdir -p "${HYBRID_scan_directory}"
}

function __static__Create_Output_Files_In_Scan_Folder()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty \
        list_of_parameters_values parameters parameters_combinations
    local id filename
    for id in "${!parameters_combinations[@]}"; do
        filename="$(__static__Get_Output_Filename "${id}")"
        Print_Info "${filename}" "${parameters_combinations[id]}"
        # Let word splitting split values in each parameters combination
        __static__Create_Single_Output_File_In_Scan_Folder ${parameters_combinations[id]}
    done
}

function __static__Create_Single_Output_File_In_Scan_Folder()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters filename
    local -r set_of_values=( "$@" )
    local index yq_replacements
    for ((index=0; index<${#parameters[@]}; index++)); do
        yq_replacements+="( .${parameters[index]} ) = ${set_of_values[index]} |"
    done
    yq "${yq_replacements%?}" "${HYBRID_configuration_file}" > "${filename}"
}

function __static__Get_Output_Filename()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters_combinations
    # Here the filename has to contain the run number prefixed with the correct
    # amount of leading zeroes in order to make sorting easier for the user.
    local -r \
        number_of_combinations=${#parameters_combinations[@]} \
        run_number=$(($1+1))
    printf '%s_%0*d.yaml' \
        "${HYBRID_scan_directory}/${HYBRID_scan_directory}" \
        "${#number_of_combinations}" \
        "${run_number}"
}
