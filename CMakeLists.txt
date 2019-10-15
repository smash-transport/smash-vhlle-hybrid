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
# find_program(SAMPLER samplerCooperFrye PATHS ${SAMPLER_PATH})
# if(NOT SAMPLER)
#     message(FATAL_ERROR
#         "Sampler not found. Please specify a path to the Sampler directory "
#         "by passing '-DSAMPLER_PATH=...' to cmake.")
# else()
#     message(STATUS "Found Sampler: ${SAMPLER}")
#     # copy executable
#     file(COPY ${SAMPLER} DESTINATION ${CMAKE_BINARY_DIR})
# endif()


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
  add_custom_command(OUTPUT ${sampled_particle_list}
  COMMAND "mpirun -n 10" "${CMAKE_BINARY_DIR}/mpiCooperFrye.x86_64"
          "${sampler_input_hypersurface}" "2000"
          "${sampler_dir}"
  DEPENDS
          "${CMAKE_BINARY_DIR}/mpiCooperFrye.x86_64"
  COMMENT "Sampling particles from freezeout hypersurface."
  )

  #----------------------------------------------------------------------------#
  # Run SMASH as afterburner
  #----------------------------------------------------------------------------#

  add_custom_command(OUTPUT "${smash_IC_file}" "${data_folder}/config.yaml"
  COMMAND "${CMAKE_BINARY_DIR}/smash"
      "-i" "${smash_afterburner_config}"
      "-c" "Modi: { List: { File_Directory: ${sampler_dir}} }"
      "-o" "${results_folder}/Afterburner"
      "-f"
  #    ">" "/dev/null"
  DEPENDS
      "${smash_afterburner_config}"
      "${CMAKE_BINARY_DIR}/smash"
  COMMENT "Running SMASH afterburner for ${system} @ ${energy} GeV."
  )

  # Define subtargets to enable separated running of the hybrid submodules
  set(target ${system}_${energy}_IC)
  add_custom_target(${target} ALL DEPENDS ${smash_IC_file})

  set(target ${system}_${energy}_hydro)
  add_custom_target(${target} ALL DEPENDS ${vhlle_freezeout_hypersurface})

  set(target ${system}_${energy}_sampler)
  add_custom_target(${target} ALL DEPENDS ${sampler_input_hypersurface})

  set(target ${system}_${energy}_afterburner)
  add_custom_target(${target} ALL DEPENDS ${final_particle_list})

endfunction()

run_one_energy("8.8;AuAu")
