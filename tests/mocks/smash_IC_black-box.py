#!/usr/bin/env python3

import argparse
import os
import sys
import time

def check_config(valid_config):
    if args.i is None:
        args.i = "./config.yaml"
    if not os.path.exists(args.i):
        print(fatal_error+"The configuration file was expected at './config.yaml', but the file does not exist.")
        sys.exit()
    if not valid_config:
        print(fatal_error+"Validation of SMASH input failed.")
        sys.exit()
    return

def print_terminal_start():
    # generated with https://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
    Terminal_Out = "###########################################################################################################\n      _________   _____      _____    _________ ___ ___   \n     /   _____/  /     \    /  _  \  /   _____//   |   \  \n     \_____  \  /  \ /  \  /  /_\  \ \_____  \/    ~    \ \n     /        \/    Y    \/    |    \/        \    Y    / \n    /_______  /\____|__  /\____|__  /_______  /\___|_  /  \n             \/         \/         \/        \/       \/  \n                                  .__           ___.         .__    .___                                \n     ____   ______  _  __         |  |__ ___.__.\_ |_________|__| __| _/          ________________      \n    /    \_/ __ \ \/ \/ /  ______ |  |  <   |  | | __ \_  __ \  |/ __ |  ______ _/ __ \_  __ \__  \     \n   |   |  \  ___/\     /  /_____/ |   Y  \___  | | \_\ \  | \/  / /_/ | /_____/ \  ___/|  | \// __ \_   \n   |___|  /\___  >\/\_/           |___|  / ____| |___  /__|  |__\____ |          \___  >__|  (____  /   \n        \/     \/                      \/\/          \/              \/              \/           \/    \n     ___ .____________             ___.   .__                 __   ___.                  ___    \n    /  / |   \_   ___ \            \_ |__ |  | _____    ____ |  | _\_ |__   _______  ___ \  \   \n   /  /  |   /    \  \/    ______   | __ \|  | \__  \ _/ ___\|  |/ /| __ \ /  _ \  \/  /  \  \  \n  (  (   |   \     \____  /_____/   | \_\ \  |__/ __ \\  \___|    < | \_\ (  <_> >    <    )  ) \n   \  \  |___|\______  /            |___  /____(____  /\___  >__|_ \|___  /\____/__/\_ \  /  /  \n    \__\             \/                 \/          \/     \/     \/    \/            \/ /__/  \n ###########################################################################################################\n"
    print(Terminal_Out)
    print("running smash IC")
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

def check_if_empty_output():
    f_config = args.o + "config.yaml"
    if os.path.exists(f_config):
        print(fatal_error + "Output directory would get overwritten. Select a different output directory, clean up, or tell SMASH to ignore existing files.")
        sys.exit()
    else:
        # create config file
        f = open(f_config, "w")
        f.close()
    return

def run_smash(finalize):
    # create smash.lock file
    f = open(args.o+file_name_is_running, "w")
    f.close()
    # open unfinished particle files
    particles_out_oscar = open(file_particles_out_oscar+name_unfinished, "w")
    particles_out_dat = open(file_particles_out_dat+name_unfinished, "w")
    # run the black box
    for ts in range(11):
        print("running t = {} fm".format(ts))
        time.sleep(0.5)
    particles_out_oscar.close()
    particles_out_dat.close()

    if finalize:
        finish()
    else:
        print(fatal_error+"crash")
    return

def finish():
    # rename output by removing the .unfinished file ending
    if os.path.exists(file_particles_out_oscar+name_unfinished):
        os.rename(file_particles_out_oscar+name_unfinished, file_particles_out_oscar)
    else:
        print("somehow the output (.oscar) file was not properly written")
        sys.exit()

    if os.path.exists(file_particles_out_dat+name_unfinished):
        os.rename(file_particles_out_dat+name_unfinished, file_particles_out_dat)
    else:
        print("somehow the output file (.dat) was not properly written")
        sys.exit()
    
    # remove smash.lock file
    os.remove(args.o+file_name_is_running)
    return

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", required=False,
                        help="File to the config.yaml")
    parser.add_argument("-o", required=False,
                        help="Path to the output folder")
    parser.add_argument("-c", required=False,
                        help="Make changes to config.yaml (this is not tested here)")
    parser.add_argument("--fail_with", required=False,
                        default=None,
                        choices=["invalid_config", "smash_crashes"],
                        help="Choose a place where SMASH should fail")

    args = parser.parse_args()

    config_is_valid = False if args.fail_with == "invalid_config" else True
    smash_finishes = False if args.fail_with == "smash_crashes" else True

    fatal_error = "FATAL         Main        : SMASH failed with the following error:\n\t\t\t    "
    file_name_is_running = "smash.lock"
    name_unfinished = ".unfinished"
    name_oscar = ".oscar"
    name_dat = ".dat"
    name_particles_file = "SMASH_IC"

    # initialize the system
    check_config(config_is_valid)
    create_folders_structure()
    check_if_empty_output()

    # SMASH output participants + spectators
    file_particles_out_oscar = args.o+name_particles_file+name_oscar
    # special SMASH output for vHLLE. only participants
    file_particles_out_dat = args.o+name_particles_file+name_dat

    # smash is now ready to run
    print_terminal_start()
    run_smash(smash_finishes)