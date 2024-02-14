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
    local -r \
        parameters=("${!list_of_parameters_values[@]}") \
        scan_combinations_file="${HYBRID_scan_directory}/${HYBRID_scan_combinations_filename}"
    local parameters_combinations
    readarray -t parameters_combinations < \
        <(__static__Get_Parameters_Combinations_For_New_Configuration_Files "${list_of_parameters_values[@]}")
    readonly parameters_combinations
    __static__Validate_And_Create_Scan_Folder
    __static__Create_Combinations_File_With_Metadata_Header_Block
    __static__Create_Output_Files_In_Scan_Folder_And_Complete_Combinations_File
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
        # Get rid of spaces and square brackets and prepare brace expansion
        string_to_be_expanded+="{${values//[][ ]/}}_"
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

function __static__Create_Combinations_File_With_Metadata_Header_Block()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters scan_combinations_file
    Internally_Ensure_Given_Files_Do_Not_Exist "${scan_combinations_file}"
    local index
    {
        for index in "${!parameters[@]}"; do
            printf '# Parameter_%d: %s\n' $((index + 1)) "${parameters[index]}"
        done
        printf '#\n#___Run'
        for index in "${!parameters[@]}"; do
            printf '  Parameter_%d' $((index + 1))
        done
        printf '\n'
    } > "${scan_combinations_file}"
}

function __static__Create_Output_Files_In_Scan_Folder_And_Complete_Combinations_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty \
        list_of_parameters_values parameters parameters_combinations
    local -r number_of_files=${#parameters_combinations[@]}
    local id filename
    Print_Progress_Bar 0 ${number_of_files}
    for id in "${!parameters_combinations[@]}"; do
        filename="$(__static__Get_Output_Filename "${id}")"
        # Let word splitting split values in each parameters combination
        __static__Add_Line_To_Combinations_File "${id}" ${parameters_combinations[id]}
        __static__Create_Single_Output_File_In_Scan_Folder "${id}" ${parameters_combinations[id]}
        Print_Progress_Bar \
            $((id + 1)) ${number_of_files} '' "$(printf '%5d' $((id + 1)))/${number_of_files} files"
    done
    Print_Final_Progress_Bar \
        $((id + 1)) ${number_of_files} '' "$(printf '%5d' $((id + 1)))/${number_of_files} files"
}

function __static__Get_Output_Filename()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters_combinations
    # Here the filename has to contain the run number prefixed with the correct
    # amount of leading zeroes in order to make sorting easier for the user.
    local -r \
        number_of_combinations=${#parameters_combinations[@]} \
        run_number=$(($1 + 1))
    printf '%s_run_%0*d.yaml' \
        "${HYBRID_scan_directory}/$(basename "${HYBRID_scan_directory}")" \
        "${#number_of_combinations}" \
        "${run_number}"
}

function __static__Add_Line_To_Combinations_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty scan_combinations_file
    # These fields lengths are hard-coded for the moment and are meant to
    # properly align the column content to the header line description
    {
        printf '%7d' $(($1 + 1))
        shift
        printf '  %11s' "$@"
        printf '\n'
    } >> "${scan_combinations_file}"
}

function __static__Create_Single_Output_File_In_Scan_Folder()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters filename
    local -r run_number=$(($1 + 1))
    shift
    local -r set_of_values=("$@")
    Internally_Ensure_Given_Files_Do_Not_Exist "${filename}"
    __static__Add_Parameters_Comment_Line_To_New_Configuration_File
    local index yq_replacements
    for ((index = 0; index < ${#parameters[@]}; index++)); do
        yq_replacements+="( .${parameters[index]} ) = ${set_of_values[index]} |"
    done
    yq "${yq_replacements%?}" "${HYBRID_configuration_file}" >> "${filename}"
}

function __static__Add_Parameters_Comment_Line_To_New_Configuration_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty \
        parameters filename run_number set_of_values
    local -r longest_parameter_length=$(wc -L < <(printf '%s\n' "${parameters[@]}"))
    {
        printf '# Run %d of parameter scan "%s"\n#\n' "${run_number}" "${HYBRID_scan_directory}"
        local index
        for index in "${!parameters[@]}"; do
            printf '# %*s: %s\n' "${longest_parameter_length}" "${parameters[index]}" "${set_of_values[index]}"
        done
        printf '\n'
    } > "${filename}"
}
