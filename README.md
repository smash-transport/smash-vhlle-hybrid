# SMASH-vHLLE-Hybrid
Event-by-event hybrid model for the description of relativistic heavy-ion collisions in the low and high baryon-density regime. This model constitutes a chain of different submodules to appropriately describe each phase of the collision with its corresponding degrees of freedom. It consists of the following modules:
- SMASH hadronic transport approach to provide the initial conditions
- vHLLE 3+1D viscous hydrodynamics approach to describe the evolution of the hot and dense fireball
- CORNELIUS tool to construct a hypersurface of constant energy density from the hydrodynamical evolution (embedded in vHLLE)
- Cooper-Frye sampler to perform particlization of the elements on the freezeout hypersurface
- SMASH hadronic transport approach to perform the afterburner evolution

If you are using the SMASH-vHLLE-hybrid, please cite [arXiv:2112.08724](https://arxiv.org/abs/2112.08724). You may also consult this reference for further details about the hybrid approach.

## Prerequisites
- [cmake](https://cmake.org) version &ge; 3.15.4
- [SMASH](https://github.com/smash-transport/smash) version &ge; 1.8
- [vHLLE](https://github.com/yukarpenko/vhlle)
- [vHLLE parameters](https://github.com/yukarpenko/vhlle_params)
- [hadron sampler](https://github.com/smash-transport/smash-hadron-sampler) version &ge; 1.0
- python version &ge; 2.7
- ([SMASH-analysis](https://github.com/smash-transport/smash-analysis) version &ge; 1.7, if automatic generation of particle spectra is desired)

Before building the full hybrid model, please make sure that the submodules listed above (SMASH, vHLLE, vHLLE params, sampler) are available and already compiled. Instructions on how to compile them can be found in the corresponding READMEs.

The newer versions of ROOT require C++17 bindings or higher, so please make sure to compile SMASH, ROOT, and the sampler with the same compiler utilizing the same compiler flags, which can be adjusted in CMakeLists.txt of each submodule. It is also recommended to start from a clean build directory whenever changing the compiler or linking to external libraries that were compiled with different compiler flags.

## Building the hybrid model

Once the prerequisites are met, use the following commands to build the full hybrid model in a separate `build` directory:

    mkdir build
    cd build
    cmake .. -DSMASH_PATH=[...]/smash/build -DVHLLE_PATH=[...]/vhlle -DVHLLE_PARAMS_PATH=[...]/vhlle_params/ -DSAMPLER_PATH=[...]/smash-hadron-sampler/build

where `[...]` denote the paths to the `smash/build` directory, the `vhlle` directory, the `vhlle_params` directory and the `smash-hadron-sampler/build` directory. The binaries of the precompiled submodules are expected to be located therein. The `vhlle_params` directory does not contain any binary though, it only holds the equations of state necessary for the hydrodynamic evolution.

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
    cmake .. -DSMASH_PATH=[...]/smash/build -DVHLLE_PATH=[...]/vhlle -DVHLLE_PARAMS_PATH=[...]/vhlle_params/ -DSAMPLER_PATH=[...]/smash-hadron-sampler/build -DSMASH_ANALYSIS_PATH=[...]/smash-analysis

Once the afterburner was run, the resulting particle lists can be analysed and plotted by executing:

    make PbPb_8.8_analysis
    make PbPb_8.8_plots

The generated plots and output files are then located in `[...]/build/Hybrid_Results/PbPb_8.8GeV/i/Spectra`. The above commands analyse and plot the results of each of the 100 parallel hybrid runs. It is useful to  average over the obtained results to obtain averaged final-state plots. This is done by executing

    make PbPb_8.8_average_spectra
    make PbPb_8.8_average_plots

in this specific order. The final output files, that is tables and plots, are then located in `[...]/build/Hybrid_Results/PbPb_8.8GeV/Averaged_Spectra`.

In addition, it is possible to extract excitation functions for the mean transverse momentum and the mid-rapidity yield if the SMASH-vHLLE-hybrid was run for different collision energies. To obtain those, execute

    make exc_funcs

after having analyzed and averaged the output at all collision energies with the above stated commands. The resulting excitation functions in terms of tables and plots containing entries at all previously run collision energies are then located  in `[...]/build/Hybrid_Results`.

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


## Using a custom SMASH configuration file for the initial conditions

In addition to the above described predefined Au+Au and Pb+Pb collisions, it is possible to employ a custom `SMASH` configuration file in the initial stage. This file is expected to be located in the  `[...]/configs/` directory and named `smash_initial_conditions_custom.yaml`. An example configuration is shipped with the `SMASH-vHLLE-hybrid`, it can be modified as desired. To run the hybrid with this custom configuration file, execute the following commands:

    make custom_IC
    make custom_hydro
    make custom_sampler
    make custom_afterburner

The results are stored in `[...]/build/Hybrid_Results/Custom` and the subdirectories are structured identically as for the predefined Au+Au or Pb+Pb collisions as described above.

To further analyze and average the outcome, if the `SMASH-vHLLE-hybrid` is coupled to the `SMASH-analysis` as described above, one may further execute

    make custom_analysis
    make custom_average_spectra
    make custom_average_plots

to obtain rapidity and transverse mass spectra that are stored in `[...]/build/Hybrid_Results/Custom/Averaged_Spectra`.

**Note:**
It might be necessary to separately adjust the viscosity and smearing parameters employed for the hydrodynamical evolution when using a custom SMASH config, as the default values are most likely not be the best fit. These can be adjusted in the `python_scripts/hydro_parameters.py` file, by modifying the values corresponding to the key `default` in the `hydro_params` dictionary.

# Module exchanges and further modifications
It might be desired to run the SMASH-vHLLE-hybrid, but relying on a different initial state, particle sampler or similar. For this, the `CMakeLists.txt` need to be updated accordingly. Exemplary instructions for a number of use cases are provided in the following.

#### Running vHLLE on an averaged initial state from SMASH
By default, the SMASH-vHLLE-hybrid performs event-by-event simulations. To run a single-shot hydrodynamical event with initial conditions obtained from multiple averaged SMASH events, you can proceed as follows:
1. Open the configuration file for the SMASH initial state: `configs/smash_initial_conditions_AuAu.yaml` and/or `configs/smash_initial_conditions_PbPb.yaml`.
2. Update the event counter (`Nevents`) with the number of events you wish to average over for the initial state.
3. Open the file `CMakeLists.txt` and set the `num_runs` parameter to 1.
4. **Caveat:** For the moment, the addition of spectators to the sampled particle list for the afterburner evolution is not implemented in the case of averaged initial conditions. In the current state, the totality of spectators extracted from all initial SMASH events would be added to each sampled afterburner event. This is of course wrong. For an approximation in central events it might be sufficient to neglect those spectators. This can be achieved by replacing line 97 in `python_scripts/add_spectators.py`: `write_full_particle_list(spectators)` by `write_full_particle_list([])`. <br>
Alternatively, one could modify SMASH in order to print participants as well as spectators to the output file that is used as input in vHLLE, such that they also contribute to the averaged initial state. For this, open the SMASH source file `smash/src/icoutput.cc` and navigate to the function `void ICOutput::at_interaction`. Therein, the statement
```cpp
if (!is_spectator) {
    std::fprintf(file_.get(), "%g %g %g %g %g %g %g %g %s %i \n",
    particle.position().tau(), particle.position()[1],
    particle.position()[2], particle.position().eta(), m_trans,
    particle.momentum()[1], particle.momentum()[2], rapidity,
    particle.pdgcode().string().c_str(), particle.type().charge());
}
```
controls that spectators are not printed to the output. Simply remove the if statement and the corresponding brackets to print all particles to the output. Make sure to re-compile SMASH after this modification and before linking to the hybrid. Additionally, one also needs to replace line 97 in `python_scripts/add_spectators.py`: `write_full_particle_list(spectators)` by `write_full_particle_list([])` to not add the spectators twice.
4. Run `cmake ..` in the build directory.
5. Proceed as usual to run the different steps as described above.

#### Using different kinds of initial condition that are supported by vHLLE
By default, the SMASH-vHLLE-hybrid relies on an initial state from SMASH. In vHLLE however, a number of different initial states are supported. To make use of them, proceed as follows:
1. Open the vHLLE configuration file in `configs/vhlle_hydro`.
2. Update the parameter `icModel` with the number corresponding to the initial state you wish to use. For further information about potential IC models, please consult [vHLLE](https://github.com/yukarpenko/vhlle).
3. If vHLLE requires an external file for the initialization, update line 170 in `CMakeLists.txt`:
```cmake
"-ISinput" "${smash_IC_file}"
```
by replacing the `smash_IC_file` by whichever file you want to use. It might make sense to define a new parameter (similar to `smash_IC_file`) with the path to the respective file, as done for the `smash_IC_file` in line 112. If no external file is required, simply remove/comment line 170.
4. Run `cmake ..` in the build directory.
5. Proceed as usual to run the different steps as described above.

#### Using a different particle sampler
By default, the SMASH-vHLLE-hybrid relies on the SMASH-hadron-sampler for the particlization process. If desired, this sampler can be exchanged by any other. It is however necessary that the created output fulfills the requirement from SMASH for the afterburner evolution. Information about those requirements is provided in the [SMASH user guide](http://theory.gsi.de/~smash/userguide/2.0.2/input_modi_list_.html).
The commands to produce the configuration file and execute the particle sampler are located in lines 183-204 of `CMakeLists.txt`. To exchange this sampler, you may proceed as follows:
1. First, the script `python_scripts/create_sampler_config.py` is executed to create the configuration file which is needed to initialize the sampler execution. If the alternative sampler also requires such a configuration file, you should update the python script accordingly.
2. Second, the sampler itself is executed. This is achieved with the following command in lines 198-204:
```cmake
add_custom_command(OUTPUT ${sampled_particle_list}
COMMAND "${CMAKE_BINARY_DIR}/sampler" "events" "1" "${sampler_updated_config}"
        ">" "${results_folder}/${i}/Sampler/Terminal_Output.txt"
DEPENDS
        "${CMAKE_BINARY_DIR}/sampler"
        "${sampler_updated_config}"
COMMENT "Sampling particles from freezeout hypersurface (${i}/${num_runs})."
)
```
where the lines following 'COMMAND' correspond to whatever one would type in the terminal in order to execute the sampler from there. Note though that ever piece of this command needs to be surrounded by quotation marks within the CMake script.
The 'OUTPUT' command is followed by the path to the output file that is to be created from the sampler. It usually corresponds to the sampled particle list.  Whatever follows 'DEPENDS' are those files/scripts on which the sampler relies. More concretely, this means that the sampler is re-executed if any of the files/scripts mentioned therein are changed. Finally, 'COMMENT' defines a corresponding comment that is printed to the terminal upon execution of the sampler. <br>
To exchange the sampler by a different one, the user may exchange the lines described above by a custom command targeted at executing a different sampler.
3. The sampled particle list is further combined with the spectators, that where not plugged into the hydro evolution in the first place. This is achieved with the script `python_scripts/add_spectators.py`. If desired, update the cmake command in lines 211-219 accordingly, to rely on the sampled particle list obtained from the new sampler.
4. If a combination with spectators is not desired, the command mentioned under 3 can simply be removed. In that case however the path to the particle list that is read in from SMASH for the afterburner evolution needs to be exchanged by the path to the directory, where the list produced with the new sampler is located. This can be achieved by updating line 225 `"-c" "Modi: { List: { File_Directory: ${sampler_dir}} }"` and replacing the variable `${sampler_dir}` with the correct path. Furthermore, the name of the output file (if not identical to the default, which is `sampling0` within the SMASH-vHLLE-hybrid), needs to be updated in the SMASH afterburner config `configs/smash_afterburner.yaml`:
```yaml
Modi:
    List:
        File_Directory: "../build/"
        File_Prefix: "sampling"
        Shift_Id: 0
```

 Note that SMASH expects every file to terminate with a number (see [SMASH user guide](http://theory.gsi.de/~smash/userguide/current/) for further details and background), so make sure to name the file accordingly. If the filename does not end with `0`, you need to update the parameter `Shift_Id` accordingly. The prefix of the file name (that is everything except the number) is controlled by the `File_Prefix` argument and may also require being updated. The `File_Directory` is updated automatically from within the `CMakeLists.txt`.

4. Run `cmake ..` in the build directory and make sure it configures without errors.
5. Proceed as usual to run the different steps as described above.
