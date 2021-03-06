# The project name
project(annas-hybrid NONE C)

cmake_minimum_required(VERSION 3.5.1)

## Tell cmake where to find the modules
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(FindPythonModules)

find_package(PythonInterp 2.7 REQUIRED)
find_package(PythonLibs 2.7)

find_python_module(numpy VERSION 1.8.2 REQUIRED)
find_python_module(matplotlib VERSION 1.3.1 REQUIRED)
find_python_module(argparse VERSION 1.1 REQUIRED)

# Find and copy SMASH
find_program(SMASH smash PATHS ${SMASH_PATH})
if(NOT SMASH)
    message(FATAL_ERROR
        "SMASH not found. Please specify a path to the SMASH build directory "
        "by passing '-DSMASH_PATH=...' to cmake.")
else()
    message(STATUS "Found SMASH: ${SMASH}")
    # copy executable
    file(COPY ${SMASH} DESTINATION ${CMAKE_BINARY_DIR})
endif()

# Find and copy vHLLE
find_program(vHLLE hlle_visc PATHS ${VHLLE_PATH})
if(NOT vHLLE)
    message(FATAL_ERROR
        "vHLLE not found. Please specify a path to the vHLLE directory "
        "by passing '-DVHLLE_PATH=...' to cmake.")
else()
    message(STATUS "Found vHLLE: ${vHLLE}")
    # copy executable
    file(COPY ${vHLLE} DESTINATION ${CMAKE_BINARY_DIR})
endif()

# find parameters: equations of state
find_path(vHLLE_EoSs eos PATHS ${VHLLE_PARAMS_PATH})
if(NOT vHLLE_EoSs)
    message(FATAL_ERROR
        "Equations of state not found. Please specify a path to the vHLLE params "
        "directory by passing '-DVHLLE_PARAMS_PATH=...' to cmake.")
else()
    message(STATUS "Found EoSs: ${VHLLE_PARAMS_PATH}/eos")
    # copy EoS files
    file(COPY "${VHLLE_PARAMS_PATH}/eos" DESTINATION ${CMAKE_BINARY_DIR})
endif()

# Find and copy sampler
find_program(SAMPLER sampler PATHS ${SAMPLER_PATH})
if(NOT SAMPLER)
    message(FATAL_ERROR
        "Sampler not found. Please specify a path to the Sampler build directory "
        "by passing '-DSAMPLER_PATH=...' to cmake.")
else()
    message(STATUS "Found Sampler: ${SAMPLER}")
    # copy executable
    file(COPY ${SAMPLER} DESTINATION ${CMAKE_BINARY_DIR})
endif()

# Decide whether to automatically analyze the data by means of the
# SMASH-analysis. If so, the path to the analysis suite needs to be passed.
if(SMASH_ANALYSIS_PATH)
   option(WITH_ANALYSIS "Automatically analyze output to yield y, mT, pT, v2, N, ... tables." ON)
endif(SMASH_ANALYSIS_PATH)

if(WITH_ANALYSIS)
  if(SMASH_ANALYSIS_PATH)
    message(STATUS "Found SMASH-analysis: ${SMASH_ANALYSIS_PATH}")
    message(STATUS "Automatic analysis of results is available.")
  else()
    message(WARNING "SMASH-analysis not found. Provide path to SMASH-analysis directory via
    cmake .. -DSMASH_ANALYSIS_PATH=path/to/SMASH_ANALYSIS")
  endif(SMASH_ANALYSIS_PATH)
endif(WITH_ANALYSIS)


#----------------------------------------------------------------------------#
# Function to set up hybrid evolution depending on system and energy
#----------------------------------------------------------------------------#

function(run_one_energy
        energy_and_system
        )
  list(GET energy_and_system 0 energy)
  list(GET energy_and_system 1 system)
  message(STATUS "Configuring hybrid run for ${system} @ sqrt(s) = ${energy} GeV.")
  set(results_folder "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}")
  file(MAKE_DIRECTORY ${results_folder})

  set(smash_IC_files "")
  set(vhlle_freezeout_hypersurfaces "")
  set(sampled_particle_lists "")
  set(final_particle_lists "")
  set(all_analysis_outputs "")
  set(all_plots "")
  set(all_conservation_plots "")

  set(num_runs "100")
  foreach(i RANGE 1 ${num_runs})
    file(MAKE_DIRECTORY "${results_folder}/${i}/IC")       # subdir for initial conditions
    file(MAKE_DIRECTORY "${results_folder}/${i}/Hydro")    # subdir for hydro run
    file(MAKE_DIRECTORY "${results_folder}/${i}/Sampler")  # subdir for particle sampling
    file(MAKE_DIRECTORY "${results_folder}/${i}/Afterburner")  # subdir for afterburner
    file(MAKE_DIRECTORY "${results_folder}/${i}/Spectra")  # subdir for analyzed spectra and plots

    # Set variables for files
    set(smash_IC_file "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/IC/SMASH_IC.dat")
    set(smash_IC_oscar "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/IC/SMASH_IC.oscar")
    set(smash_IC_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/smash_initial_conditions_${system}.yaml")
    set(vhlle_default_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/vhlle_hydro")
    set(vhlle_updated_config "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/Hydro/vhlle_config")
    set(vhlle_freezeout_hypersurface "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/Hydro/freezeout.dat")
    set(sampler_input_hypersurface "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/Sampler/freezeout.dat")
    set(sampler_default_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/hadron_sampler")
    set(sampler_updated_config "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/Sampler/sampler_config")
    set(sampler_dir "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/Sampler")
    set(sampled_particle_list "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/Sampler/particle_lists.oscar")
    set(full_particle_list "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/Sampler/sampling0")
    set(smash_afterburner_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/smash_afterburner.yaml")
    set(final_particle_list "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/Afterburner/particles_binary.bin")

    list(APPEND smash_IC_files ${smash_IC_file})
    list(APPEND vhlle_freezeout_hypersurfaces ${vhlle_freezeout_hypersurface})
    list(APPEND sampled_particle_lists ${sampled_particle_list})
    list(APPEND final_particle_lists ${final_particle_list})

    #----------------------------------------------------------------------------#
    # Run SMASH and generate initial conditions output
    #----------------------------------------------------------------------------#
    add_custom_command(OUTPUT "${smash_IC_file}" "${results_folder}/${i}/config.yaml"
    COMMAND "${CMAKE_BINARY_DIR}/smash"
        "-o" "${results_folder}/${i}/IC"
        "-i" "${smash_IC_config}"
        "-c" "Modi: {Collider: {Sqrtsnn: ${energy}}}"
        "-f"
        ">" "/dev/null"
    DEPENDS
        "${smash_IC_config}"
        "${CMAKE_BINARY_DIR}/smash"
    COMMENT "Running SMASH for Initial Conditions of ${system} @ ${energy} GeV (${i}/${num_runs})."
    )

    #----------------------------------------------------------------------------#
    # Feed SMASH initial conditions into vHLLE and run hydro evolution
    #----------------------------------------------------------------------------#
    # create input file with correct paths for vHLLE
    add_custom_command(OUTPUT "${vhlle_updated_config}"
    COMMAND "python" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/create_vhlle_config.py"
            "--vhlle_config" "${vhlle_default_config}"
            "--smash_ic" "${smash_IC_file}"
            "--output_file" "${vhlle_updated_config}"
    DEPENDS
            "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/create_vhlle_config.py"
            "${vhlle_default_config}"
    COMMENT "Creating input file for vHLLE for ${system} @ ${energy} GeV (${i}/${num_runs})."
    )


    # Run hydro
    add_custom_command(OUTPUT "${vhlle_freezeout_hypersurface}"
    COMMAND "${CMAKE_BINARY_DIR}/hlle_visc"
            "${vhlle_updated_config}"
            ">" "${results_folder}/${i}/Hydro/Terminal_Output.txt"
    DEPENDS
            "${vhlle_updated_config}"
            "${CMAKE_BINARY_DIR}/hlle_visc"
    COMMENT "Running vHLLE for ${system} @ ${energy} GeV (${i}/${num_runs})."
    )

    #----------------------------------------------------------------------------#
    # Run Cooper-Frye sampler for particlization of freezeout surface
    #----------------------------------------------------------------------------#
    # create input file with correct paths for sampler
    set(N_events_afterburner "1000")
    add_custom_command(OUTPUT "${sampler_updated_config}"
    COMMAND "python" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/create_sampler_config.py"
            "--sampler_config" "${sampler_default_config}"
            "--vhlle_config" "${vhlle_updated_config}"
            "--output_file" "${sampler_updated_config}"
            "--Nevents" "${N_events_afterburner}"
    DEPENDS
            "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/create_sampler_config.py"
            "${sampler_default_config}"
    COMMENT "Creating input file for sampler for ${system} @ ${energy} GeV (${i}/${num_runs})."
    )

    # Run sampler
    add_custom_command(OUTPUT ${sampled_particle_list}
    COMMAND "${CMAKE_BINARY_DIR}/sampler" "events" "1" "${sampler_updated_config}"
            ">" "${results_folder}/${i}/Sampler/Terminal_Output.txt"
    DEPENDS
            "${CMAKE_BINARY_DIR}/sampler"
            "${sampler_updated_config}"
    COMMENT "Sampling particles from freezeout hypersurface (${i}/${num_runs})."
    )

    #----------------------------------------------------------------------------#
    # Run SMASH as afterburner
    #----------------------------------------------------------------------------#
    # Add spectators to particle list and rename it to be in accordance
    # with SMASH list modus input format
    add_custom_command(OUTPUT ${full_particle_list}
    COMMAND "python2" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/add_spectators.py"
                      "--sampled_particle_list" "${sampler_dir}/particle_lists.oscar"
                      "--initial_particle_list" "${smash_IC_oscar}"
                      "--output_file" "${full_particle_list}"
    DEPENDS
            "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/add_spectators.py"
    COMMENT "Adding spectators to sampled particle list for afterburner (${i}/${num_runs})."
    )

    # Run afterburner evolution
    add_custom_command(OUTPUT "${final_particle_list}" "${results_folder}/${i}/config.yaml"
    COMMAND "${CMAKE_BINARY_DIR}/smash"
        "-i" "${smash_afterburner_config}"
        "-c" "Modi: { List: { File_Directory: ${sampler_dir}} }"
        "-c" "General: { Nevents: ${N_events_afterburner} }"
        "-o" "${results_folder}/${i}/Afterburner"
        "-f"
        ">" "/dev/null"
    DEPENDS
        "${smash_afterburner_config}"
        "${CMAKE_BINARY_DIR}/smash"
        "${full_particle_list}"
    COMMENT "Running SMASH afterburner for ${system} @ ${energy} GeV (${i}/${num_runs})."
    )

    #----------------------------------------------------------------------------#
    # Analyse data
    #----------------------------------------------------------------------------#
    # Define filenames for particle spectra and create list of those
    set(spectra_fnames "${results_folder}/${i}/Spectra/yspectra.txt" ;
                       "${results_folder}/${i}/Spectra/mtspectra.txt" ;
                       "${results_folder}/${i}/Spectra/ptspectra.txt" ;
                       "${results_folder}/${i}/Spectra/v2spectra.txt" ;
                       "${results_folder}/${i}/Spectra/meanmt0_midrapidity.txt" ;
                       "${results_folder}/${i}/Spectra/meanpt_midrapidity.txt" ;
                       "${results_folder}/${i}/Spectra/midrapidity_yield.txt" ;
                       "${results_folder}/${i}/Spectra/total_multiplicity.txt")
    set(analysis_outputs "")
    foreach(j ${spectra_fnames})
        list(APPEND analysis_outputs "${j}")
    endforeach(j)

    list(APPEND all_analysis_outputs ${analysis_outputs})

    # Perform analysis
    add_custom_command(OUTPUT ${analysis_outputs}
            COMMAND "python2" "${SMASH_ANALYSIS_PATH}/test/energy_scan/mult_and_spectra.py"
                    "--output_files" ${analysis_outputs}
                    "--input_files" "${final_particle_list}"
            COMMENT "Analyzing spectra for ${system} @ ${energy} GeV (${i}/${num_runs})."
            DEPENDS "${SMASH_ANALYSIS_PATH}/test/energy_scan/mult_and_spectra.py"
        )

    #----------------------------------------------------------------------------#
    # Plot spectra
    #----------------------------------------------------------------------------#
    # Define plot names
    set(plot_names "${results_folder}/${i}/Spectra/yspectra.pdf" ;
                   "${results_folder}/${i}/Spectra/mtspectra.pdf" ;
                   "${results_folder}/${i}/Spectra/ptspectra.pdf" ;
                   "${results_folder}/${i}/Spectra/v2spectra.pdf" ;
                   "${results_folder}/${i}/Spectra/meanmt0_midrapidity.pdf" ;
                   "${results_folder}/${i}/Spectra/meanpt_midrapidity.pdf" ;
                   "${results_folder}/${i}/Spectra/midrapidity_yield.pdf" ;
                   "${results_folder}/${i}/Spectra/total_multiplicity.pdf")

    set(plots "")
    foreach(j ${plot_names})
       list(APPEND plots "${j}")
    endforeach(j)

    list(APPEND all_plots ${plots})

    # Perform plotting
    add_custom_command(OUTPUT ${plots}
            COMMAND "python2" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/plot_spectra.py"
                    "--input_files" "${results_folder}/${i}/Spectra/*.txt"
                    "--energy" "${energy}"
                    "--system" "${system}"
                    "--Nevents" "${N_events_afterburner}"
            COMMENT "Plotting spectra for ${system} @ ${energy} GeV (${i}/${num_runs})."
        )



    #----------------------------------------------------------------------------#
    # Check conserved quantities
    #----------------------------------------------------------------------------#
    set(smash_IC_binary "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/IC/SMASH_IC.bin")
    set(output_dir "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/${i}/")
    set(E_cons_plot "${output_dir}/Energy_Conservation.pdf")
    set(Mult_plot "${output_dir}/Pions.pdf")

    list(APPEND all_conservation_plots ${E_cons_plot})
    list(APPEND all_multiplicity_plots ${Mult_plot})
    add_custom_command(OUTPUT ${E_cons_plot}
            COMMAND "python2" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/check_conservation.py"
                    "--SMASH_IC" "${smash_IC_oscar}"
                    "--Hydro_Info" "${results_folder}/${i}/Hydro/Terminal_Output.txt"
                    "--Sampler" "${full_particle_list}"
                    "--SMASH_final_state" "${final_particle_list}"
                    "--SMASH_ana_path" "${SMASH_ANALYSIS_PATH}"
                    "--output_path" "${output_dir}"
                    "--Nevents" "${N_events_afterburner}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/check_conservation.py"
            COMMENT "Checking conservation laws for ${system} @ ${energy} GeV (${i}/${num_runs})."
        )

    add_custom_command(OUTPUT ${Mult_plot}
            COMMAND "python2" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/check_multiplicities.py"
                    "--Freezeout_Surface" "${vhlle_freezeout_hypersurface}"
                    "--Sampler" "${sampled_particle_list}"
                    "--output_path" "${output_dir}"
            DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/check_multiplicities.py"
            COMMENT "Verifying multiplicities for ${system} @ ${energy} GeV (${i}/${num_runs})."
        )



  endforeach(i)

  #----------------------------------------------------------------------------#
  # Average previously obtained spectra
  #----------------------------------------------------------------------------#
  file(MAKE_DIRECTORY "${results_folder}/Averaged_Spectra")
  set(averaged_spectra "${results_folder}/pT.txt" ;
                       "${results_folder}/mT.txt" ;
                       "${results_folder}/dNdy.txt"
                     )
  add_custom_command(OUTPUT ${averaged_spectra}
          COMMAND "python2" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/average_spectra.py"
                  "--pT_files" "${results_folder}/*/Spectra/ptspectra.txt"
                  "--mT_files" "${results_folder}/*/Spectra/mtspectra.txt"
                  "--y_files" "${results_folder}/*/Spectra/yspectra.txt"
                  "--Nevents" "${N_events_afterburner}"
                  "--output_dir" "${results_folder}/Averaged_Spectra/"
          COMMENT "Averaging spectra for ${system} @ ${energy} GeV."
      )

  #----------------------------------------------------------------------------#
  # Plot averaged quantities
  #----------------------------------------------------------------------------#
  set(averaged_plots "${results_folder}/Averaged_Spectra/yspectra.pdf" ;
                     "${results_folder}/Averaged_Spectra/mtspectra.pdf" ;
                     "${results_folder}/Averaged_Spectra/ptspectra.pdf")

  # Perform plotting of averaged quantities
  add_custom_command(OUTPUT ${averaged_plots}
          COMMAND "python2" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/plot_spectra.py"
                  "--input_files" "${results_folder}/Averaged_Spectra/*.txt"
                  "--energy" "${energy}"
                  "--system" "${system}"
                  "--Nevents" "${N_events_afterburner}"
                  "--average" "True"
          COMMENT "Plotting averaged spectra for ${system} @ ${energy} GeV."
      )


  # Define subtargets to enable separated running of the hybrid submodules
  set(target ${system}_${energy}_afterburner)
  add_custom_target(${target} ALL DEPENDS ${final_particle_lists})

  set(target ${system}_${energy}_IC)
  add_custom_target(${target} ALL DEPENDS ${smash_IC_files})

  set(target ${system}_${energy}_hydro)
  add_custom_target(${target} ALL DEPENDS ${vhlle_freezeout_hypersurfaces})

  set(target ${system}_${energy}_sampler)
  add_custom_target(${target} ALL DEPENDS ${sampled_particle_lists})

  set(target ${system}_${energy}_analysis)
  add_custom_target(${target} ALL DEPENDS ${all_analysis_outputs})

  set(target ${system}_${energy}_plots)
  add_custom_target(${target} ALL DEPENDS ${all_plots})

  set(target ${system}_${energy}_check_conservation)
  add_custom_target(${target} ALL DEPENDS ${all_conservation_plots})

  set(target ${system}_${energy}_check_multiplicities)
  add_custom_target(${target} ALL DEPENDS ${all_multiplicity_plots})

  # Averaging
  set(target ${system}_${energy}_average_spectra)
  add_custom_target(${target} ALL DEPENDS ${averaged_spectra})

  set(target ${system}_${energy}_average_plots)
  add_custom_target(${target} ALL DEPENDS ${averaged_plots})

endfunction()

run_one_energy("7.7;AuAu")
run_one_energy("8.8;AuAu")
run_one_energy("39.0;AuAu")
run_one_energy("200.0;AuAu")
run_one_energy("17.3;PbPb")
