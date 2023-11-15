#!/usr/bin/env python3

# README:
# The sampler black box is called like:
#
#     ./sampler_black_box events num path_to_config_file
#
# with:
# - events: This is not a variable. This must be the string 'events'
# - num: random number set by the user. In hybrid NUM=1
# - path_to_config_file: Path to the sampler configuration

# How it works:
# The sampler black box starts by checking if the sampler config exists.
# If it is the case, it gets the path to the freezeout hypersurface and the output
# directory from the config and checks that also the freezeout surface exists.
#
# Use the BLACK_BOX_FAIL environment variable set to "true"
# to mimic a particular failure in the black box.
#
# If it got everything correctly, it will produce a dummy terminal output and
# a) particle_lists.oscar in the output directory if the optional argument is not given
# b) nothing if the BLACK_BOX_FAIL environment variable is set to "true"

import sys
import os.path
import numpy as np
import time
import random

def check_input_arguments():
    calling_instruction = 'Call the sampler black box by:\n\n' +\
                          './sampler_black_box.py events num path_to_config_file \n\n' +\
                          '- events: This is not a variable. This must be the string "events"\n' +\
                          '- num: random number set by the user. In hybrid num=1\n' +\
                          '- path_to_config_file: Path to the sampler configuration\n'

    if len(sys.argv) < 4 or len(sys.argv) > 5:
        err_msg = 'Invalid number of arguments!\n' + calling_instruction
        print(err_msg)
        sys.exit(1)
    elif not sys.argv[1] == 'events':
        err_msg = 'Invalid first argument passed!\n' +\
                  'The first argument must be the string "events"\n' + calling_instruction
        print(err_msg)
        sys.exit(1)


def check_if_file_exists(path):
    if not os.path.isfile(path):
        err_msg = 'File not found at given path: ' + path
        print(err_msg)
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

def get_value_as_string_from_config_by_keyword(path_to_config, keyword):
    #Valid keywords:
    #surface, spectra_dir, number_of_events, weakContribution, shear, ecrit
    file = open(path_to_config)

    while True:
        line_in_config = file.readline()
        if not line_in_config:
            exception_message = 'Keyword '+str(keyword)+' is not contained in the config file!'
            print(exception_message)
            sys.exit(1)
        else:
            splitted_line_in_config = get_first_two_fields_in_line(line_in_config)
            key_in_config_line = splitted_line_in_config[0]
            value_of_key_in_config_line = splitted_line_in_config[1]

            if key_in_config_line == str(keyword):
                return value_of_key_in_config_line


def make_fake_run():
    header ="\n"+\
     "   _____         __  __ _____  _      ______ _____    ____  _               _____ _  __  ____   ______   __\n"+\
     "  / ____|  /\   |  \/  |  __ \| |    |  ____|  __ \  |  _ \| |        /\   / ____| |/ / |  _ \ / __ \ \ / /\n"+\
     " | (___   /  \  | \  / | |__) | |    | |__  | |__) | | |_) | |       /  \ | |    | ' /  | |_) | |  | \ V / \n"+\
     "  \___ \ / /\ \ | |\/| |  ___/| |    |  __| |  _  /  |  _ <| |      / /\ \| |    |  <   |  _ <| |  | |> <   \n"+\
     "  ____) / ____ \| |  | | |    | |____| |____| | \ \  | |_) | |____ / ____ \ |____| . \  | |_) | |__| / . \  \n"+\
     " |_____/_/    \_\_|  |_|_|    |______|______|_|  \_\ |____/|______/_/    \_\_____|_|\_\ |____/ \____/_/ \_\ \n"+\
     "       | | | |           / _|     | |                      | |           | |                                \n"+\
     "       | |_| |__   ___  | |_ _   _| |_ _   _ _ __ ___   ___| |_ __ _ _ __| |_ ___   _ __   _____      __    \n"+\
     "       | __| '_ \ / _ \ |  _| | | | __| | | | '__/ _ \ / __| __/ _` | '__| __/ __| | '_ \ / _ \ \ /\ / /    \n"+\
     "       | |_| | | |  __/ | | | |_| | |_| |_| | | |  __/ \__ \ || (_| | |  | |_\__ \ | | | | (_) \ V  V /     \n"+\
     "        \__|_| |_|\___| |_|  \__,_|\__|\__,_|_|  \___| |___/\__\__,_|_|   \__|___/ |_| |_|\___/ \_/\_/      \n"

    print(header)
    for i in range(11):
        print('Fake computational progress: ', int(10*i), '%')
        time.sleep(0.1)


def create_output_file(output_dir):
    header = '#!OSCAR2013 particle_lists t x y z mass p0 px py pz pdg ID charge\n' +\
             '# Units: fm fm fm fm GeV GeV GeV GeV GeV none none e\n' +\
             '# SMASH-3.0-1-g0985d6b3\n'
    format_oscar2013 = '%g %g %g %g %g %g %g %g %g %d %d %d'

    output_file = output_dir+'/particle_lists.oscar'

    file = open(output_file, 'w')
    file.write(header)
    file.close()

    with open(output_file, "a") as f_out:
        for counter_event in range(4):
            num_output_of_event = random.randint(10, 20)
            output_event = []

            for counter_output in range(num_output_of_event):
                t = 200.0
                x = 0.1*random.randint(-1000, 1000)
                y = 0.1*random.randint(-1000, 1000)
                z = 0.1*random.randint(-1000, 1000)
                mass = 0.1*random.randint(0, 100)
                p0 = 0.001*random.randint(0, 10000)
                px = 0.001*random.randint(-10000, 10000)
                py = 0.001*random.randint(-100, 10000)
                pz = 0.001*random.randint(-10000, 10000)
                pdg = random.randint(0, 10000)
                ID = random.randint(0, 100)
                charge = random.randint(-2, 2)

                output_line = [t, x, y, z, mass, p0, px, py, pz, pdg, ID, charge]
                output_event.append(output_line)

            output_event = np.asarray(output_event)


            f_out.write('# event '+ str(counter_event)+' out '+ str(num_output_of_event)+'\n')
            np.savetxt(f_out, output_event, delimiter=' ', newline='\n', fmt=format_oscar2013)
            f_out.write('# event '+ str(counter_event)+' end 0 impact   0.000 scattering_projectile_target yes\n')


####################   End Definitions   ####################

if __name__=='__main__':

    sampler_finishes = os.environ.get('BLACK_BOX_FAIL') != 'true'

    check_input_arguments()

    path_to_config = sys.argv[3]

    check_if_file_exists(path_to_config)

    path_to_freezeout = get_value_as_string_from_config_by_keyword(path_to_config, 'surface')
    output_dir = get_value_as_string_from_config_by_keyword(path_to_config, 'spectra_dir')

    check_if_file_exists(path_to_freezeout)
    check_if_directory_exists(output_dir)

    if sampler_finishes:
        make_fake_run()
        create_output_file(output_dir)
    else:
        print("Sampler black-box crashed!")
        sys.exit(1)
