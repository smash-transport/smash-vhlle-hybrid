#!/usr/bin/env python3

import argparse
import os
import sys
import re
import time

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
    # generated with https://patorjk.com/software/taag/#p=display&f=Graffiti&t=Type%20Something%20
    Terminal_Out="""###########################################################################################################\n
_________   _____      _____    _________ ___ ___\n
    /   _____/  /     \    /  _  \  /   _____//   |   \ \n
    \_____  \  /  \ /  \  /  /_\  \ \_____  \/    ~    \\n
    /        \/    Y    \/    |    \/        \    Y    /\n
    /_______  /\____|__  /\____|__  /_______  /\___|_  /\n
            \/         \/         \/        \/       \/\n
    \n                                 ___ ___         ___.         .__    .___        _____________________    _____
    ____   ______  _  __          /   |   \ ___.__.\_ |_________|__| __| _/        \_   _____/\______   \  /  _  \\n
    /    \_/ __ \ \/ \/ /  ______ /    ~    <   |  | | __ \_  __ \  |/ __ |  ______  |    __)_  |       _/ /  /_\  \\n
    |   |  \  ___/\     /  /_____/ \    Y    /\___  | | \_\ \  | \/  / /_/ | /_____/  |        \ |    |   \/    |    \\n
    |___|  /\___  >\/\_/            \___|_  / / ____| |___  /__|  |__\____ |         /_______  / |____|_  /\____|__  /\n
        \/     \/                        \/  \/          \/              \/                 \/         \/         \/\n
    \n   _____  _____________________________________________________ ____ _____________  _______  _____________________  __________.____       _____  _________  ____  __.        __________\n ________  ____  ___\n
    /  _  \ \_   _____/\__    ___/\_   _____/\______   \______   \    |   \______   \ \      \ \_   _____/\______   \ \______   \    |     /  _  \ \_   ___ \|    |/ _|        \______   \\n\_____  \ \   \/  /
    /  /_\  \ |    __)    |    |    |    __)_  |       _/|    |  _/    |   /|       _/ /   |   \ |    __)_  |       _/  |    |  _/    |    /  /_\  \/    \  \/|      <    ______ |    |  _/ /\n   |   \ \     /
    /    |    \|     \     |    |    |        \ |    |   \|    |   \    |  / |    |   \/    |    \|        \ |    |   \  |    |   \    |___/    |    \     \___|    |  \  /_____/ |    |   \/\n    |    \/     \
    \____|__  /\___  /     |____|   /_______  / |____|_  /|______  /______/  |____|_  /\____|__  /_______  / |____|_  /  |______  /_______ \____|__  /\______  /____|__ \         |______  /\n\_______  /___/\  \
            \/     \/                       \/         \/        \/                 \/         \/        \/         \/          \/        \/       \/        \/        \/                \/\n         \/      \_/\n###########################################################################################################\n"""





    print(Terminal_Out)
    print("running SMASH Afterburner")
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

def run_smash(finalize,file_particles_in,sampler_dir):
    # create smash.lock file
    f = open(args.o+file_name_is_running, "w")
    extension_pattern = r"\d+"  # Matches one or more digits at the end of the filename
    regex=re.compile(file_particles_in+extension_pattern)
    # Get a list of files in the current directory
    files = os.listdir(sampler_dir)
    # Filter files that match the base name and have only integer extensions
    matching_files = [file_in for file_in in files if regex.match(sampler_dir+file_in)]
    if(len(matching_files)>0):
        try:
            for match in matching_files:
                f_in=open(sampler_dir+match,"r")
                f_in.close()
                print("File read")
        except:
            print(fatal_error+"Sampled particle list could not be opened")
            sys.exit(1)
    else:
        print(fatal_error+"Sampled particle list could not be found")
        sys.exit(1)
    f.close()
    # open unfinished particle files
    particles_out_oscar = open(file_particles_out_oscar+name_unfinished, "w")
    particles_out_bin = open(file_particles_out_bin+name_unfinished, "w")
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
    if os.path.exists(file_particles_out_oscar+name_unfinished):
        os.rename(file_particles_out_oscar+name_unfinished, file_particles_out_oscar)
    else:
        print("somehow the output (.oscar) file was not properly written")
        sys.exit(1)

    if os.path.exists(file_particles_out_bin+name_unfinished):
        os.rename(file_particles_out_bin+name_unfinished, file_particles_out_bin)
    else:
        print("somehow the output file (.bin) was not properly written")
        sys.exit(1)

    # remove smash.lock file
    os.remove(args.o+file_name_is_running)
    return

def parse_command_line_config_options():
    sampler_dir=""
    dir_config=False
    n_events_config=False
    if(args.c == None):
        print("No -c command line option was given")
        sys.exit(1)
    else:
        for option in args.c:
            if "Modi:" in option[0].split():
                sampler_dir=option[0].split()[5].split("}")[0]
                dir_config=True
            elif "Nevents:" in option[0].split():
                try:
                    n_events=int(option[0].split()[3].strip())
                    n_events_config=True
                except:
                    print("Nevents could not be parsed")
                    sys.exit(1)

    if not (dir_config and n_events_config):
        print("Necessary command line options not found\n"
              "  -c 'Modi: { List: { File_Directory: <dir-path>} }'\n"
              "  -c 'General: { Nevents: <N-events> }'")
        sys.exit(1)

    if not os.path.isdir(sampler_dir):
        print("Directory '{0}' not found".format(sampler_dir))
        sys.exit(1)

    if sampler_dir != "/":
        sampler_dir += "/"
    return sampler_dir


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", required=False,
                        help="File to the config.yaml")
    parser.add_argument("-o", required=False,
                        help="Path to the output folder")
    parser.add_argument("-c", required=False,action='append',nargs='+',
                        help="Make changes to config.yaml (this is mocked here)")
    parser.add_argument("--fail_with", required=False,
                        default=None,
                        choices=["invalid_config", "smash_crashes"],
                        help="Choose a place where SMASH should fail")

    args = parser.parse_args()

    smash_finishes = args.fail_with != "smash_crashes"
    fatal_error = "FATAL         Main        : SMASH failed with the following error:\n\t\t\t    "
    file_name_is_running = "smash.lock"
    name_unfinished = ".unfinished"
    name_oscar = ".oscar"
    name_bin = ".bin"
    name_particles_file = "particle_lists"
    sampler_dir=parse_command_line_config_options()
    file_particles_in=sampler_dir+"sampling"

    # initialize the system
    check_config(args.fail_with != "invalid_config")
    create_folders_structure()
    ensure_no_output_is_overwritten()

    file_particles_out_oscar = args.o+name_particles_file+name_oscar
    file_particles_out_bin = args.o+name_particles_file+name_bin

    # smash is now ready to run
    print_terminal_start()
    run_smash(smash_finishes,file_particles_in,sampler_dir)
