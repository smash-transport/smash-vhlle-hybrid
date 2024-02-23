---
hide:
  - navigation
  - toc
---

# From great power comes great responsibility

The hybrid handler has been developed trying to make the entry point of a newbie developer as low as possible.
Although :simple-gnubash: **Bash** can be sometimes not that simple to read[^1], the integration-operation segregation principle ([IOSP](https://clean-code-developer.com/grades/grade-1-red/)) has been used most of the times at the the top-level to allow the reader to get a first understanding of what the main functions are doing, having then the possibility to deepen into lower levels if needed.
Said it differently, reading the code top-down should be straightforward, as the most top-level function is a series of function calls only, whose names should clearly describe what it is done.

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

-   :arrow_forward:{ .lg .middle } &nbsp; __Building the documentation__

    ---

    Especially when changing it, it is important to locally build the documentation and see how it looks.
    This is made trivial by MkDocs which also helps deploying it at every release.

    [:material-arrow-right-box:&nbsp; Check it out!](building_docs.md)

-   :computer:{ .lg .middle } &nbsp; __Ready to code?__

    ---

    Not so quick.
    Every project has its contributing rules and you are kindly requested to go over them at least once before starting.

    [:material-arrow-right-box:&nbsp; Read more](contributing.md)

-   :material-barcode-scan:{ .lg .middle } &nbsp; __Design of the parameter scan__

    ---

    Since the `prepare-scan` execution mode implementation is not trivial and it required a couple of design decisions, it has been decided to comment on each of these in a dedicated page.

    [:material-arrow-right-box:&nbsp; Read more](parameters_scan.md)

</div>
