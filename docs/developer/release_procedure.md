# Releasing procedure

The codebase development is done using the [Git-flow branching pattern](http://nvie.com/git-model)[^1].

!!! tip "Use a Git extension"
    There are few extensions that allow to automatize the overhead of sticking to the branching model by hand, i.e. by using Git vanilla commands.
    Since [trunk based development](https://trunkbaseddevelopment.com) has become in the software landscape more appealing, most Git extension to implement Git-flow pattern have decreased maintenance and many froze.
    However, in simple scenarios, like manual usage in the terminal, any extension should work as expected.
    You can check-out the [AVH edition](https://github.com/petervanderdoes/gitflow-avh) (which has been archived in June 2023) or the [CJS Edition](https://github.com/CJ-Systems/gitflow-cjs) which is still (rarely) active.
    Both are successors of the [original implementation](https://github.com/nvie/gitflow) by Vincent Driessen, who invented the model in first place.

When the code is ready to be published, a `release` branch shall be created and the finalization steps should be carried out on it.
Closing the branch means to merge it into `main`, which will be tagged and contain the released version, and merge it back to `develop`, which in principle might have continue development.

!!! warning "Don't forget to update the version string"
    In the codebase there is a global `HYBRID_codebase_version` variable, which contains the version label.
    This should be bumped on the `release` branch, i.e. when it is clear which will be the following version number.
    Analogously, it should be bumped into a dirt state[^2] on `develop` as soon as the `release` is closed.

[^1]:
    Alessandro has offered a trilogy of talks about Git and these are available on his GitHub profile :material-arrow-right-box: [:material-github: AxelKrypton](https://github.com/AxelKrypton/Git-crash-course).
    The second part of the last talk is devoted to introduce and explain this branching pattern in detail.

[^2]:
    The version variable should make clear whether the codebase is in a stable state or not.
    Usually a suffix like `-next` or `-unreleased` is added to the last stable version name immediately after the release (in a dedicated commit), such that the main script will report the dirty state when run with the `--version` option.

## Release checklist

- [x] Create the `release` branch from `develop` and switch to it.

    ??? danger "If you are doing a hot-fix, an extra step is needed here!"
        For hot-fixes, you will branch off `main` and the repository will be in a stable state.
        Hence, you need to immediately bump the version to the hot-fix one adding e.g. a `-start` suffix.
        Before closing the branch you will remove such a suffix.

- [x] Make sure everything is ready to go (e.g. check copyright statements including in documentation).
- [x] Change the `Unreleased` box in the CHANGELOG file to a new release section by
      - adding the new section title;
      - changing the type of box;
      - adding release date and link to changes from previous version.
- [x] Bump version number global variable in main script to a **stable state**.
- [x] Close the `release` branch in the git-flow sense:
      - merge it into the `main` branch;
      - switch to `main` and tag the last commit;
      - switch to `develop` and merge the `release` back into it[^3].
- [x] Publish the new release by pushing the changes and the new tag on `main`.
- [x] From `main` [build and deploy the documentation](building_docs.md).
- [x] From `develop` bump version number global variable in main script to an **unstable state** and prepare a `!!! work-in-progress "Unreleased"` box in the CHANGELOG file.

=== "Create the release branch"
    ```bash
    # Git-flow extension
    git flow release start 1.2.0

    # Vanilla Git commands
    git switch -c release/1.2.0 develop
    ```

=== "Close the release branch"
    ```bash
    # Git-flow extension
    git flow release finish 1.2.0

    # Vanilla Git commands
    git switch main
    git merge --no-ff release/1.2.0
    git tag -a 1.2.0
    git switch develop
    git merge --no-ff release/1.2.0
    git branch -d release/1.2.0
    ```

=== "Publish new release"
    ```bash
    # Only vanilla Git commands
    git push origin main
    git push origin develop
    git push origin --tags
    git push origin :release/1.2.0  # if pushed
    ```

[^3]:
    This might lead to conflicts if the codebase has evolved on the `develop` branch.
    Please note as well that merging `main` into `develop` would be equivalent as the `main` branch is meant for stable releases only and it should not contain anything new w.r.t. the `develop` branch.
