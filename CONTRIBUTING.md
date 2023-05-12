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
* quotes are correctly used, i.e. everything that _might_ break if unquoted is quoted;
* single quotes are used if there is no need of using double or different quotes;
* all functions declared in each separate file are marked in the end of the file as `readonly`;
* files are sourced all together by sourcing a single dedicated file.
