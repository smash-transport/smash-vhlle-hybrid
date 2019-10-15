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
endif()

# Find and copy sampler
find_program(SAMPLER samplerCooperFrye PATHS ${SAMPLER_PATH})
if(NOT SAMPLER)
    message(FATAL_ERROR
        "Sampler not found. Please specify a path to the Sampler directory "
        "by passing '-DSAMPLER_PATH=...' to cmake.")
else()
    message(STATUS "Found Sampler: ${SAMPLER}")
    # copy executable
    file(COPY ${SAMPLER} DESTINATION ${CMAKE_BINARY_DIR})
endif()


function(run_one_energy
        energy_and_system
        )
  list(GET energy_and_system 0 energy)
  list(GET energy_and_system 1 system)
  message(STATUS "Configuring hybrid run for ${system} @ sqrt(s) = ${energy} GeV.")
  set(results_folder "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}")
  file(MAKE_DIRECTORY ${results_folder})
  file(MAKE_DIRECTORY "${results_folder}/Hydro")  #subdir for hydro run

  set(smash_IC_file "${CMAKE_CURRENT_BINARY_DIR}/Hybrid_Results/${system}_${energy}/SMASH_IC.dat")
  set(smash_IC_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/${system}_${energy}GeV/smash_initial_conditions.yaml")
  set(vhlle_config "${CMAKE_CURRENT_SOURCE_DIR}/configs/${system}_${energy}GeV/vhlle_hydro")


  # Run SMASH and generate initial conditions output
  add_custom_command(OUTPUT "${smash_IC_file}" "${data_folder}/config.yaml"
          COMMAND "${CMAKE_BINARY_DIR}/smash"
              "-o" "${results_folder}/IC"
              "-i" "${smash_IC_config}"
              "-f"
          #    ">" "/dev/null"
          DEPENDS
              "${smash_IC_config}"
              "${CMAKE_BINARY_DIR}/smash"
          WORKING_DIRECTORY ${test_folder}
          COMMENT "Running SMASH for Initial Conditions of ${system} @ ${energy} GeV."
      )

  # Feed SMASH initial conditions into vHLLE


  set(target ${system}_${energy}_IC)
  add_custom_target(${target} ALL DEPENDS ${smash_IC_file})

endfunction()





run_one_energy("8.8;AuAu")
