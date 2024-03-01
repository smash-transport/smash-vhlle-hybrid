# Contributing to SMASH-vHLLE-Hybrid

If you landed here, you might be thinking of contributing to the codebase: **Excellent decision!** :upside_down_face:

As an external contributor, fork the repository, work on a branch dedicated to your changes and then create a pull request.
Details on this workflow can be found e.g. [here](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project).

In any case, before starting editing code, take few minutes to go through the following recommendations.
It will speed up the code review and avoid comments about codebase notation.

!!! note "Write tests first"
    The project has been started with the goal of making every developer fearless in changing and improve the code.
    Such a confidence can only be attained if the developer can be confident that their changes are not breaking existing functionality.
    Sounds like magic?
    No, it simply means that there are tests for basically every functionality. :innocent:
    You are requested to stick to this exciting aspect and, possibly, device and why not write tests for your new code before implementing the code itself.
    A sufficiently handy testing framework has been developed tailored on this project and you find the needed information about it in a dedicated page [:material-arrow-right-box: testing framework](testing_framework.md).
    **The basic idea is that adding new tests is as simple as adding a new function.**

!!! warning "It's a Bash project!"
    Use the `.bash` extension (**NOT** `.sh`) for files containing *Bash* code.
    This is often ignored in shell scripting.

## Editing existing files or creating new ones

This codebase is distributed under the terms of the GPLv3 license.
In general, you should follow the instructions therein.
Some guidance for authors is also provided here, in order to reach a coherent style of copyright and licensing notices.

!!! info "Getting started working on the project"
    * If you are contributing for the first time, be sure that your git username and email are [set up correctly](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup).
    To check them you can run `git config --list` and see the values of the `user.name` and `user.email` fields.
    Add yourself to the AUTHORS file (you find this at the top-level of the repository).
    * If you create a new file, add copyright and license remarks to a comment at the top of the file (after a possible shebang).
    This should read like
    ```bash
    #===================================================
    #
    #    Copyright (c) 2024
    #      SMASH Hybrid Team
    #
    #    GNU General Public License (GPLv3 or later)
    #
    #===================================================
    ```
    **with the correct development year**.
    * When editing an existing file, ensure there is the current year in the copyright line.
    The years should form a comma-separated list.
    If two subsequent years or more are given, the list can be merged into a range.

### Hooks and good commits

In order to e.g. avoid to forget to update the copyright statement, git hooks can be used to perform some checks at commit time.
You can implement them in your favorite language or look for some on the web.
We encourage you to checkout and use the [:material-arrow-right-box: GitHooks](https://github.com/AxelKrypton/GitHooks) which will also enforce good habits about how to structure your commit messages, as well as sanitize white spaces in source code. :sunglasses:
Please, refer to their README file for more information.


## Used Bash behavior

After long consideration, it has been decided to use some stricter Bash mode.
In particular, the harmless `pipefail`, `nounset` and `extglob` options are enabled, together with the more controversial `errexit` one (and its sibling `inherit_errexit`).
We are aware that the `errexit` option leads to many corner cases and that there are controversial opinions around.
The advantage is its useful semantics and, more importantly, it can protect from dangerous situations (`cd NotExistingFolder; rm -r *`).
But beware of possible gotchas.
Of course, a proper error handling would be even better.
Considering that even more inexperienced developers might contribute to the project and miss some error handling (and, by the way, oversight is always possible), we still decided to let the shell abort on error, accepting to deal with all possible downsides this feature has.

Finally, a short remark about `extglob` option. To motivate why we decided to enable it globally, it is best to quote [Greg's wiki](http://mywiki.wooledge.org/glob):
> **`extglob` changes the way certain characters are parsed. It is necessary to have a newline (not just a semicolon) between `shopt -s extglob` and any subsequent commands to use it.**
> You cannot enable extended globs inside a group command that uses them, because the entire block is parsed before the `shopt` is _evaluated_.
> Note that the typical function body is a _group command_.
> An unpleasant workaround could be to use a _subshell command_ list as the function body.


## Bash notation in the codebase

The general advice is pretty trivial: **Be consistent with what you find**.

The codebase is formatted using [`shfmt`](https://github.com/mvdan/sh#shfmt).
Any developer should be aware that, because of the nature of the Bash scripting language, it is probably impossible to have a perfect formatter, which ensure rules in all details (as e.g. `clang-format` does for C++).
Therefore, it is crucial for the developer to stay consistent with the existing style and, more importantly, to take some minutes to read the following lists.
In particular, be aware the the formatter will not enforce the rules explained below.

!!! tip "The main hybrid handler script can format the codebase!"
    Before opening a PR, make sure all tests pass.
    One of them will try to check formatting and complain if something has to be adjusted.
    The main script has a `format` execution mode which formats the full codebase and runs the formatting unit test.
    This is meant for developers only and therefore does not appear in the helper description.

!!! info "Some aspects about the codebase"
    * Lines of code are split around 100 characters and should never be longer than 120.
      This is a hard limit and tests will fail if longer lines exist.
    * Bash functions use **both** the `function` keyword **and** parenthesis (with the enclosing braces on separate lines).
    ```bash
    function Example_Function()
    {
        # Body of the function
    }
    ```
    * Local variables are typed with all small letters and words separated by underscores, e.g. `local_variable_name`.
    * Global variables in the codebase are prefixed by `HYBRID_` and this is meant for better readability, e.g. `HYBRID_global_variable`.
    * Analogously, global variables in tests are prefixed by `HYBRIDT_`.
    * Variables are always expanded using braces, i.e. you should use `${variable}` instead of `$variable`.
    * Function names are made of underscore-separated words with initials capitalized, e.g. `Function_Name_With_Words`.
    * Functions that are and should be used only in the file where declared are prefixed by `__static__`.
    * Quotes are correctly used, i.e. everything that _might_ break if unquoted is quoted.
    * Single quotes are used if there is no need of using double or different quotes.
    * All functions declared in each separate file are marked in the end of the file as `readonly`.
      This is done calling the `Make_Functions_Defined_In_This_File_Readonly` function.
      This does not apply to the code in the :file_folder: **tests** folder.
    * Files are sourced all together by sourcing a single dedicated file (cf. :material-file: *bash/source_codebase_files.bash* file).

    **Other conventions in use that the formatter enforces**

    * Indentation is done _exclusively with spaces_ and **no** <kbd>Tab</kbd> should be used.
    * Loops and conditional clauses are started on a single line, i.e. the `do` and `then` keywords are **NOT** put on a separate line.
