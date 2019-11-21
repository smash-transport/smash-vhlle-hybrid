# Annas-Hybrid
Hybrid model for the description of relativistic high-energy heavy-ion collisions. This model constitutes a chain of different submodules to appropriately describe each phase of the collision with appropriate degrees of freedom. It consists of the following modules:
- SMASH hadronic transport approach to provide the initial conditions
- vHLLE 3 +1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball
- CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE)
- Cooper-Frye sampler by S. Ryu to perform particlization of the freezeout hypersurface
- SMASH hadronic transport approach to perform the afterburner evolution

## Prerequisites
- [cmake](https://cmake.org) version &ge; 3.15.4
- [SMASH](https://github.com/smash-transport/smash) version &ge; 1.7
- [vHLLE](https://github.com/akschaefer/vhlle) branch `schaefer/Output_for_Sampler_Ryu_inMilne`
- Cooper-Frye sampler by S. Ryu
- ([SMASH-analysis](https://github.com/smash-transport/smash-analysis) version &ge; 1.7, if automatic generation of particle spectra is desired)

## Building the hybrid model

Use the following commands to easily build the full model for all subtargets in a separate `build` directory:

    mkdir build
    cd build
    cmake .. -DSMASH_PATH=[...]/smash/build -DVHLLE_PATH=[...]/vhlle -DSAMPLER_PATH=[...]/sampler_SRyu
    make

where `[...]` denote the paths to the `smash/build` direcory, the `vhlle` directory and the `sampler_SRyu` directory. All submodules are expecte to be precompiled and the binaries located in the aforementioned directories. Make sure to compile `vhlle`on branch `schaefer/Output_for_Sampler_Ryu_inMilne`, else the output will not be compatible with the Cooper-Frye sampler.

All subtargets corresponding to the predefined collision setups have been created by `cmake`. To run, for example, a Gold-Gold collision at sqrt(s) = 8.8 GeV, execute the following:

    make AuAu_8.8

which will start the full chain of simulations and run the entire hybrid evolution. Alternatively, you can run the different stages step by step by executing the following commands in the given order:

    make AuAu_8.8_IC
    make AuAu_8.8_hydro
    make AuAu_8.8_sampler
    make AuAu_8.8_afterburner

Note: Apart from the binaries, the equations of state are also necessary, to run the hydro evolution as well as to perform the particlization for the afterburner. For this, the directories `eos` and `EOS` are also copied to the build directory and contain the input for vHLLE and the Cooper-Frye sampler, respectively.
