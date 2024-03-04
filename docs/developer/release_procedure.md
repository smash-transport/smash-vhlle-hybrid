# Releasing procedure

The codebase development is done using the [Git-flow branching pattern](http://nvie.com/git-model)[^1].

!!! tip "Use a Git extension"
    There are few extensions that allow to automatize the overhead of sticking to the branching model by hand using Git vanilla commands.
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

- [x] Create the `release` branch and switch to it.
- [x] Make sure everything is ready to go.
- [x] Bump version number global variable in main script to a **stable state**.
- [x] Close the `release` branch in the git-flow sense.
- [x] From `main` build and deploy the documentation.
- [x] From `develop` bump version number global variable in main script to an **unstable state**.
