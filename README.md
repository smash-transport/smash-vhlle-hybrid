# SMASH-vHLLE-Hybrid
Event-by-event hybrid model for the description of relativistic heavy-ion collisions in the low and high baryon-density regime.
This model constitutes a chain of different submodules to appropriately describe each phase of the collision with its corresponding degrees of freedom.
It consists of the following modules:
- SMASH hadronic transport approach to provide the initial conditions;
- vHLLE 3+1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball;
- CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE);
- Cooper-Frye sampler to perform particlization of the elements on the freezeout hypersurface;
- SMASH hadronic transport approach to perform the afterburner evolution.

If you are using the SMASH-vHLLE-hybrid, please cite [arXiv:2212.08724](https://arxiv.org/abs/2112.08724). You may also consult this reference for further details about the hybrid approach.

## Prerequisites

| Software | Required version |
| :------: | :--------------: |
| [CMake](https://cmake.org) | 3.15.4 or higher |
| [SMASH](https://github.com/smash-transport/smash) | 1.8 or higher |
| [vHLLE](https://github.com/yukarpenko/vhlle) | - |
| [vHLLE parameters](https://github.com/yukarpenko/vhlle_params) | - |
| [Hadron sampler](https://github.com/smash-transport/smash-hadron-sampler) | 1.0 or higher |
| [Python](https://www.python.org) | 2.7  or higher |
| [SMASH-analysis](https://github.com/smash-transport/smash-analysis)<sup>*</sup> | 1.7 or higher |

<sup>*</sup><sub>Needed if automatic generation of particle spectra is desired.</sub>

Instructions on how to compile or install the software above can be found at the provided links either in the official documentation or in the corresponding README files.

The newer versions of ROOT require C++17 bindings or higher, so please make sure to compile SMASH, ROOT, and the sampler with the same compiler utilizing the same compiler flags, which can be adjusted in CMakeLists.txt of each submodule.
It is also recommended to start from a clean build directory whenever changing the compiler or linking to external libraries that were compiled with different compiler flags.
