# Hybrid handler CHANGELOG

All notable changes to this project will be documented in this changelog.
This project does not strictly adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html), but it uses versioning inspired by it.
In particular, not all backward incompatible changes lead to a bump in the major version number, but all of these are mentioned and emphasized here.
Given a version number `X.Y.Z`,

* `X` is incremented for major changes in particular relevant new functionality,
* `Y` is incremented for minor changes or new minor functionality, and
* `Z` is mainly used for bug fixes.


=== "Symbols"

    Every entry in this file is prepended with a symbol that is meant to draw attention about the type of change.
    Click on a symbol above for more information about it.

=== ":new:"

    This symbol indicates _new features_.

=== ":recycle:"

    This symbol indicates _changes in existing functionality_.

=== ":sos:"

    This symbol indicates _fixes of wrong behavior_.

=== ":x:"

    This symbol indicates _removed features_.

=== ":boom:"

    This symbol indicates _breaking changes, i.e. not backward-compatible changes_.

=== ":fire:"

    This symbol indicates _deprecated features, which are likely to be removed in later versions_.

=== ":warning:"

    This symbol indicates _changes that deserve particular attention by the user_.


!!! work-in-progress "Unreleased"

    **Changes:**


### SMASH-vHLLE-hybrid-2.1.2

???+ success "&nbsp; :date: &nbsp; Release date: 2025-05-16 &emsp; :left_right_arrow: &nbsp; [Compare changes to previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-2.1.1...SMASH-vHLLE-hybrid-2.1.2)"

    :sos: &nbsp; The previous hot-fix introduced a subtle bug, making the hybrid handler ignore a user-customized base configuration file for the `IC` stage. This is fixed now.


### SMASH-vHLLE-hybrid-2.1.1

???+ success "&nbsp; :date: &nbsp; Release date: 2025-05-15 &emsp; :left_right_arrow: &nbsp; [Compare changes to previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-2.1...SMASH-vHLLE-hybrid-2.1.1)"

    :sos: &nbsp; Make the handler select the correct default base configuration file for the `IC` stage depending on the SMASH version. This was needed because `SMASH-3.2` changed some configuration keys about initial conditions setup.

    :sos: &nbsp; Fix how spectators are added from the `IC` output into the `Afterburner` input file. This now works for all SMASH versions. The spectators from the target were not properly considered beforehand. Additionally, the adding of spectators is currently only allowed if only one `IC` event was run.

    :recycle: &nbsp; Renamed the copied/linked afterburner inputfile containing the sampled particles (and possibly spectators) from :material-file: _sampled_particles_list.oscar_ to :material_file: _sampled_particles.oscar_. Note that this is not a breaking change because this file is created into the :file_folder: **Afterburner** folder at the beginning of such a stage.


### SMASH-vHLLE-hybrid-2.1

???+ success "&nbsp; :date: &nbsp; Release date: 2025-03-31 &emsp; :left_right_arrow: &nbsp; [Compare changes to previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-2.0...SMASH-vHLLE-hybrid-2.1)"

    :sos: &nbsp; Make the handler select the correct default base configuration file for the `Sampler` stage depending on the SMASH hadron sampler version. This was needed because `SMASH-hadron-sampler-3.2` refactored the user interface.

    :new: &nbsp; Support for a new sampler module: [FIST sampler](https://github.com/vlvovch/fist-sampler) is now usable additionally to the SMASH hadron sampler.

    :new: &nbsp; The project logo was changed to a fancier, more fantasy version.


### SMASH-vHLLE-hybrid-2.0

???+ success ":date: &nbsp; Release date: 2024-04-12 &emsp; :left_right_arrow: &nbsp; [Compare changes to previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-1.0...SMASH-vHLLE-hybrid-2.0)"

    :new: :boom: &nbsp; The project approach has totally changed and it switched from a `CMake` based framework to a `Bash` based framework.
      A detailed documentation web-page has been built to guide both users and developers.


### SMASH-vHLLE-hybrid-1.0

!!! success ":date: &nbsp; Release date: 2020-11-18 &emsp; :left_right_arrow: &nbsp; [First public version of the SMASH-vHLLE-hybrid](https://github.com/smash-transport/smash-vhlle-hybrid/releases/tag/SMASH-vHLLE-hybrid-1.0)"
