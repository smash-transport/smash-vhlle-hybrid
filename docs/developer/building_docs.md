# Building the documentation

The documentation is built using [MkDocs](https://www.mkdocs.org) and in particular the impressive [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/) theme.
All documentation files and related material is located in :file_folder: ***docs***.
Therefore it is hosted in the codebase and it naturally evolves together with it.

## Prerequisite

Few packages are required and all can be installed using `pip`:
```bash
pip install mkdocs
pip install mkdocs-material
pip install mike
```

You can refer to the corresponding installation pages for further information (1).
{ .annotate }

1.  :fontawesome-solid-book: [MkDocs](https://www.mkdocs.org/user-guide/installation/)&emsp;
    :simple-materialformkdocs: [Material for MkDocs](https://squidfunk.github.io/mkdocs-material/getting-started/#installation)&emsp; :material-bike-fast: [mike](https://github.com/jimporter/mike#installation)

## Serving, building and deploying

The deployed version is hosted on the :octicons-git-branch-16: `gh-pages` branch, while documentation from any other branch can be comfortably visualized in a browser opening up [http://127.0.0.1:8000/](http://127.0.0.1:8000/) after having run `mkdocs serve` in a terminal from the top-level repository folder.

The documentation website can also be locally built by running `mkdocs build`, which will create a :file_folder: ***site*** folder containing the website source code.

Once changes to the website have been locally checked, they are ready to be deployed.
We use `mike` to deploy documentation, because it allows to make different documentation versions coexist and be easily selected.
Our usage of this tool is quite basic, but you can check out [mike's documentation](https://github.com/jimporter/mike) to know more about it.

!!! warning "Be aware of few caveats"

    Even if we use `mike` to deploy documentation, the same warnings about the [MkDocs deployment](https://www.mkdocs.org/user-guide/deploying-your-docs/) feature apply:

    1. Be aware that you will not be able to review the built site before it is pushed to GitHub. Therefore, you may want to verify any changes you make to the docs beforehand by using the build or serve commands and reviewing the built files locally.
    2. You should never edit files in your pages repository by hand if you're using the gh-deploy command because you will lose your work the next time you run the command.
    3. If there are untracked files or uncommitted work in the local repository where `mkdocs gh-deploy` is run, these will be included in the pages that are deployed.


### Our deployment scheme

The documentation does not store one version for _all_ versions of the codebase.
In particular, releases like a bug-fix which only change the `patch` number in the version string won't have a new documentation version associated.
To say it differently, the documentation of version `X.Y` will always show the documentation of the corresponding highest patch.

#### At new releases

When a new release of the codebase is done, a new version of the documentation should be built and deployed.
This can be easily done via
```
mike deploy --push --update-aliases X.Y latest
```
where `X.Y` are the `major.minor` version numbers of the release.
The command will also update the `latest` alias to point to the new release documentation.

??? tip "Good to know"
    Omitting the `--push` option, nothing will be pushed and you have the possibility to check the changes on the `gh-pages` branch, which must be then manually pushed to publish the changes.

#### At new patches

When a new patch is released, it is usually worth adjusting the documentation title via `mike retitle --push X.Y <new_title>`, where new title might simply be `X.Y.Z`, i.e. the complete new version string.

#### The development documentation

Documentation between releases will naturally evolve and, whenever it makes sense, changes to the documentation should be deployed, too.
For this purpose, developers should run
```
mike deploy --push develop
```
reasonably often, since this documentation is thought to reflect the state of the :octicons-git-branch-16: `develop` branch.
