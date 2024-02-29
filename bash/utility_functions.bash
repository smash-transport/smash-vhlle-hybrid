#===================================================
#
#    Copyright (c) 2023-2024
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

# ATTENTION: Unless it makes sense to do it differently, each function here
#            should have a short documentation before and then be included in
#            the developer guide. Be consistent when adding a new function.
#            Here a simple bash trick is used: A no-operation ':' followed by
#            a here-doc is used to be able to put the markdown documentation
#            inside and still make this be ignored by the shell. In the here-doc
#            a couple of "snippet anchors" is used to be able to include the
#            snippets in the developer guide. Each snippet begins and ends with
#            '--8<-- [start:<label>]' and '--8<-- [end:<label>]', respectively.
#            The first snippet is for a short description of the function and
#            the second for a bash example of how to call it. If the snippets
#            are missing, then the function is documented differently.

: << 'DOCSTRING'
--8<-- [start:Element_In_Array_Equals_To-desc]
Test if an array contains a given element using string comparison.
The function returns 0 if the element is in the array, 1 otherwise.
--8<-- [end:Element_In_Array_Equals_To-desc]
--8<-- [start:Element_In_Array_Equals_To-ex]
if Element_In_Array_Equals_To 'element' "${array[@]}"; then
    # 'element' is in array
fi
--8<-- [end:Element_In_Array_Equals_To-ex]
DOCSTRING
function Element_In_Array_Equals_To()
{
    local element
    for element in "${@:2}"; do
        [[ "${element}" == "$1" ]] && return 0
    done
    return 1
}

: << 'DOCSTRING'
--8<-- [start:Element_In_Array_Matches-desc]
Test if an array contains a given element using regex comparison.
The function returns 0 if at least one element in the array matches the regular
expression, 1 otherwise.
--8<-- [end:Element_In_Array_Matches-desc]
--8<-- [start:Element_In_Array_Matches-ex]
if Element_In_Array_Matches '^file_[0-9]+' "${array[@]}"; then
    # array contains one entry matching the regex
fi
--8<-- [end:Element_In_Array_Matches-ex]
DOCSTRING
function Element_In_Array_Matches()
{
    local element
    for element in "${@:2}"; do
        [[ "${element}" =~ $1 ]] && return 0
    done
    return 1
}

: << 'DOCSTRING'
--8<-- [start:Has_YAML_String_Given_Key-desc]
Test if a YAML string contains a given key.
If the YAML string is invalid, an error is printed and the function exits.
The function returns 0 if the key is present in the YAML string, 1 otherwise.
--8<-- [end:Has_YAML_String_Given_Key-desc]
--8<-- [start:Has_YAML_String_Given_Key-ex]
yaml_string=$'section:\n  key: 42\n'
if Has_YAML_String_Given_Key "${yaml_string}" 'section' 'key'; then
    # this is executed
fi
--8<-- [end:Has_YAML_String_Given_Key-ex]
DOCSTRING
function Has_YAML_String_Given_Key()
{
    local yaml_string section key
    if [[ $# -lt 2 ]]; then
        Print_Internal_And_Exit 'Function ' --emph "${FUNCNAME}" ' called with less than 2 arguments.'
    fi
    yaml_string=$1
    shift
    if ! yq <<< "${yaml_string}" &> /dev/null; then
        Print_Internal_And_Exit 'Function ' --emph "${FUNCNAME}" ' called with invalid YAML string.'
    fi
    # Reset parameters letting word splitting split keys after having replaced periods by spaces.
    # This is needed to correctly deal with any possible way keys are passed to this function.
    set -- ${@//./ }
    section="$(printf '.%s' "${@:1:$#-1}")" # All arguments but last
    key=${@: -1}                            # Last argument
    if [[ $(yq "${section}"' | has("'"${key}"'")' <<< "${yaml_string}") = 'true' ]]; then
        return 0
    else
        return 1
    fi
}

: << 'DOCSTRING'
--8<-- [start:Read_From_YAML_String_Given_Key-desc]
Read a given key from a YAML string.
If the YAML string does not contain the key (or it is invalid) the function exits with an error.
The read key is printed to standard output.
--8<-- [end:Read_From_YAML_String_Given_Key-desc]
--8<-- [start:Read_From_YAML_String_Given_Key-ex]
yaml_string=$'section:\n  key: 42\n'
key_value=$(Read_From_YAML_String_Given_Key "${yaml_string}" 'section' 'key')
echo "${key_value}"  # <-- this prints '42'
key_value=$(Read_From_YAML_String_Given_Key "${yaml_string}" 'section.key')
echo "${key_value}"  # <-- this prints '42'
--8<-- [end:Read_From_YAML_String_Given_Key-ex]
DOCSTRING
function Read_From_YAML_String_Given_Key()
{
    local yaml_string key
    if [[ $# -lt 2 ]]; then
        Print_Internal_And_Exit 'Function ' --emph "${FUNCNAME}" ' called with less than 2 arguments.'
    elif ! Has_YAML_String_Given_Key "$@"; then
        Print_Internal_And_Exit 'Function ' --emph "${FUNCNAME}" ' called with YAML string not containing given key.'
    fi
    yaml_string=$1
    shift
    key="$(printf '.%s' "$@")"
    yq "${key}" <<< "${yaml_string}"
}

: << 'DOCSTRING'
--8<-- [start:Print_YAML_String_Without_Given_Key-desc]
Remove a given key from a YAML string.
If the YAML string does not contain the key (or it is invalid) the function exits with an error.
The new YAML string is printed to standard output.
--8<-- [end:Print_YAML_String_Without_Given_Key-desc]
--8<-- [start:Print_YAML_String_Without_Given_Key-ex]
yaml_string=$'a: 17\nb: 42\n'
yaml_string=$(Print_YAML_String_Without_Given_Key "${yaml_string}" 'b')
echo "${yaml_string}"  # <-- this prints 'a: 17'
--8<-- [end:Print_YAML_String_Without_Given_Key-ex]
DOCSTRING
function Print_YAML_String_Without_Given_Key()
{
    local yaml_string key
    if [[ $# -lt 2 ]]; then
        Print_Internal_And_Exit 'Function ' --emph "${FUNCNAME}" ' called with less than 2 arguments.'
    elif ! Has_YAML_String_Given_Key "$@"; then
        Print_Internal_And_Exit 'Function ' --emph "${FUNCNAME}" ' called with YAML string not containing given key.'
    fi
    yaml_string=$1
    shift
    key="$(printf '.%s' "$@")"
    yq 'del('"${key}"')' <<< "${yaml_string}"
}

: << 'DOCSTRING'
--8<-- [start:Print_Line_of_Equals-desc]
Print a lines of equals to the standard output.
Function interface:

1. Length in characters of the line.
2. Prefix to be printed before the line (optional, default: `''`).
3. Postfix to be printed after the line (optional, default: `'\n'`).
--8<-- [end:Print_Line_of_Equals-desc]
--8<-- [start:Print_Line_of_Equals-ex]
Print_Line_of_Equals 80 '\e[96m    ' '\e[0m\n'
--8<-- [end:Print_Line_of_Equals-ex]
DOCSTRING
function Print_Line_of_Equals()
{
    local length indentation prefix postfix
    length="$1"
    prefix="${2-}"    # Input arg. or empty string
    postfix="${3-\n}" # Input arg. or endline
    printf "${prefix}"
    for ((i = 0; i < ${length}; i++)); do
        printf '='
    done
    printf "${postfix}"
}

: << 'DOCSTRING'
--8<-- [start:Print_Centered_Line-desc]
Print a string horizontally centered in the terminal or in the provided length.
Function interface:

1. String to be printed.
2. Length in characters of the line (optional, default: terminal width).
3. Prefix to be printed before the line (optional, default: `''`).
4. Padding character to fill the line left and right of the string (optional, default: `' '`).
5. Postfix to be printed after the line (optional, default: `'\n'`).
--8<-- [end:Print_Centered_Line-desc]
--8<-- [start:Print_Centered_Line-ex]
Print_Centered_Line 'Hello world!' 80 '\e[96m    ' '=' '\e[0m\n'
--8<-- [end:Print_Centered_Line-ex]
DOCSTRING
function Print_Centered_Line()
{
    local input_string output_total_width indentation padding_character \
        postfix real_length padding_utility
    input_string="$1"
    output_total_width="${2:-$(tput cols)}" # Input arg. or full width of terminal
    indentation="${3-}"                     # Input arg. or empty string
    padding_character="${4:- }"             # Input arg. or single space
    postfix="${5-\n}"                       # Input arg. or endline
    # Determine length of input at net of formatting codes (color, face)
    real_length=$(printf '%s' "${input_string}" | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g" | wc -c)
    if ((output_total_width - 2 - real_length < 0)); then
        Print_Fatal_And_Exit 'Error in ' --emph "${FUNCNAME}" ': specify larger total width!'
    fi
    # In the following we build a very long string of padding characters that
    # will be later truncated when printing the output string. Very long is
    # here 500 characters. The * in a string format descriptor of printf means
    # that the number to be used there is passed to printf as argument.
    padding_utility="$(printf '%0.1s' "${padding_character}"{1..500})"
    printf "${indentation}%0.*s %s %0.*s${postfix}" \
        "$(((output_total_width - 2 - real_length) / 2))" \
        "${padding_utility}" \
        "${input_string}" \
        "$(((output_total_width - 2 - real_length) / 2))" \
        "${padding_utility}"
}

: << 'DOCSTRING'
--8<-- [start:Print_Option_Specification_Error_And_Exit-desc]
Print a fatal error about the given option using the logger and exits.
--8<-- [end:Print_Option_Specification_Error_And_Exit-desc]
--8<-- [start:Print_Option_Specification_Error_And_Exit-ex]
Print_Option_Specification_Error_And_Exit '--filename'
--8<-- [end:Print_Option_Specification_Error_And_Exit-ex]
DOCSTRING
function Print_Option_Specification_Error_And_Exit()
{
    exit_code=${HYBRID_fatal_command_line} Print_Fatal_And_Exit \
        'The value of the option ' --emph "$1" ' was not correctly specified (either forgotten or invalid)!'
}

: << 'DOCSTRING'
--8<-- [start:Print_Not_Implemented_Function_Error-desc]
Print an error about the caller function using the logger.
--8<-- [end:Print_Not_Implemented_Function_Error-desc]
--8<-- [start:Print_Not_Implemented_Function_Error-ex]
Print_Not_Implemented_Function_Error
--8<-- [end:Print_Not_Implemented_Function_Error-ex]
DOCSTRING
function Print_Not_Implemented_Function_Error()
{
    Print_Error 'Function ' --emph "${FUNCNAME[1]}" ' not implemented yet, skipping it.'
}

: << 'DOCSTRING'
--8<-- [start:Remove_Comments_In_File-desc]
Remove comments starting with a given character (default `'#'`) in a given file.
In particular:

* Entire lines starting with a comment (possibly with leading spaces) are removed.
* Inline comments with any space before them are removed.

!!! danger "Think before using this function!"
    This function considers as comments anything coming after _any_ occurrence of
    the specified comment character and **you should not use it if there might
    be occurrences of that character that do not start a comment!**
    For the hybrid handler configuration such a basic implementation is enough.
--8<-- [end:Remove_Comments_In_File-desc]
--8<-- [start:Remove_Comments_In_File-ex]
Remove_Comments_In_File 'config.yaml'
Remove_Comments_In_File 'doc.tex' '%'
--8<-- [end:Remove_Comments_In_File-ex]
DOCSTRING
function Remove_Comments_In_File()
{
    local filename comment_character
    filename=$1
    comment_character=${2:-#}
    if [[ ! -f "${filename}" ]]; then
        exit_code=${HYBRID_fatal_file_not_found} Print_Fatal_And_Exit \
            'File ' --emph "${filename}" ' not found.'
    elif [[ ${#comment_character} -ne 1 ]]; then
        Print_Internal_And_Exit 'Comment character ' --emph "${comment_character}" ' invalid!'
    else
        sed -i '/^[[:blank:]]*'"${comment_character}"'/d;s/[[:blank:]]*'"${comment_character}"'.*//' "${filename}"
    fi
}

: << 'DOCSTRING'
--8<-- [start:Strip_ANSI_Color_Codes_From_String-desc]
Remove ANSI color codes from the given string.
The cleaned up string is printed to standard output.
--8<-- [end:Strip_ANSI_Color_Codes_From_String-desc]
--8<-- [start:Strip_ANSI_Color_Codes_From_String-ex]
Strip_ANSI_Color_Codes_From_String $'\e[96mHi\e[0m' # <-- this prints 'Hi'
--8<-- [end:Strip_ANSI_Color_Codes_From_String-ex]
DOCSTRING
function Strip_ANSI_Color_Codes_From_String()
{
    # Adjusted from https://stackoverflow.com/a/18000433/14967071
    sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g" <<< "$1"
}

#-------------------------------------------------------------------------------
# NOTE: Refer to the developer guide for information about these functions
function Ensure_Given_Files_Do_Not_Exist()
{
    __static__Check_Given_Files_With '-f' 'FATAL' "$@"
}

function Ensure_Given_Files_Exist()
{
    __static__Check_Given_Files_With '! -f' 'FATAL' "$@"
}

function Ensure_Given_Folders_Do_Not_Exist()
{
    __static__Check_Given_Files_With '-d' 'FATAL' "$@"
}

function Ensure_Given_Folders_Exist()
{
    __static__Check_Given_Files_With '! -d' 'FATAL' "$@"
}

function Internally_Ensure_Given_Files_Do_Not_Exist()
{
    __static__Check_Given_Files_With '-f' 'INTERNAL' "$@"
}

function Internally_Ensure_Given_Files_Exist()
{
    __static__Check_Given_Files_With '! -f' 'INTERNAL' "$@"
}

# Since the few functions above differ in small aspects, it is possible to have
# a core common implementation. The following static function takes:
#   $1     -> the test operator to be used in [[ ... ]] keyword
#   $2     -> whether to print a fatal or an internal error
#   ${@:3} -> the names of the files to be tested.
#
# NOTE: If among the names of the files the argument '--' is used, then
#       this is ignored and the arguments before are an add on message to
#       be printed in case of error (one argument per line).
function __static__Check_Given_Files_With()
{
    local -r test_to_use=$1 error=$2
    shift 2
    local add_on_message list_of_files negations string filename
    add_on_message=()
    if Element_In_Array_Equals_To '--' "$@"; then
        for string in "$@"; do
            if [[ "${string}" = '--' ]]; then
                shift
                break
            fi
            add_on_message+=("$1")
            shift
        done
    fi
    list_of_files=()
    string='The following'
    case "${test_to_use}" in
        -f)
            negations=('' 'NOT ')
            string+=' file'
            ;;
        "! -f")
            negations=('NOT ' '')
            string+=' file'
            ;;
        -d)
            negations=('' 'NOT ')
            string+=' folder'
            ;;
        "! -d")
            negations=('NOT ' '')
            string+=' folder'
            ;;
        *)
            Print_Internal_And_Exit 'Wrong test passed to ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
    case "${error}" in
        FATAL | INTERNAL) ;;
        *)
            Print_Internal_And_Exit 'Wrong error passed to ' --emph "${FUNCNAME}" ' function.'
            ;;
    esac
    for filename in "$@"; do
        # NOTE: In the following if-clause the [ test command is used and not the [[
        #       keyword because then it is possible to use the operator stored in the
        #       test_to_use variable (keywords are parsed before expanding arguments).
        if [ ${test_to_use} "$(realpath -m "${filename}")" ]; then
            list_of_files+=("${filename}")
        fi
    done
    case ${#list_of_files[@]} in
        0)
            return
            ;;
        1)
            string+=" was ${negations[0]}found but is expected ${negations[1]}to exist:"
            ;;
        *)
            string+="s were ${negations[0]}found but are expected ${negations[1]}to exist:"
            ;;
    esac
    Print_Error "${string}"
    for filename in "${list_of_files[@]}"; do
        Print_Error -l -- ' - ' --emph "${filename}"
    done
    if [[ "${#add_on_message[@]}" -ne 0 ]]; then
        Print_Error -l -- "${add_on_message[@]}"
    fi
    if [[ "${error}" = 'INTERNAL' ]]; then
        Print_Internal_And_Exit '\nThis should not have happened.'
    else
        exit_code=${HYBRID_fatal_logic_error} Print_Fatal_And_Exit \
            '\nUnable to continue.'
    fi
}
#-------------------------------------------------------------------------------

: << 'DOCSTRING'
--8<-- [start:Call_Function_If_Existing_Or_Exit-desc]
Check if the given function exists and if so call it forwarding all arguments.
Exit with an internal error otherwise.
--8<-- [end:Call_Function_If_Existing_Or_Exit-desc]
--8<-- [start:Call_Function_If_Existing_Or_Exit-ex]
# These two are equivalent if the function 'Mystery_Function' is defined
Call_Function_If_Existing_Or_Exit 'Mystery_Function' 'Arg_1' 'Arg_2' 'Arg_3'
Mystery_Function 'Arg_1' 'Arg_2' 'Arg_3'
--8<-- [end:Call_Function_If_Existing_Or_Exit-ex]
DOCSTRING
function Call_Function_If_Existing_Or_Exit()
{
    local name_of_the_function=$1
    shift
    if [[ "$(type -t ${name_of_the_function})" = 'function' ]]; then
        ${name_of_the_function} "$@"
    else
        exit_code=${HYBRID_fatal_missing_feature} Print_Internal_And_Exit \
            '\nFunction ' --emph "${name_of_the_function}" ' not found!' \
            'Please provide an implementation following the in-code documentation.'
    fi
}

: << 'DOCSTRING'
--8<-- [start:Call_Function_If_Existing_Or_No_Op-desc]
Check if the given function exists and if so call it forwarding all arguments.
This is a no-operation if the function is not defined.
--8<-- [end:Call_Function_If_Existing_Or_No_Op-desc]
--8<-- [start:Call_Function_If_Existing_Or_No_Op-ex]
# These two are equivalent if the function 'Mystery_Function' is defined
Call_Function_If_Existing_Or_No_Op 'Mystery_Function' 'Arg_1' 'Arg_2' 'Arg_3'
Mystery_Function 'Arg_1' 'Arg_2' 'Arg_3'
--8<-- [end:Call_Function_If_Existing_Or_No_Op-ex]
DOCSTRING
function Call_Function_If_Existing_Or_No_Op()
{
    local name_of_the_function=$1
    shift
    if [[ "$(type -t ${name_of_the_function})" = 'function' ]]; then
        ${name_of_the_function} "$@"
    fi
}

: << 'DOCSTRING'
--8<-- [start:Ensure_That_Given_Variables_Are_Set-desc]
Check if the given variables are set, i.e. have been declared.
Exit with an internal error if at least one variable is not set.
--8<-- [end:Ensure_That_Given_Variables_Are_Set-desc]
--8<-- [start:Ensure_That_Given_Variables_Are_Set-ex]
Ensure_That_Given_Variables_Are_Set 'var_1' 'var_2' 'var_3'
--8<-- [end:Ensure_That_Given_Variables_Are_Set-ex]
DOCSTRING
function Ensure_That_Given_Variables_Are_Set()
{
    # NOTE: In Bash there are several ways to declare variables and somehow these are
    #       (apparently) not consistent w.r.t. the variable resulting set when tested via
    #       [[ -v ... ]] and therefore here we decided to also use the 'declare' command.
    #       For example, 'local foo' is not setting a variable (the -v test fails, which
    #       makes sense). However, also 'foo=()' is not setting the array variable
    #       which is not what we want here. In this function "set" means DECLARED IN
    #       SOME WAY and 'foo=()' should not result in an error. On the other hand,
    #       if this function is used to test existence of an entry of an array, then
    #       'declare -p array[0]' would fail even if array[0] existed, while the test
    #       [[ -v array[0] ]] would succeed. Hence we treat this case separately.
    local variable_name
    for variable_name in "$@"; do
        if ! declare -p "${variable_name}" &> /dev/null; then
            if [[ ${variable_name} =~ \]$ && -v ${variable_name} ]]; then
                continue
            fi
            Print_Internal_And_Exit \
                'Variable ' --emph "${variable_name}" ' not set in function ' --emph "${FUNCNAME[1]}" '.'
        fi
    done
}

: << 'DOCSTRING'
--8<-- [start:Ensure_That_Given_Variables_Are_Set_And_Not_Empty-desc]
Check if the given variables are set and not empty.
Exit with an internal error if at least one variable is not set or set but empty.

??? question "What does empty mean?"
    A normal variable is empty if it is set to `''`.
    An array is considered empty if it has size equal to 0.
--8<-- [end:Ensure_That_Given_Variables_Are_Set_And_Not_Empty-desc]
--8<-- [start:Ensure_That_Given_Variables_Are_Set_And_Not_Empty-ex]
Ensure_That_Given_Variables_Are_Set_And_Not_Empty 'var_1' 'var_2' 'var_3'
--8<-- [end:Ensure_That_Given_Variables_Are_Set_And_Not_Empty-ex]
DOCSTRING
function Ensure_That_Given_Variables_Are_Set_And_Not_Empty()
{
    # NOTE: See Ensure_That_Given_Variables_Are_Set comment. Moreover, since we indirectly
    #       access the variable through its name, we need to check separately the case
    #       in which the variable is an array. In bash, the "array length" of a non-array
    #       variable is 1 (as accessing an array without index returns the first entry).
    #       Hence, for 'foo=""', ${#foo[@]} would return 1 and a non zero length is not
    #       synonym of a non-empty variable.
    local variable_name
    for variable_name in "$@"; do
        # The following can be done using the "${ref@A}" bash-5 expansion which
        # would return the variable declared attributes (e.g. 'a' for arrays).
        if [[ $(declare -p "${variable_name}" 2> /dev/null) =~ ^declare\ -[aA] ]]; then
            declare -n ref=${variable_name}
            set +u # Here 'ref' might be unset for empty associative arrays! Do not exit if so
            if [[ ${#ref[@]} -ne 0 ]]; then
                set -u
                continue
            fi
            set -u
        else
            set +u # Here 'variable_name' might be unset! Do not exit if so
            if [[ "${!variable_name}" != '' ]]; then
                set -u
                continue
            fi
            set -u
        fi
        Print_Internal_And_Exit \
            'Variable ' --emph "${variable_name}" ' unset or empty in function ' --emph "${FUNCNAME[1]}" '.'
    done
}

: << 'DOCSTRING'
--8<-- [start:Make_Functions_Defined_In_This_File_Readonly-desc]
Extract all functions defined in the file where called and mark them as `readonly`.

!!! warning "An important assumption"
    Only functions defined as `#!bash function Name_Of_The_Function()` and the
    braces on new lines are recognized.
    Accepted symbols in the function name are letters, `_`, `:` and `-`.
--8<-- [end:Make_Functions_Defined_In_This_File_Readonly-desc]
--8<-- [start:Make_Functions_Defined_In_This_File_Readonly-ex]
Make_Functions_Defined_In_This_File_Readonly
--8<-- [end:Make_Functions_Defined_In_This_File_Readonly-ex]
DOCSTRING
function Make_Functions_Defined_In_This_File_Readonly()
{
    # Make this function a no-op if sed or grep are not available, so that
    # the system-requirements check does not weirdly fail in those cases just
    # because this function is called when sourcing the files at the end.
    if ! hash sed &> /dev/null || ! hash grep &> /dev/null; then
        return
    fi
    # Here we assume all functions are defined with the same stile,
    # including empty parentheses and the braces on new lines! I.e.
    #
    #    function nameOfTheFunction()
    #
    # Accepted symbols in function name: letters, '_', ':' and '-'
    #
    # NOTE: The file from which this function is called is ${BASH_SOURCE[1]}
    local declared_functions
    declared_functions=( # Here word splitting can split names, no space allowed in function name!
        $(grep -E '^[[:space:]]*function[[:space:]]+[-[:alnum:]_:]+\(\)[[:space:]]*$' "${BASH_SOURCE[1]}" \
            | sed -E 's/^[[:space:]]*function[[:space:]]+([^(]+)\(\)[[:space:]]*$/\1/')
    )
    if [[ ${#declared_functions[@]} -eq 0 ]]; then
        Print_Internal_And_Exit \
            'Function ' --emph "${FUNCNAME}" ' called, but no function found in file\n file ' \
            --emph "${BASH_SOURCE[1]}" '.'
    else
        readonly -f "${declared_functions[@]}"
    fi
}

Make_Functions_Defined_In_This_File_Readonly
