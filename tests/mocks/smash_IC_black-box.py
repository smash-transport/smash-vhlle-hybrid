#!/usr/bin/env python3

import argparse
import os
import shutil
import sys
import textwrap
import time

ic_version = os.environ.get("MOCK_IC_VERSION", "3.2")

def print_version_and_exit_if_requested():
    if args.version:
        print(f"SMASH-{ic_version}")
        sys.exit(0)

def check_config(valid_config):
    if args.i is None:
        args.i = "./config.yaml"
    if not os.path.exists(args.i):
        print(fatal_error + "The configuration file was expected at '" + args.i + "', but the file does not exist.")
        sys.exit(1)
    if not valid_config:
        print(fatal_error + "Validation of SMASH input failed.")
        sys.exit(1)
    return

def print_terminal_start():
    print("\nRunning SMASH IC:\n")
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

def validate_output_folder():
    f_config = args.o + "config.yaml"
    if os.path.exists(f_config):
        print(fatal_error + "Output directory would get overwritten. Select a different output directory, clean up, or tell SMASH to ignore existing files.")
        sys.exit(1)
    else:
        # create config file copying input one to output folder
        shutil.copy(args.i, f_config)
    return

def run_smash(finalize):
    # create smash.lock file
    f = open(args.o+file_name_is_running, "w")
    f.close()
    # open unfinished particle files
    particles_out_oscar = open(SMASH_output_file_with_participants_and_spectators+name_unfinished, "w")
    particles_out_dat = open(SMASH_special_output_file_for_vHLLE_with_participants_only+name_unfinished, "w")
    # run the black box
    for ts in range(1,11):
        print("running t = {} fm".format(ts))
        time.sleep(0.1)
    particles_out_oscar.close()
    particles_out_dat.close()

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
        print("somehow the output file (.dat) was not properly written")
        sys.exit(1)

    # remove smash.lock file
    os.remove(args.o+file_name_is_running)
    return

if __name__ == '__main__':
    parser = argparse.ArgumentParser(formatter_class=argparse.RawTextHelpFormatter,
                                     epilog=textwrap.dedent('''
                                       Use the BLACK_BOX_FAIL environment variable set to either "invalid_config"
                                       or to "smash_crashes" to mimic a particular failure in the black box.
                                     '''))
    parser.add_argument("--version", required=False, action='store_true',
                        help="Print version and exit")
    parser.add_argument("-i", required=False,
                        help="File to the config.yaml")
    parser.add_argument("-o", required=False,
                        help="Path to the output folder")
    parser.add_argument("-c", required=False,
                        help="Make changes to config.yaml (this is not tested here)")
    parser.add_argument("-n", required=False, default=False, action='store_true',
                        help="As SMASH -n (this is not affecting any behavior here)")
    args = parser.parse_args()

    config_is_valid = os.environ.get('BLACK_BOX_FAIL') != "invalid_config"
    smash_finishes = os.environ.get('BLACK_BOX_FAIL') != "smash_crashes"

    fatal_error = "FATAL         Main        : SMASH failed with the following error:\n\t\t\t    "
    file_name_is_running = "smash.lock"
    name_unfinished = ".unfinished"
    name_oscar = ".oscar"
    name_dat = ".dat"
    name_particles_file = "SMASH_IC"

    print_version_and_exit_if_requested()

    # initialize the system
    check_config(config_is_valid)
    create_folders_structure()
    validate_output_folder()

    SMASH_output_file_with_participants_and_spectators = args.o+name_particles_file+name_oscar
    SMASH_special_output_file_for_vHLLE_with_participants_only = args.o+name_particles_file+name_dat

    # smash is now ready to run
    print_terminal_start()
    run_smash(smash_finishes)
