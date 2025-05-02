# Changelog

All notable changes to this project will be documented in this file.
This project does not strictly adhere to [Semantic Versioning](https://semver.org/spec/v2.0.0.html), but it uses versioning inspired by it.
In particular, not all backward incompatible changes lead to a bump in the major version number, but all of these are mentioned and emphasized here.
Given a version number `X.Y.Z`,

* `X` is incremented for major changes in particular relevant new functionality,
* `Y` is incremented for minor changes or new minor functionality, and
* `Z` is mainly used for bug fixes.

Every entry in this file is prepended with symbols that are meant to draw attention about the type of change:

* :new: for new features;
* :recycle: for changes in existing functionality;
* :sos: for fixes of wrong behavior;
* :x: for removed features;
* :boom: for breaking changes, i.e. not backward-compatible changes;
* :fire: for deprecated features, which are likely to be removed in later versions;
* :warning: for changes that deserve particular attention by the user.


## Unreleased

* :recycle: Renamed the copied/linked afterburner inputfile containing the sampled particles (and possibly spectators) from _sampled_particles_list.oscar_ to _sampled_particles.oscar_.


## SMASH-vHLLE-hybrid-2.1
Date: 2025-03-31

* :new: Support for a new sampler module: [FIST sampler](https://github.com/vlvovch/fist-sampler) is now usable additionally to the SMASH hadron sampler.
* :new: The project logo was changed to a fancier, more fantasy version.

[Link to diff from previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-2.0...SMASH-vHLLE-hybrid-2.1)


## SMASH-vHLLE-hybrid-2.0
Date: 2024-04-12

* :new: :boom: The project approach has totally changed and it switched from a `CMake` based framework to a `Bash` based framework.
  A detailed documentation web-page has been built to guide both users and developers.

[Link to diff from previous version](https://github.com/smash-transport/smash-vhlle-hybrid/compare/SMASH-vHLLE-hybrid-1.0...SMASH-vHLLE-hybrid-2.0)


## SMASH-vHLLE-hybrid-1.0
Date: 2020-11-18

**[First public version of the SMASH-vHLLE-hybrid](https://github.com/smash-transport/smash-vhlle-hybrid/releases/tag/SMASH-vHLLE-hybrid-1.0)**
