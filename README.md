# SMASH-vHLLE-Hybrid
Event-by-event hybrid model for the description of relativistic heavy-ion collisions in the low and high baryon-density regime. This model constitutes a chain of different submodules to appropriately describe each phase of the collision with its corresponding degrees of freedom. It consists of the following modules:
- SMASH hadronic transport approach to provide the initial conditions
- vHLLE 3+1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball
- CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE)
- Cooper-Frye sampler to perform particlization of the elements on the freezeout hypersurface
- SMASH hadronic transport approach to perform the afterburner evolution

## Prerequisites
- [cmake](https://cmake.org) version &ge; 3.15.4
- [SMASH](https://github.com/smash-transport/smash) version &ge; 1.8
- [vHLLE](https://github.com/yukarpenko/vhlle)
- [vHLLE parameters](https://github.com/yukarpenko/vhlle_params)
- [hadron sampler](https://github.com/smash-transport/smash-hadron-sampler) version &ge; 1.0
- python version &ge; 2.7
- ([SMASH-analysis](https://github.com/smash-transport/smash-analysis) version &ge; 1.7, if automatic generation of particle spectra is desired)

Before building the full hybrid model, please make sure that the submodules listed above (SMASH, vHLLE, vHLLE params, sampler) are available and already compiled. Instructions on how to compile them can be found in the corresponding READMEs.

## Building the hybrid model

Once the prerequisites are met, use the following commands to build the full hybrid model in a separate `build` directory:

    mkdir build
    cd build
    cmake .. -DSMASH_PATH=[...]/smash/build -DVHLLE_PATH=[...]/vhlle -DVHLLE_PARAMS_PATH=[...]/vhlle_params/ -DSAMPLER_PATH=[...]/hadron-sampler/build
    make

where `[...]` denote the paths to the `smash/build` direcory, the `vhlle` directory, the `vhlle_params` directory and the `hadron-sampler/build` directory. The binaries of the precompiled submodules are expected to be located therein. The `vhlle_params` directory does not contain any binary though, it only holds the equations of state necessary for the hydrodynamic evolution.

All subtargets corresponding to the predefined collision setups have been created by `cmake`. To more easily divide the full hybrid run into smaller pieces, different targets are created for each step of the hybrid simulation. They have to be run one after the other in the order specified below. For a Pb+Pb collision at sqrt(s) = 8.8 GeV, this chain is executed via:

    make PbPb_8.8_IC
    make PbPb_8.8_hydro
    make PbPb_8.8_sampler
    make PbPb_8.8_afterburner

The output files of the individual submodules as well as the configuration files used can be found in the newly-created directory `[...]/build/Hybrid_Results/PbPb_8.8GeV/i`, where `i` corresponds to the i-th hybrid run in an event-by-event setup. By default, the full hybrid model is run 100 times in parallel for different initial states. To change the number of parallel runs, modify the parameter `num_runs` in  `CMakeLists.txt`.

## Building the hybrid model linked to the SMASH-analysis
To also provide the automatic analysis of the final particle lists, run the following commands to link the project to the smash-analysis:

    mkdir build
    cd build
    cmake .. -DSMASH_PATH=[...]/smash/build -DVHLLE_PATH=[...]/vhlle -DVHLLE_PARAMS_PATH=[...]/vhlle_params/ -DSAMPLER_PATH=[...]/hadron-sampler/build -DSMASH_ANALYSIS_PATH=[...]/smash-analysis
    make

Once the afterburner was run, the resulting particle lists can be analysed and plotted by executing:

    make PbPb_8.8_analysis
    make PbPb_8.8_plots

The generated plots and output files are then located in `[...]/build/Hybrid_Results/PbPb_8.8GeV/i/Spectra`. The above commands analyse and plot the results of each of the 100 parallel hybrid runs. It is useful to  average over the obtained results to obtain averaged final-state plots. This is done by executing

    make PbPb_8.8_average_spectra
    make PbPb_8.8_average_plots

in this specific order. The final output files are then located in `[...]/build/Hybrid_Results/PbPb_8.8GeV/Averaged_Spectra`.

## Configuring the collision setups
A number of different collision setups for the hybrid model are supported out of the box. The shear viscosities applied are taken from *Karpenko et al.: Phys.Rev.C 91 (2015)* and the longitudinal and transversal smearing parameters are adjusted to improve agreement with experimental data. The supported collision systems are:
* AuAu @ sqrt(s) = 4.3 GeV
* PbPb @ sqrt(s) = 6.4 GeV
* AuAu @ sqrt(s) = 7.7 GeV
* PbPb @ sqrt(s) = 8.8 GeV
* PbPb @ sqrt(s) = 17.3 GeV
* AuAu @ sqrt(s) = 27.0 GeV
* AuAu @ sqrt(s) = 39.0 GeV
* AuAu @ sqrt(s) = 64.2 GeV
* AuAu @ sqrt(s) = 130.0 GeV
* AuAu @ sqrt(s) = 200.0 GeV

They can be executed in analogy to the PbPb @ sqrt(s) = 8.8 GeV example presented above.

To run additional setups it is necessary to add the corresponding targets to the bottom of the `CMakeLists.txt` file. <br>
The configuration files are located in `[...]/configs/`. Four different configuration files are necessary to run the full hybrid model. These are:
1. `smash_initial_conditions_AuAu.yaml` or `smash_initial_conditions_AuAu.yaml` for the configuration of the initial setup of the collision. There are two initial conditions files corresponding to collision systems of Au+Au and Pb+Pb, respectively. If additional collision systems are desired, it is necessary to add an appropriate configuration file to the `[...]/configs/` directory. For details and further information about the configuration of SMASH, consult the [SMASH User Guide](http://theory.gsi.de/~smash/userguide/current/).
2. `vhlle_hydro` for the configuration of the hydrodynamic evolution. <br>
Further information about the configuration of vHLLE is provided in the `README.txt` of vHLLE.
3. `hadron_sampler` for the configuration of the sampler. <br>
Further information about the configuration of the sampler is provided in the `README.md` of the `hadron-sampler`.
4. `smash_afterburner.yaml` for the configuration of the SMASH afterburner evolution based on the sampled particle list.

**Note:** In all configuration files, the paths to input files from the previous stages are adjusted automatically. Also cross-parameters that require consistency between the hydrodynamics evolution and the sampler, e.g. viscosities and critical energy density, are taken care of automatically.
