# Hybrid handler changelog

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


!!! warning "Unreleased"
    :recycle: &nbsp; Renamed the copied/linked afterburner inputfile containing the sampled particles (and possibly spectators) from _sampled_particles_list.oscar_ to _sampled_particles.oscar_.


!!! success "SMASH-vHLLE-hybrid-2.1"
    <div align="center">
      :date: &nbsp; Release date: 2025-03-31
      &emsp;
      :left_right_arrow: &nbsp; [Link to diff from previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-2.0...SMASH-vHLLE-hybrid-2.1)
    </div>

    **Changes**

    :new: &nbsp; Support for a new sampler module: [FIST sampler](https://github.com/vlvovch/fist-sampler) is now usable additionally to the SMASH hadron sampler.

    :new: &nbsp; The project logo was changed to a fancier, more fantasy version.


!!! success "SMASH-vHLLE-hybrid-2.0"
    <div align="center">
      :date: &nbsp; Release date: 2024-04-12
      &emsp;
      :left_right_arrow: &nbsp; [Link to diff from previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-1.0...SMASH-vHLLE-hybrid-2.0)
    </div>

    **Changes**

    :new: :boom: &nbsp; The project approach has totally changed and it switched from a `CMake` based framework to a `Bash` based framework.
      A detailed documentation web-page has been built to guide both users and developers.


!!! success "SMASH-vHLLE-hybrid-1.0"
    <div align="center">
      :date: &nbsp; Release date: 2020-11-18
      &emsp;
      :left_right_arrow: &nbsp; [First public version of the SMASH-vHLLE-hybrid](https://github.com/smash-transport/smash-vhlle-hybrid/releases/tag/SMASH-vHLLE-hybrid-1.0)
    </div>
