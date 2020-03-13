# Annas-Hybrid
Hybrid model for the description of relativistic heavy-ion collisions in the low and high baryon-density regime. This model constitutes a chain of different submodules to appropriately describe each phase of the collision with its corresponding degrees of freedom. It consists of the following modules:
- SMASH hadronic transport approach to provide the initial conditions
- vHLLE 3+1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball
- CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE)
- Cooper-Frye sampler to perform particlization of the elements on the freezeout hypersurface
- SMASH hadronic transport approach to perform the afterburner evolution

## Prerequisites
- [cmake](https://cmake.org) version &ge; 3.15.4
- [SMASH](https://github.com/smash-transport/smash) version &ge; 1.8
- [vHLLE](https://github.com/akschaefer/vhlle) branch `smash_hybrid`
- [hadron sampler](https://github.com/yukarpenko/hadronSampler/) branch `smash_hybrid`
- ([SMASH-analysis](https://github.com/smash-transport/smash-analysis) version &ge; 1.7, if automatic generation of particle spectra is desired)

Before building the full hybrid model, please make sure that the sumodules listed above (SMASH, vHLLE, sampler) are available and already compiled. Instructions on how to compile them can be found in the corresponding READMEs.  
**Note:** For vHLLE and the sampler it is essential that both are compiled on the branch `smash_hybrid`.

## Building the hybrid model

Once the prerequisites are met, use the following commands to build the full hybrid model in a separate `build` directory:

    mkdir build
    cd build
    cmake .. -DSMASH_PATH=[...]/smash/build -DVHLLE_PATH=[...]/vhlle -DSAMPLER_PATH=[...]/hadronSampler/build
    make

where `[...]` denote the paths to the `smash/build` direcory, the `vhlle` directory and the `hadronSampler/build` directory. The binaries of the precompiled submodules are expected to be located therein.

All subtargets corresponding to the predefined collision setups have been created by `cmake`. To run, for example, a Gold-Gold collision at sqrt(s) = 8.8 GeV, execute the following:

    make AuAu_8.8

which will start the full chain of simulations and run the entire hybrid evolution. Alternatively, you can run the different stages step by step by executing the following commands in the given order:

    make AuAu_8.8_IC
    make AuAu_8.8_hydro
    make AuAu_8.8_sampler
    make AuAu_8.8_afterburner

The output files of the individual submodules as well as the configuration files used can be found in the newly-created directory `[...]/build/Hybrid_Results/AuAu_8.8GeV`.

**Note:** Apart from the binaries, the equations of state are also necessary to run the hydro evolution as well as to perform the particlization for the afterburner. For this, the directory `eos` is also copied from `[...]/vhlle` to the build directory.

## Building the hyrid including analysis
To also provide the automatic analysis of the final state, run the following commands to also link to the smash analysis:

    mkdir build
    cd build
    cmake .. -DSMASH_PATH=[...]/smash/build -DVHLLE_PATH=[...]/vhlle -DSAMPLER_PATH=[...]/hadronSampler/build -DSMASH_ANALYSIS_PATH=[...]/smash-analysis
    make

Once the afterurner was run, the resulting particle lists can be analysed and plotted by executing the following commands:

    make AuAu_8.8_analysis
    make AuAu_8.8_plots

The generate plots and lists are then located in `[...]/build/Hybrid_Results/AuAu_8.8GeV/Spectra`.
