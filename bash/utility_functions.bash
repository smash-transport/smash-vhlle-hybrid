#===================================================
#
#    Copyright (c) 2023
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

function Element_In_Array_Equals_To()
{
    local element
    for element in "${@:2}"; do
        [[ "${element}" == "$1" ]] && return 0
    done
    return 1
}

function Element_In_Array_Matches()
{
    local element
    for element in "${@:2}"; do
        [[ "${element}" =~ $1 ]] && return 0
    done
    return 1
}

function Print_Line_of_Equals()
{
    local length indentation prefix postfix
    length="$1"
    indentation="${2-}"  # Input arg. or empty string
    prefix="${3-}"       # Input arg. or empty string
    postfix="${4-\n}"    # Input arg. or endline
    printf "${prefix}${indentation}"
    for ((i = 0; i < ${length}; i++)); do
        printf '='
    done
    printf "${postfix}"
}

function Print_Centered_Line()
{
    local input_string output_total_width indentation padding_character\
          postfix real_length padding_utility
    input_string="$1"
    output_total_width="${2:-$(tput cols)}" # Input arg. or full width of terminal
    indentation="${3-}"                     # Input arg. or empty string
    padding_character="${4:- }"             # Input arg. or single space
    postfix="${5-\n}"                       # Input arg. or endline
    # Determine length of input at net of formatting codes (color, face)
    real_length=$(printf '%s' "${input_string}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g" | wc -c)
    if (( output_total_width - 2 - real_length < 0 )); then
        Print_Fatal_And_Exit "Error in \"${FUNCNAME}\": specify larger total width!"
    fi
    # In the following we build a very long string of padding characters that
    # will be later truncated when printing the output string. Very long is
    # here 500 characters. The * in a string format descriptor of printf means
    # that the number to be used there is passed to printf as argument.
    padding_utility="$(printf '%0.1s' "${padding_character}"{1..500})"
    printf "${indentation}%0.*s %s %0.*s${postfix}"\
           "$(( (output_total_width - 2 - real_length)/2 ))"\
           "${padding_utility}"\
           "${input_string}"\
           "$(( (output_total_width - 2 - real_length)/2 ))"\
           "${padding_utility}"
}


function Make_Functions_Defined_In_This_File_Readonly()
{
    # Here we assume all functions are defined with the same stile,
    # including empty parenteses and the braces on new lines! I.e.
    #
    #    function nameOfTheFunction()
    #
    # Accepted symbols in function name: letters, '_', ':' and '-'
    #
    # NOTE: The file from which this function is called is ${BASH_SOURCE[1]}
    local declared_functions
    declared_functions=( # Here word splitting can split names, no space allowed in function name!
        $(grep -E '^[[:space:]]*function[[:space:]]+[-[:alnum:]_:]+\(\)[[:space:]]*$' "${BASH_SOURCE[1]}" |\
           sed -E 's/^[[:space:]]*function[[:space:]]+([^(]+)\(\)[[:space:]]*$/\1/')
    )
    if [[ ${#declared_functions[@]} -eq 0 ]]; then
        Print_Internal_And_Exit\
            "Function \"${FUNCNAME}\" called, but no function found in file\n file \"${BASH_SOURCE[1]}\""
    else
        readonly -f "${declared_functions[@]}"
    fi
}


Make_Functions_Defined_In_This_File_Readonly
