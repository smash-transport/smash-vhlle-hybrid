#!/usr/bin/env python3

import argparse
import os
import sys
import textwrap
import time
import yaml

def check_config(valid_config):
    if args.i is None:
        args.i = "./config.yaml"
    if not os.path.exists(args.i):
        print(fatal_error+"The configuration file was expected at './config.yaml', but the file does not exist.")
        sys.exit(1)
    if not valid_config:
        print(fatal_error+"Validation of SMASH input failed.")
        sys.exit(1)
    return

def print_terminal_start():
    print("\nRunning SMASH Afterburner:\n")
    return

def create_folders_structure():
    # if no path is given, create folder structure
    if args.o is None:
        args.o = "./data/"
        if not os.path.exists(args.o):
            os.mkdir(args.o)
        n = 0
        found_folder = False
        while not found_folder:
            if not os.path.exists(args.o + str(n)):
                found_folder = True
            else:
                n += 1
        args.o += str(n)
    # create path if needed
    if not os.path.exists(args.o):
        os.makedirs(args.o)
    # fix format
    if args.o[-1] != "/":
        args.o += "/"
    return

def ensure_no_output_is_overwritten():
    f_config = args.o + "config.yaml"
    if os.path.exists(f_config):
        print(fatal_error + "Output directory would get overwritten. Select a different output directory, clean up, or tell SMASH to ignore existing files.")
        sys.exit(1)
    else:
        # create config file
        f = open(f_config, "w")
        f.close()
    return

def run_smash(finalize,SMASH_input_file_with_participants_and_spectators,sampler_dir):
    # create smash.lock file
    f = open(args.o+file_name_is_running, "w")
    try:
        f_in=open(sampler_dir+SMASH_input_file_with_participants_and_spectators,"r")
        f_in.close()
        print("File read")
    except:
        print(fatal_error+"Sampled particle list could not be opened")
        sys.exit(1)
    f.close()
    # open unfinished particle files
    particles_out_oscar = open(SMASH_output_file_with_participants_and_spectators+name_unfinished, "w")
    particles_out_bin = open(SMASH_special_output_file_for_vHLLE_with_participants_only+name_unfinished, "w")
    # run the black box
    for ts in range(2):
        print("running t = {} fm".format(ts))
        time.sleep(0.5)
    particles_out_oscar.close()
    particles_out_bin.close()

    if finalize:
        finish()
    else:
        print(fatal_error+"crash")
        sys.exit(1)
    return

def finish():
    # rename output by removing the .unfinished file ending
    if os.path.exists(SMASH_output_file_with_participants_and_spectators+name_unfinished):
        os.rename(SMASH_output_file_with_participants_and_spectators+name_unfinished, SMASH_output_file_with_participants_and_spectators)
    else:
        print("somehow the output (.oscar) file was not properly written")
        sys.exit(1)

    if os.path.exists(SMASH_special_output_file_for_vHLLE_with_participants_only+name_unfinished):
        os.rename(SMASH_special_output_file_for_vHLLE_with_participants_only+name_unfinished, SMASH_special_output_file_for_vHLLE_with_participants_only)
    else:
        print("somehow the output file (.bin) was not properly written")
        sys.exit(1)

    # remove smash.lock file
    os.remove(args.o+file_name_is_running)
    return

def parse_command_line_config_options():
    with open(args.i, 'r') as file:
        data_config = yaml.safe_load(file)

    sampler_dir=""
    dir_config=False
    n_events_config=False

    try:
        n_events=data_config['General']['Nevents']
        n_events_config=True
    except:
        print("Nevents could not be parsed")
        sys.exit(1)
    try:
        sampler_dir=data_config['Modi']['List']['File_Directory']
        dir_config=True
    except:
        print("File directory could not be parsed")
        sys.exit(1)

    try:
        file=data_config['Modi']['List']['Filename']
    except:
        print("Filename could not be parsed")
        sys.exit(1)

    if not os.path.isdir(sampler_dir):
        print("Directory '{0}' not found".format(sampler_dir))
        sys.exit(1)

    if sampler_dir != "/":
        sampler_dir += "/"
    return sampler_dir, file


if __name__ == '__main__':
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
                                     epilog=textwrap.dedent('''
                                       Use the BLACK_BOX_FAIL environment variable set to either "invalid_config"
                                       or to "smash_crashes" to mimic a particular failure in the black box.
                                     '''))
    parser.add_argument("-i", required=False,
                        help="File to the config.yaml")
    parser.add_argument("-o", required=False,
                        help="Path to the output folder")
    parser.add_argument("-n", required=False, nargs='?', const='',
                        help="Option to not store the tabulations")

    args = parser.parse_args()

    config_is_valid = os.environ.get('BLACK_BOX_FAIL') != "invalid_config"
    smash_finishes = os.environ.get('BLACK_BOX_FAIL') != "smash_crashes"

    fatal_error = "FATAL         Main        : SMASH failed with the following error:\n\t\t\t    "
    file_name_is_running = "smash.lock"
    name_unfinished = ".unfinished"
    name_oscar = ".oscar"
    name_bin = ".bin"
    name_particles_file = "particle_lists"

    # initialize the system
    check_config(config_is_valid)
    sampler_dir, file =parse_command_line_config_options()
    create_folders_structure()
    ensure_no_output_is_overwritten()

    SMASH_input_file_with_participants_and_spectators = sampler_dir+file
    SMASH_output_file_with_participants_and_spectators = args.o+name_particles_file+name_oscar
    SMASH_special_output_file_for_vHLLE_with_participants_only = args.o+name_particles_file+name_bin

    # smash is now ready to run
    print_terminal_start()
    run_smash(smash_finishes,SMASH_input_file_with_participants_and_spectators,sampler_dir)
