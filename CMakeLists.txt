# The project name
project(annas-hybrid NONE C)

cmake_minimum_required(VERSION 3.5.1)

## Tell cmake where to find the modules
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake")
include(FindPythonModules)

find_package(PythonInterp 2.7 REQUIRED)
find_package(PythonLibs 2.7)

find_python_module(numpy VERSION 1.14.0 REQUIRED)
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
    # copy EoS files
    file(COPY "${VHLLE_PATH}/eos" DESTINATION ${CMAKE_BINARY_DIR})
endif()

# Find and copy sampler
find_program(SAMPLER mpiCooperFrye.x86_64 PATHS ${SAMPLER_PATH})
if(NOT SAMPLER)
    message(FATAL_ERROR
        "Sampler not found. Please specify a path to the Sampler directory "
        "by passing '-DSAMPLER_PATH=...' to cmake.")
else()
    message(STATUS "Found Sampler: ${SAMPLER}")
    # copy executable
    file(COPY ${SAMPLER} DESTINATION ${CMAKE_BINARY_DIR})
    # copy EoS files
    file(COPY "${SAMPLER_PATH}/EOS" DESTINATION ${CMAKE_BINARY_DIR})
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

# Decide whether to plot experimental data as well. Note that in this case,
# the path to the experimental_data directory needs to be passed
if(EXP_DATA)
   option(WITH_EXP_DATA "Plot experimental data points as well." ON)
endif(EXP_DATA)

if(WITH_EXP_DATA)
  if(EXP_DATA)
    message(STATUS "Found experimental data: ${EXP_DATA}")
    message(STATUS "Comparison to experimental measurements will be plotted.")
  else()
    message(WARNING "Experimental data not found and will not be plotted. Provide path to experimental_data directory via
                     cmake .. -DEXP_DATA=path/to/exp/data")
  endif(EXP_DATA)
endif(WITH_EXP_DATA)



function(run_one_energy
        energy_and_system
        )
  list(GET energy_and_system 0 energy)
  list(GET energy_and_system 1 system)
  message(STATUS "Configuring hybrid run for ${system} @ sqrt(s) = ${energy} GeV.")
  set(results_folder "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}")
  file(MAKE_DIRECTORY ${results_folder})
  file(MAKE_DIRECTORY "${results_folder}/IC")       # subdir for initial conditions
  file(MAKE_DIRECTORY "${results_folder}/Hydro")    # subdir for hydro run
  file(MAKE_DIRECTORY "${results_folder}/Sampler")  # subdir for particle sampling
  file(MAKE_DIRECTORY "${results_folder}/Afterburner")  # subdir for afterburner
  file(MAKE_DIRECTORY "${results_folder}/Spectra")  # subdir for analyzed spectra

  # Set variables for files
  set(smash_IC_file "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/IC/SMASH_IC.dat")
  set(smash_IC_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/${system}_${energy}GeV/smash_initial_conditions.yaml")
  set(vhlle_default_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/${system}_${energy}GeV/vhlle_hydro")
  set(vhlle_updated_config "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/Hydro/vhlle_config")
  set(vhlle_freezeout_hypersurface "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/Hydro/freezeout.dat")
  set(sampler_input_hypersurface "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/Sampler/freezeout.dat")
  set(sampler_dir "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/Sampler")
  set(sampled_particle_list "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/Sampler/sampling0")
  set(smash_afterburner_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/${system}_${energy}GeV/smash_afterburner.yaml")
  set(final_particle_list "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/Afterburner/particles_binary.bin")


  #----------------------------------------------------------------------------#
  # Run SMASH and generate initial conditions output
  #----------------------------------------------------------------------------#
  add_custom_command(OUTPUT "${smash_IC_file}" "${data_folder}/config.yaml"
  COMMAND "${CMAKE_BINARY_DIR}/smash"
      "-o" "${results_folder}/IC"
      "-i" "${smash_IC_config}"
      "-f"
  #    ">" "/dev/null"
  DEPENDS
      "${smash_IC_config}"
      "${CMAKE_BINARY_DIR}/smash"
  COMMENT "Running SMASH for Initial Conditions of ${system} @ ${energy} GeV."
  )

  # create input file with correct paths for vHLLE
  add_custom_command(OUTPUT "${vhlle_updated_config}"
  COMMAND "python" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/create_vhlle_config.py"
          "--vhlle_config" "${vhlle_default_config}"
          "--smash_ic" "${smash_IC_file}"
          "--output_file" "${vhlle_updated_config}"
  DEPENDS
          "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/create_vhlle_config.py"
          "${vhlle_default_config}"
  COMMENT "Creating input file for vHLLE for ${system} @ ${energy} GeV."
  )


  #----------------------------------------------------------------------------#
  # Feed SMASH initial conditions into vHLLE and run hydro evolution
  #----------------------------------------------------------------------------#
  add_custom_command(OUTPUT "${vhlle_freezeout_hypersurface}"
  COMMAND "${CMAKE_BINARY_DIR}/hlle_visc"
          "${vhlle_updated_config}"
  DEPENDS
          "${vhlle_updated_config}"
          "${CMAKE_BINARY_DIR}/hlle_visc"
  COMMENT "Running vHLLE for ${system} @ ${energy} GeV."
  )

  # Extract only those cells from hypersurface with non-zero temperature and
  # pressure
  add_custom_command(OUTPUT ${sampler_input_hypersurface}
  COMMAND "python" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/extract_hypersurface_contributions.py"
          "--vhlle_hypersurface" "${vhlle_freezeout_hypersurface}"
          "--output_file" "${sampler_input_hypersurface}"
  DEPENDS
          "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/extract_hypersurface_contributions.py"
  COMMENT "Removing hypersurface patches with T = p = 0."
  )

  #----------------------------------------------------------------------------#
  # Run Cooper-Frye sampler for particlization of freezeout surface
  #----------------------------------------------------------------------------#
  set(N_events_afterburner "2000")
  add_custom_command(OUTPUT ${sampled_particle_list}
  COMMAND "mpirun" "-n" "4" "${CMAKE_BINARY_DIR}/mpiCooperFrye.x86_64"
          "${sampler_input_hypersurface}" "${N_events_afterburner}"
          "${sampler_dir}"
  DEPENDS
          "${CMAKE_BINARY_DIR}/mpiCooperFrye.x86_64"
          "${sampler_input_hypersurface}"
  COMMENT "Sampling particles from freezeout hypersurface."
  )

  #----------------------------------------------------------------------------#
  # Run SMASH as afterburner
  #----------------------------------------------------------------------------#

  add_custom_command(OUTPUT "${final_particle_list}" "${data_folder}/config.yaml"
  COMMAND "${CMAKE_BINARY_DIR}/smash"
      "-i" "${smash_afterburner_config}"
      "-c" "Modi: { List: { File_Directory: ${sampler_dir}} }"
      "-c" "General: { Nevents: ${N_events_afterburner} }"
      "-o" "${results_folder}/Afterburner"
      "-f"
  #    ">" "/dev/null"
  DEPENDS
      "${smash_afterburner_config}"
      "${CMAKE_BINARY_DIR}/smash"
  COMMENT "Running SMASH afterburner for ${system} @ ${energy} GeV."
  )

  #----------------------------------------------------------------------------#
  # Analyse data
  #----------------------------------------------------------------------------#

  # Define filenames for particle spectra and create list of those
  set(spectra_fnames "${results_folder}/Spectra/yspectra.txt" ;
                     "${results_folder}/Spectra/mtspectra.txt" ;
                     "${results_folder}/Spectra/ptspectra.txt" ;
                     "${results_folder}/Spectra/v2spectra.txt" ;
                     "${results_folder}/Spectra/meanmt0_midrapidity.txt" ;
                     "${results_folder}/Spectra/meanpt_midrapidity.txt" ;
                     "${results_folder}/Spectra/midrapidity_yield.txt" ;
                     "${results_folder}/Spectra/total_multiplicity.txt")
  set(analysis_outputs "")
  foreach(j ${spectra_fnames})
      list(APPEND analysis_outputs "${j}")
  endforeach(j)

  # Perform analysis
  add_custom_command(OUTPUT ${analysis_outputs}
          COMMAND "python2" "${SMASH_ANALYSIS_PATH}/test/energy_scan/mult_and_spectra.py"
                  "--output_files" ${analysis_outputs}
                  "--input_files" "${final_particle_list}"
          COMMENT "Analyzing spectra for ${system} @ ${energy} GeV."
          DEPENDS "${SMASH_ANALYSIS_PATH}/test/energy_scan/mult_and_spectra.py"
      )

  #----------------------------------------------------------------------------#
  # Plot spectra
  #----------------------------------------------------------------------------#
  # Define plot names
  set(plot_names "${results_folder}/Spectra/yspectra.pdf" ;
                     "${results_folder}/Spectra/mtspectra.pdf" ;
                     "${results_folder}/Spectra/ptspectra.pdf" ;
                     "${results_folder}/Spectra/v2spectra.pdf" ;
                     "${results_folder}/Spectra/meanmt0_midrapidity.pdf" ;
                     "${results_folder}/Spectra/meanpt_midrapidity.pdf" ;
                     "${results_folder}/Spectra/midrapidity_yield.pdf" ;
                     "${results_folder}/Spectra/total_multiplicity.pdf")

  set(plots "")
  foreach(j ${plot_names})
     list(APPEND plots "${j}")
  endforeach(j)

  # Perform plotting
  add_custom_command(OUTPUT ${plots}
          COMMAND "python2" "${CMAKE_CURRENT_SOURCE_DIR}/python_scripts/plot_spectra.py"
                  "--input_files" "${results_folder}/Spectra/*.txt"
                  "--energy" "${energy}"
                  "--system" "${system}"
                  "--Nevents" "${N_events_afterburner}"
          COMMENT "Plotting spectra for ${system} @ ${energy} GeV."
      )

  # Define subtargets to enable separated running of the hybrid submodules
  set(target ${system}_${energy}_IC)
  add_custom_target(${target} ALL DEPENDS ${smash_IC_file})

  set(target ${system}_${energy}_hydro)
  add_custom_target(${target} ALL DEPENDS ${vhlle_freezeout_hypersurface})

  set(target ${system}_${energy}_sampler)
  add_custom_target(${target} ALL DEPENDS ${sampled_particle_list} ${sampler_input_hypersurface})

  set(target ${system}_${energy}_afterburner)
  add_custom_target(${target} ALL DEPENDS ${final_particle_list})

  set(target ${system}_${energy}_analysis)
  add_custom_target(${target} ALL DEPENDS ${analysis_outputs})

  set(target ${system}_${energy}_plots)
  add_custom_target(${target} ALL DEPENDS ${plots})

endfunction()

run_one_energy("8.8;AuAu")
