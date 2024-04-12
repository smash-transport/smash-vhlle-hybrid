# Bash utility functions

:simple-gnubash: Bash world is often the realm of the **do it yourself**. :innocent:
This is belonging to the nature of the language as it is very unusual to have libraries with functionality to be reused.
However, it is very simple to provide the codebase with some utility function tailored on the needs of the project.
In the following you will find an overview of what is available in the codebase.

!!! warning "These functions are tailored on the project"
    The following functions should not be considered as a library.
    Actually most of them would not work if copied and pasted in another project.
    Be aware that some of them depend on project-specific aspects (e.g. they use the logger or they assume that the shell used options are on) and, sometimes, make use of other utility functions.

!!! tip "Mimicking boolean functions"
    In Bash conditionals are based on exit codes of commands and therefore a function which returns either 0 (success) or 1 (failure) can directly be used in a conditional clause, e.g. a `if` statement.
    When the function returns 0, the condition will be evaluated as true, and when the function returns 1, the condition will be evaluated as false.

## Array utilities

??? utility-func "`Element_In_Array_Equals_To`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Element_In_Array_Equals_To-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Element_In_Array_Equals_To-ex"
        ```

??? utility-func "`Element_In_Array_Matches`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Element_In_Array_Matches-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Element_In_Array_Matches-ex"
        ```

## Variables- and functions-related utilities

??? utility-func "`Call_Function_If_Existing_Or_Exit`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Call_Function_If_Existing_Or_Exit-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Call_Function_If_Existing_Or_Exit-ex"
        ```

??? utility-func "`Call_Function_If_Existing_Or_No_Op`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Call_Function_If_Existing_Or_No_Op-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Call_Function_If_Existing_Or_No_Op-ex"
        ```

??? utility-func "`Ensure_That_Given_Variables_Are_Set`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Ensure_That_Given_Variables_Are_Set-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Ensure_That_Given_Variables_Are_Set-ex"
        ```

??? utility-func "`Ensure_That_Given_Variables_Are_Set_And_Not_Empty`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Ensure_That_Given_Variables_Are_Set_And_Not_Empty-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Ensure_That_Given_Variables_Are_Set_And_Not_Empty-ex"
        ```

??? utility-func "`Make_Functions_Defined_In_This_File_Readonly`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Make_Functions_Defined_In_This_File_Readonly-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Make_Functions_Defined_In_This_File_Readonly-ex"
        ```

??? utility-func "`Print_Not_Implemented_Function_Error`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Print_Not_Implemented_Function_Error-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Print_Not_Implemented_Function_Error-ex"
        ```

## YAML related utilities

!!! info "All functions have the same interface"
    The following functions need to be called with the YAML string as first argument and the section key(s) as remaining argument(s).
    As it is assumed everywhere that no key contains a period (or a space), keys can be passed to this function also already concatenated (or in a mixed way).

??? utility-func "`Has_YAML_String_Given_Key`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Has_YAML_String_Given_Key-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Has_YAML_String_Given_Key-ex"
        ```

??? utility-func "`Read_From_YAML_String_Given_Key`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Read_From_YAML_String_Given_Key-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Read_From_YAML_String_Given_Key-ex"
        ```

??? utility-func "`Print_YAML_String_Without_Given_Key`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Print_YAML_String_Without_Given_Key-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Print_YAML_String_Without_Given_Key-ex"
        ```

## Output utilities

??? utility-func "`Print_Line_of_Equals`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Print_Line_of_Equals-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Print_Line_of_Equals-ex"
        ```

??? utility-func "`Print_Centered_Line`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Print_Centered_Line-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Print_Centered_Line-ex"
        ```

## File utilities

??? utility-func "`Remove_Comments_In_File`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Remove_Comments_In_File-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Remove_Comments_In_File-ex"
        ```

???+ utility-func "Functions to ensure presence or absence of files or folders"
    There are some functions that add a level of abstraction to testing for file or folders existence or absence.
    Their interface has been unified.
    In particular, the arguments are interpreted as file or folder names and each is tested.
    However, if an argument is `--`, then the arguments before it are interpreted as add-on message to be printed in case of error (one per line).

    * `Ensure_Given_Files_Do_Not_Exist`
    * `Ensure_Given_Files_Exist`
    * `Ensure_Given_Folders_Do_Not_Exist`
    * `Ensure_Given_Folders_Exist`
    * `Internally_Ensure_Given_Files_Do_Not_Exist`
    * `Internally_Ensure_Given_Files_Exist`

    The last ones fail with an internal error instead of a normal fatal one.
    Note that symbolic links are accepted as arguments and the entity of what they resolve to is tested.
    Links resolution is done using `realpath -m` before testing the entity (the option `-m` accepts non existing paths).

## Miscellaneous

??? utility-func "`Strip_ANSI_Color_Codes_From_String`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Strip_ANSI_Color_Codes_From_String-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Strip_ANSI_Color_Codes_From_String-ex"
        ```

??? utility-func "`Print_Option_Specification_Error_And_Exit`"
    === "Description"
        --8<-- "bash/utility_functions.bash:Print_Option_Specification_Error_And_Exit-desc"
    === "Call example"
        ```bash
        --8<-- "bash/utility_functions.bash:Print_Option_Specification_Error_And_Exit-ex"
        ```
