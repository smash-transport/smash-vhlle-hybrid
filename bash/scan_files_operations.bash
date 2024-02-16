#===================================================
#
#    Copyright (c) 2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# NOTE: The parameters names and values are stored in 'list_of_parameters_values'
#       which is an associative array. No key order is guaranteed, but it is
#       important for reproducibility across different machines to fix some
#       ordering. Here we create two normal arrays to sort names and have values
#       in the same order.
#
# ATTENTION: Here we use process substitution together with readarray to store data
#            into arrays. As getting the exit code of process substitution can be
#            tricky (https://unix.stackexchange.com/q/128560/370049) we adopt here
#            a workaround which consists in storing the data at first in a variable
#            using a standard command substitution. This will exit on error and
#            no further error handling is needed.
function Create_And_Populate_Scan_Folder()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    local -r \
        parameters=("${!list_of_parameters_values[@]}") \
        scan_combinations_file="${HYBRID_scan_directory}/${HYBRID_scan_combinations_filename}"
    local auxiliary_string parameters_names parameters_values parameters_combinations
    auxiliary_string=$(__static__Get_Fixed_Order_Parameters)
    readarray -t parameters_names < <(printf "${auxiliary_string}")
    auxiliary_string=$(__static__Get_Fixed_Order_Parameters_Values)
    readarray -t parameters_values < <(printf "${auxiliary_string}")
    auxiliary_string=$(__static__Get_Parameters_Combinations_For_New_Configuration_Files "${parameters_values[@]}")
    readarray -t parameters_combinations < <(printf "${auxiliary_string}")
    readonly parameters_names parameters_values parameters_combinations
    __static__Validate_And_Create_Scan_Folder
    __static__Create_Combinations_File_With_Metadata_Header_Block
    __static__Create_Output_Files_In_Scan_Folder_And_Complete_Combinations_File
}

function __static__Get_Fixed_Order_Parameters()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values
    # Sort parameters according to stage: IC, Hydro, Sampler, Afterburner (then alphabetically)
    #
    # NOTE: Using 'grep' would fail and make the function exit if no match was found
    #       and therefore it is simply easier to loop over parameters here.
    local key parameter
    for key in 'IC' 'Hydro' 'Sampler' 'Afterburner'; do
        for parameter in "${!list_of_parameters_values[@]}"; do
            if [[ ${parameter} = ${key}* ]]; then
                printf "${parameter}\n"
            fi
        done | sort --ignore-case
    done
}

function __static__Get_Fixed_Order_Parameters_Values()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty list_of_parameters_values parameters_names
    local name
    for name in "${parameters_names[@]}"; do
        printf '%s\n' "${list_of_parameters_values["${name}"]}"
    done
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
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters_names scan_combinations_file
    Internally_Ensure_Given_Files_Do_Not_Exist "${scan_combinations_file}"
    {
        for index in "${!parameters_names[@]}"; do
            printf '# Parameter_%d: %s\n' $((index + 1)) "${parameters_names[index]}"
        done
        printf '#\n#___Run'
        for index in "${!parameters_names[@]}"; do
            printf '  Parameter_%d' $((index + 1))
        done
        printf '\n'
    } > "${scan_combinations_file}"
}

function __static__Create_Output_Files_In_Scan_Folder_And_Complete_Combinations_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters_combinations
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
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters_names filename
    local -r run_number=$(($1 + 1))
    shift
    local -r set_of_values=("$@")
    Internally_Ensure_Given_Files_Do_Not_Exist "${filename}"
    __static__Add_Parameters_Comment_Line_To_New_Configuration_File
    __static__Add_YAML_Configuration_To_New_Configuration_File
    __static__Remove_Scan_Parameters_Key_From_New_Configuration_File
}

function __static__Add_Parameters_Comment_Line_To_New_Configuration_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty \
        parameters_names filename run_number set_of_values
    local -r longest_parameter_length=$(wc -L < <(printf '%s\n' "${parameters_names[@]}"))
    {
        printf '# Run %d of parameter scan "%s"\n#\n' "${run_number}" "${HYBRID_scan_directory}"
        local index
        for index in "${!parameters_names[@]}"; do
            printf '# %*s: %s\n' "${longest_parameter_length}" "${parameters_names[index]}" "${set_of_values[index]}"
        done
        printf '\n'
    } > "${filename}"
}

function __static__Add_YAML_Configuration_To_New_Configuration_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty parameters_names filename set_of_values
    local index yq_replacements
    for index in ${!parameters_names[@]}; do
        yq_replacements+="( .${parameters_names[index]} ) = ${set_of_values[index]} |"
    done
    yq "${yq_replacements%?}" "${HYBRID_configuration_file}" >> "${filename}"
}

function __static__Remove_Scan_Parameters_Key_From_New_Configuration_File()
{
    Ensure_That_Given_Variables_Are_Set_And_Not_Empty filename
    sed -i '/Scan_parameters/d' "${filename}"
}
