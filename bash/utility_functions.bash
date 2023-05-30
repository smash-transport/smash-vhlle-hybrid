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

function Print_Not_Implemented_Function_Error()
{
    Print_Error "Function \"${FUNCNAME[1]}\" not implemented yet, skipping it."
}

function Remove_Comments_In_File()
{
    # NOTE: This function considers as comments anything coming after ANY occurrence of
    #       the specified comment character and you should not use it if there might
    #       be occurrences of that character that do not start a comment!
    #        1) Entire lines starting with a comment (possibly with leading spaces) are removed
    #        2) Inline comments with any space before them are removed
    local filename comment_character
    filename=$1
    comment_character=${2:-#}
    if [[ ! -f ${filename} ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit\
            "File \"${filename}\" not found."
    elif [[ ${#comment_character} -ne 1 ]]; then
        Print_Internal_And_Exit "Comment character \"${comment_character}\" invalid!"
    else
        sed -i '/^[[:blank:]]*'"${comment_character}"'/d;s/[[:blank:]]*'"${comment_character}"'.*//' "${filename}"
    fi
}

function Call_Function_If_Existing_Or_Exit()
{
    local name_of_the_function=$1
    shift
    if [[ "$(type -t ${name_of_the_function})" = 'function' ]]; then
        # Return value propagates automatically since a function returns the last exit code.
        # However, when exit on error behavior is active, the script would terminate here if
        # the function returns non-zero exit code and, instead we want this propagate up!
        ${name_of_the_function} "$@" || return $?
    else
        exit_code=${HYBRID_fatal_missing_feature} Print_Internal_And_Exit\
            "\nFunction \"${name_of_the_function}\" not found!"\
            "Please provide an implementation following the in-code documentation."
    fi
}

function Call_Function_If_Existing_Or_No_Op()
{
    local name_of_the_function=$1
    shift
    if [[ "$(type -t ${name_of_the_function})" = 'function' ]]; then
        # See 'Call_Function_If_Existing_Or_Exit' for more information about 'return $?'
        ${name_of_the_function} "$@" || return $?
    fi
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
