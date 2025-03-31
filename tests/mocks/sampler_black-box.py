#!/usr/bin/env python3

# README:
# If the environment variable BLACK_BOX_TYPE_SAMPLER is set to "FIST", the script is called like:
#
#     ./sampler_black-box path_to_config_file
#
# with:
# - path_to_config_file: Path to the sampler configuration
#
# otherwise
#
#  version < 3.2:
#     ./sampler_black-box events num path_to_config_file
#  version >= 3.2:
#     ./sampler_black-box --config path_to_config_file --num num
#
# with:
# - events: This is not a variable. This must be the string 'events'
# - num: random number set by the user. In hybrid NUM=1
# - path_to_config_file: Path to the sampler configuration
#
# How it works:
# The sampler black box starts by checking if the sampler config exists.
# The FIST sampler additionally checks for two more files: decays_list_file and particle_list_file.
# If it is the case, it gets the path to the freezeout hypersurface and the output
# directory from the config and checks that also the freezeout surface exists.
#
# Use the BLACK_BOX_FAIL environment variable set to "true"
# to mimic a particular failure in the black box.
#
# If it got everything correctly, it will produce a dummy terminal output and
# a) particle_lists.oscar in the output directory if the optional argument is not given
# b) nothing if the BLACK_BOX_FAIL environment variable is set to "true"
#
# Use the MOCK_HADRON_SAMPLER_VERSION environment variable to set the sampler version
# behavior which is mimicking the different real sampler versions.

import sys
import os
import time
import random
import numpy as np
from packaging.version import Version

sampler_version = os.environ.get("MOCK_HADRON_SAMPLER_VERSION", "3.1.1")

def print_version_and_exit_if_requested():
    if sys.argv[1] == '--version':
        print(sampler_version)
        sys.exit(0)

def check_input_arguments(mode):
    """
    Depending on the mode (FIST vs SMASH), validate command-line arguments.

    FIST mode expects:
        ./merged_black_box.py path_to_config_file

    SMASH mode expects:
        ./merged_black_box.py events num path_to_config_file
    """
    if mode == 'FIST':
        calling_instruction = (
            "Call the sampler black box by:\n\n"
            "./merged_black_box.py [ENV VARS] path_to_config_file \n\n"
            "- path_to_config_file: Path to the sampler configuration\n"
        )
        if len(sys.argv) != 2:
            print("Invalid number of arguments!\n" + calling_instruction)
            sys.exit(1)

    else:
        if Version(sampler_version) < Version("3.2"):
            calling_instruction = (
                "Call the sampler black box by:\n\n"
                "./sampler_black-box.py events num path_to_config_file\n\n"
                "- events: Must be the string 'events'\n"
                "- num: random number set by the user (e.g., 1)\n"
                "- path_to_config_file: Path to the sampler configuration\n"
            )
            if not (4 <= len(sys.argv) <= 5):
                print("Invalid number of arguments!\n" + calling_instruction)
                sys.exit(1)
            elif sys.argv[1] != 'events':
                print("Invalid first argument!\nThe first argument must be 'events'\n" + calling_instruction)
                sys.exit(1)
        else:
            calling_instruction = (
                "Call the sampler black box by:\n\n"
                "./sampler_black-box.py --config path_to_config_file --num num\n\n"
                "- --num and --config are literal strings\n"
                "- num: random number set by the user (e.g., 1)\n"
                "- path_to_config_file: Path to the sampler configuration\n"
            )
            if len(sys.argv) != 5:
                print("Invalid number of arguments!\n" + calling_instruction)
                sys.exit(1)

def check_if_file_exists(path, mode, ftype=None):
    """
    Checks if the file (path) exists. In FIST mode, prints specialized error messages
    depending on ftype. In SMASH mode, prints a generic message.
    """
    if mode == 'FIST':
        if not os.path.isfile(path):
            if ftype == "hypersurface":
                print(f"Hypersurface file  {path} not found! \n Empty hypersurface! Aborting...")
            elif ftype == "decays":
                print("**WARNING** rho0 (113): Particle marked unstable but no decay channels found!")
                sys.exit(1)
            elif ftype == "particle":
                print("Segmentation fault")
            elif ftype == "config":
                print("Hypersurface file surface_eps_0.26.dat not found!")
            else:
                print(f"File not found: {path}")
            sys.exit(1)
    else:
        if not os.path.isfile(path):
            print(f"File not found at given path: {path}")
            sys.exit(1)

def check_if_directory_exists(path):
    if not os.path.isdir(path):
        err_msg = path + ' is not a valid directory or does not exist!'
        print(err_msg)
        sys.exit(1)

def get_first_two_fields_in_line(line_in_config):
    #deleting the last character to omit the newline character '\n'
    line_in_config = line_in_config[:-1].split(' ')
    splitted_line_in_config = list(filter(None, line_in_config))
    splitted_line_in_config[0]=str(splitted_line_in_config[0])
    splitted_line_in_config[1]=str(splitted_line_in_config[1])
    return splitted_line_in_config

def get_value_as_string_from_config_by_keyword(path_to_config, keyword, custom_error=None):
    """
    Retrieves the config value for the given keyword from a simple 2-column config file.
    If the keyword is not found, prints custom_error (if given) or a default error.
    """
    with open(path_to_config, "r") as file_in:
        for line in file_in:
            key_in_line, val_in_line = get_first_two_fields_in_line(line)
            if key_in_line == keyword:
                return val_in_line
    if custom_error:
        print(custom_error)
    else:
        print(f"Keyword '{keyword}' not found in config file!")
    sys.exit(1)

def make_fake_run(mode):
    if mode == 'FIST':
        print("\nRunning FIST-Sampler:\n")
    else:
        print(f"\nRunning SMASH-Sampler v{sampler_version}:\n")
    for i in range(11):
        print('Fake computational progress: ', int(10*i), '%')
        time.sleep(0.1)

def create_output_file(mode, outpath):
    """
    A single function to create the Oscar2013 output file.
    The only difference is the header, chosen by the mode.
    Otherwise, the generation of random lines is the same.
    """
    if mode == 'FIST':
        header = (
            "#!OSCAR2013 particle_lists t x y z mass p0 px py pz pdg ID charge\n"
            "# Units: fm fm fm fm GeV GeV GeV GeV GeV none none e\n"
            "# FISTSampler\n"
        )
        out_filename = outpath
    else:
        header = (
            "#!OSCAR2013 particle_lists t x y z mass p0 px py pz pdg ID charge\n"
            "# Units: fm fm fm fm GeV GeV GeV GeV GeV none none e\n"
            "# SMASH-3.0-1-g0985d6b3\n"
        )
        # SMASH mode expects 'outpath' to be a directory
        # so we produce 'particle_lists.oscar' inside that directory
        out_filename = os.path.join(outpath, 'particle_lists.oscar')

    with open(out_filename, "w") as f:
        f.write(header)

    # Append random events
    format_oscar2013 = "%g %g %g %g %g %g %g %g %g %d %d %d"
    with open(out_filename, "a") as f_out:
        for counter_event in range(4):
            num_output_of_event = random.randint(10, 20)
            output_event = []
            for _ in range(num_output_of_event):
                t = 200.0
                x = 0.1 * random.randint(-1000, 1000)
                y = 0.1 * random.randint(-1000, 1000)
                z = 0.1 * random.randint(-1000, 1000)
                mass = 0.1 * random.randint(0, 100)
                p0 = 0.001 * random.randint(0, 10000)
                px = 0.001 * random.randint(-10000, 10000)
                py = 0.001 * random.randint(-100, 10000)
                pz = 0.001 * random.randint(-10000, 10000)
                pdg = random.randint(0, 10000)
                ID = random.randint(0, 100)
                charge = random.randint(-2, 2)
                output_line = [t, x, y, z, mass, p0, px, py, pz, pdg, ID, charge]
                output_event.append(output_line)

            output_event = np.asarray(output_event)
            f_out.write(f'# event {counter_event} out {num_output_of_event}\n')
            np.savetxt(f_out, output_event, delimiter=' ', newline='\n', fmt=format_oscar2013)
            f_out.write(f'# event {counter_event} end 0 impact   0.000 scattering_projectile_target yes\n')

####################   End Definitions   ####################

def run_black_box():
    """
    Main function that:
      0. If the --version option was given, print it and exit
      1. Detects the mode from BLACK_BOX_TYPE_SAMPLER.
      2. Checks command-line arguments depending on the mode.
      3. Reads config to get freezeout and output info.
      4. Checks for required files/dirs.
      5. Possibly simulates a crash (BLACK_BOX_FAIL='true').
      6. If not crashed, does the fake run and output creation.
    """
    print_version_and_exit_if_requested()

    mode = os.environ.get("BLACK_BOX_TYPE_SAMPLER", "SMASH").upper()
    if mode not in ["FIST", "SMASH"]:
        print("Unknown mode in BLACK_BOX_TYPE! Use 'FIST' or 'SMASH'.")
        sys.exit(1)

    check_input_arguments(mode)

    # Distinguish how we read the config file
    if mode == 'FIST':
        path_to_config = sys.argv[1]
        check_if_file_exists(path_to_config, 'FIST', "config")
        path_to_freezeout = get_value_as_string_from_config_by_keyword(
            path_to_config,
            'hypersurface_file',
            "Keyword 'hypersurface_file' not in config!"
        )
        output_file = get_value_as_string_from_config_by_keyword(
            path_to_config,
            'output_file',
            "Keyword 'output_file' not in config!"
        )
        decays_file = get_value_as_string_from_config_by_keyword(
            path_to_config,
            'decays_list_file',
            "Keyword 'decays_list_file' not in config!"
        )
        particle_file = get_value_as_string_from_config_by_keyword(
            path_to_config,
            'particle_list_file',
            "Keyword 'particle_list_file' not in config!"
        )
        check_if_file_exists(path_to_freezeout, 'FIST', "hypersurface")
        check_if_file_exists(decays_file, 'FIST', "decays")
        check_if_file_exists(particle_file, 'FIST', "particle")
        outpath = output_file

    else:
        if Version(sampler_version) < Version("3.2"):
            path_to_config = sys.argv[3]
            check_if_file_exists(path_to_config, 'SMASH')
            path_to_freezeout = get_value_as_string_from_config_by_keyword(
                path_to_config,
                'surface',
                "Keyword 'surface' not in config!"
            )
            output_dir = get_value_as_string_from_config_by_keyword(
                path_to_config,
                'spectra_dir',
                "Keyword 'spectra_dir' not in config!"
            )
        else:
            path_to_config = sys.argv[2]
            check_if_file_exists(path_to_config, 'SMASH')
            path_to_freezeout = get_value_as_string_from_config_by_keyword(
                path_to_config,
                'surface_file',
                "Keyword 'surface_file' not in config!"
            )
            output_dir = get_value_as_string_from_config_by_keyword(
                path_to_config,
                'output_dir',
                "Keyword 'output_dir' not in config!"
            )
        check_if_file_exists(path_to_freezeout, 'SMASH')
        check_if_directory_exists(output_dir)
        outpath = output_dir

    # Crash logic
    if os.environ.get("BLACK_BOX_FAIL") == "true":
        print("Sampler black-box crashed!")
        sys.exit(1)

    # Otherwise proceed with a normal run
    make_fake_run(mode)
    create_output_file(mode, outpath)

if __name__ == "__main__":
    run_black_box()
