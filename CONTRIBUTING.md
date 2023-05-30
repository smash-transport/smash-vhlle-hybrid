# Contributing to SMASH-vHLLE-Hybrid

If you are reading this, you might be thinking of contributing to the codebase: Excellent decision! :upside_down_face:

As an external contributor, go fork the repository, work on a branch dedicated to your changes and then create a pull request. Details on this workflow can be found e.g. [here](https://git-scm.com/book/en/v2/GitHub-Contributing-to-a-Project).

In any case, before starting editing code, take few minutes to go through the following recommendations.
It will speed up the code review and avoid comments about codebase notation.


## Editing existing files or creating new ones

This codebase is distributed under the terms of the GPLv3 license.
In general, you should follow the instructions therein.
Some guidelines for authors are provided in the following, in order to reach a coherent style of copyright and licensing notices.

* If you are contributing for the first time, be sure that your git username and email are [set up correctly](https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup).
  To check them you can run `git config --list` and see the values of the `user.name` and `user.email` fields.
  Add yourself to the [AUTHORS](AUTHORS.md) file.
* If you create a new file, add copyright and license remarks to a comment at the top of the file (after a possible shebang).
  This should read like
  ```bash
  #===================================================
  #
  #    Copyright (c) 2023
  #      SMASH Hybrid Team
  #
  #    GNU General Public License (GPLv3 or later)
  #
  #===================================================
  ```
  with the correct development year.
  Use the `.bash` extension (**NOT** `.sh`) for files containing *bash* code.
* When editing an existing file, ensure there is the current year in the copyright line.
  The years should form a comma-separated list.
  If two subsequent years or more are given, the list can be merged into a range.

### Hooks and good commits

In order to e.g. avoid to forget to update the copyright statement, git hooks can be used to perform some checks at commit time.
You can implement them in your favorite language or look for some on the web.
We encourage you to checkout and use the [**GitHooks**](https://github.com/AxelKrypton/GitHooks) which will also enforce good habits about how to structure your commit messages, as well as sanitize white spaces in source code.
Please, refer to their README file for more information.


## Used bash behavior

After long consideration, it has been decided to use some stricter bash mode.
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
Here a list of some aspects worth mentioning:
* indentation is done _exclusively with spaces_ and **no** <kbd>Tab</kbd> should be used;
* lines of code are split around 100 characters and should never be longer than 120;
* bash functions use both the `function` keyword and parenthesis and the enclosing braces are put on separate lines,
  ```bash
  function Example_Function()
  {
    # Body of the function
  }
  ```
* loops and conditional clauses are started on a single line, i.e. the `do` and `then` keywords are **NOT** put on a separate line;
* local variables are typed with all small letters and words separated by underscores, e.g. `local_variable_name`;
* global variables in the codebase are prefixed by `HYBRID_` and this is meant for better readability, e.g. `HYBRID_global_variable`;
* analogously, global variables in tests are prefixed by `HYBRIDT_`;
* variables are always expanded using braces, i.e. you should use `${variable}` instead of `$variable`;
* function names are made of underscore-separated words with initials capitalized, e.g. `Function_Name_With_Words`;
* functions that are and should be used only in the file where declared are prefixed by `__static__`;
* quotes are correctly used, i.e. everything that _might_ break if unquoted is quoted;
* single quotes are used if there is no need of using double or different quotes;
* all functions declared in each separate file are marked in the end of the file as `readonly`;
* files are sourced all together by sourcing a single dedicated file (cf. *bash/source_codebase_files.bash* file);
* unit tests must be put in files whose names begin with `unit_tests_` and have the `.bash` extension (this convention allows the runner to source them all automatically) in the ***tests*** folder;
* unit tests are automatically recognized by the tests runner as functions having the `Unit_Test__` prefix (and the remaining part of the function will be the unit test name);
* operations to be done before or after a unit test can be put in the `Make_Test_Preliminary_Operations__[test-name]` and `Clean_Tests_Environment_For_Following_Test__[test-name]` functions, respectively (here `[test-name]` must match the string used in the unit test function name).
