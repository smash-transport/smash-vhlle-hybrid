# Hybrid-handler CHANGELOG

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

    :new: &nbsp; The name of the framework is changed from SMASH-vHLLE-hybrid to Hybrid-handler. Since the handler is a tool to facilitate running hybrid simulations and the underlying stage modules can be varied, this generic name is more precise. Nevertheless, the SMASH-vHLLE-hybrid approach is still part of this framework.

    :new: &nbsp; Added `Add_corona_from_IC_and_Hydro` configuration key in the `Afterburner` module, which merges the files containing corona particles from :file_folder: ***IC*** and :file_folder: ***Hydro*** into the particle lists sampled in :file_folder: ***Sampler***.

    :new: &nbsp; Added new valid config key `hydro_coordinate_system` for SMASH sampler `3.3` to handle hydrodynamic simulations in Cartesian coordinates properly, additional to the runs in tau-eta frame.

    :new: &nbsp; Added new valid config keys `compute_spin_vector`, and `create_vorticity_vector_output` for SMASH sampler `3.3` to enable spin vector calculation all sampled particles.

    :new: &nbsp; The `Input_file` configuration key in the `Hydro` and `Afterburner` modules can now be used to modify the expected file names from the appropriate :file_folder: ***IC*** and :file_folder: ***Sampler*** sub-folders, when a string without a `/` character is given.

    :warning: &nbsp; The parameters extracted by the [Bayesian analysis in :newspaper: *Phys. Rev. C 112, 014910*](https://journals.aps.org/prc/abstract/10.1103/rzml-rjxz) are now set as default for the base configs. The old parameters for the hydro evolution were kept in :file_folder: ***configs/predef_configs/vhlle_hydro_EPJA_58-11-230***, and the other parameters are adjusted by each handler configuration file in :file_folder: *** predef_configs***.

    :new: &nbsp; Added configuration files for a dynamic fluidization run in :file_folder: ***configs/predef_configs/dynamic_fluidization***. This requires the specific branch [merge-review in vHLLE](https://github.com/yukarpenko/vhlle/tree/merge-review).

### SMASH-vHLLE-hybrid-2.1.3

???+ success "&nbsp; :date: &nbsp; Release date: 2025-06-05 &emsp; :left_right_arrow: &nbsp; [Compare changes to previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-2.1.2...SMASH-vHLLE-hybrid-2.1.3)"

    :sos: &nbsp; Fix Hybrid-handler crash due to accessing an unbound variable when trying to run both the `Sampler` and the `Afterburner` stages using the FIST sampler.


### SMASH-vHLLE-hybrid-2.1.2

???+ success "&nbsp; :date: &nbsp; Release date: 2025-05-16 &emsp; :left_right_arrow: &nbsp; [Compare changes to previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-2.1.1...SMASH-vHLLE-hybrid-2.1.2)"

    :sos: &nbsp; The previous hot-fix introduced a subtle bug, making the Hybrid-handler ignore a user-customized base configuration file for the `IC` stage. This is fixed now.


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
