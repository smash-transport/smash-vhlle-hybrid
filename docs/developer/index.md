---
hide:
  - navigation
  - toc
---

# From great power comes great responsibility

The hybrid handler has been developed trying to make the entry point of a newbie developer as low as possible.
Although :simple-gnubash: **Bash** can be sometimes not that simple to read[^1], the integration-operation segregation principle ([IOSP](https://clean-code-developer.com/grades/grade-1-red/)) has been used most of the times at the the top-level to allow the reader to get a first understanding of what the main functions are doing, having then the possibility to deepen into lower levels if needed.
Said differently, reading the code top-down should be straightforward, as the most top-level function is a series of function calls only, whose names should clearly describe what is done.

Therefore, this guide is not meant to document any possible implementation detail, but rather provide the reader with important information, which might be difficult to grasp by reading the codebase.
Assumptions that are crucial to know before even getting to the code have a dedicated card here in the following.

---

[^1]:
    Alessandro has offered many times a Bash crash-course and the full material is available on his GitHub profile :material-arrow-right-box: [:material-github: AxelKrypton](https://github.com/AxelKrypton/Bash-lecture).

<div class="grid cards" markdown>

!!! danger "No period or space in YAML keys"
    The full implementation relies on the assumption that YAML keys contain neither spaces nor periods.
    This is basically a design decision for this project and also a sensible thing to avoid (it would require another level of quoting when using `yq`).
    The developer has to be aware that the code does break, if such an assumption is violated.
    Although the external software used for each stage might violate this, it is not the case at the moment and it is considered unlikely to happen in the future.

!!! warning "The stages names are hard-coded everywhere"
    Each simulation phase has a label associated to it (i.e. `IC`, `Hydro`, etc.) and these are used in variable names as well, although with lower-case letters only.
    In the codebase it has been exerted leverage on this aspect and at some point the name of variables are built using the section labels transformed into lower-case words.
    Hence, it is important that section labels do not contain characters that would break this mechanism, like dashes or spaces.

!!! tip "Ensure variables that should be defined *are* defined"
    In Bash, from within a function, it is possible to access the caller local variables.
    However, this should be used with care and not be abused as it might lead to code which is easy to use wrong.
    When needed, make sure to use the dedicated [utility functions](utility_functions.md) `Ensure_That_Given_Variables_Are_Set` and `Ensure_That_Given_Variables_Are_Set_And_Not_Empty` in the beginning of your function.
    This is also a way to document the implementation.

-   :computer:{ .lg .middle } &nbsp; __Ready to code?__

    ---

    Cool, but not so quick.
    Every project has its contributing rules and you are kindly requested to go over them at least once before starting.

    [:material-arrow-right-box:&nbsp; Read more](contributing.md)

-   :arrow_forward:{ .lg .middle } &nbsp; __Building the documentation__

    ---

    Especially when changing it, it is important to locally build the documentation and see how it looks.
    This is made trivial by MkDocs which also helps deploying it at every release.

    [:material-arrow-right-box:&nbsp; Check it out!](building_docs.md)

-   :test_tube:{ .lg .middle } &nbsp; __A handy testing framework__

    ---

    Tests are the key to be confident that the code works as expected.
    A testing framework has been developed tailored to the project.
    Adding new tests is as simple as writing a new function!

    [:material-arrow-right-box:&nbsp; Check it out!](testing_framework.md)

-   :rocket:{ .lg .middle } &nbsp; __New release procedure__

    ---

    At every new release few standard steps are required and it is important not to forget them and to always be consistent in how a new version of the code is released.

    [:material-arrow-right-box:&nbsp; Discover more!](release_procedure.md)

-   :tools:{ .lg .middle } &nbsp; __Utility functions__

    ---

    As in every codebase, there are operations that are totally general and can be delegated to utility functions that will help in extending or improving the codebase.

    [:material-arrow-right-box:&nbsp; Reference page](utility_functions.md)

-   :material-barcode-scan:{ .lg .middle } &nbsp; __Design of the parameter scan__

    ---

    Since the `prepare-scan` execution mode implementation is not trivial and it required a couple of design decisions, it has been decided to comment on each of these in a dedicated page.

    [:material-arrow-right-box:&nbsp; Read more](parameters_scan.md)

-   :jigsaw:{ .lg .middle } &nbsp; __Adding a new module__

    ---

    You want to replace the software in one or more stages with a different one?
    Check these notes about what changes are needed.

    [:material-arrow-right-box:&nbsp; Read more](new_module.md)


</div>
