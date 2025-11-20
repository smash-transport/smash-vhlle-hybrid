#!/usr/bin/env python3

#===================================================
#
#    Copyright (c) 2025
#      SMASH Hybrid Team
#
#    GNU General Public License (GPLv3 or later)
#
#===================================================

import argparse
import numpy as np
import sys
import os
import subprocess

'''
    This script adds the corona particles from the initial SMASH run
    and possibly others to the sampled particle list.
'''

def find_out_event_number(filepath):
    '''
        Look into the last line of the file and find the number of events
    '''
    if not os.path.isfile(filepath):
        print(filepath+" does not exist!", file=sys.stderr)
        sys.exit(2)
    tail = subprocess.run(['tail', '-n', '1', filepath],
                          stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    last_line = tail.stdout.decode().strip().split()
    n_events = 0
    error = False
    if "end" in last_line:
        try:
            n_events = int(last_line[2])
        except ValueError:
            error = True
    else:
        error = True
    if error:
        print("The number of events cannot be found for " + filepath,
                file=sys.stderr)
        sys.exit(3)
    return n_events+1

def extract_particles(filename):
    '''
        Extract particles from a file to a numpy array
    '''
    particles = np.empty(shape=[0, 13])
    n_event = 0

    for line in open(filename, "r"):
        line = line.split()
        # event end line
        if "end" in line:
            n_event += 1
        # ignore header
        elif "#" in line or "#!OSCAR2013" in line or "#!OSCAR2013Extended" in line:
            continue
        # particle line
        else:
            particle = np.array(line[:12])
            particle = np.append(int(n_event), particle)
            particles = np.append(particles,[particle], axis=0)
    return(particles)

def gather_corona_particles(corona_lists):
    '''
        Extract particle lines from the initial conditions oscar output of SMASH
        and any extra file (e.g. from vHLLE oscar output) and join particles
        into one array.
    '''
    is_any_corona_file_present = False
    corona_particles = np.empty(shape=[0, 13])
    for file in corona_lists:
        if os.path.isfile(file):
            is_any_corona_file_present = True
            more_corona_particles = extract_particles(file)
            corona_particles = np.append(corona_particles, more_corona_particles, axis=0)
    if len(corona_particles) == 0:
        print("No corona particles!", file=sys.stderr)
        sys.exit(4)
    if not is_any_corona_file_present:
        print("Corona files not found!", file=sys.stderr)
        sys.exit(2)
    return corona_particles

def copy_header(input_file, output_file):
    header = ""
    for line in open(input_file, "r"):
        if line.startswith('# event'):
            break
        else:
            header += line
    with open(output_file, 'w') as f:
        f.write(header)

def read_sampled_and_write_full_particle_list(args, corona_particles, n_events_ic):
    '''
        Corona particles are distributed among sampled events
    '''
    output_file = args.output_file
    copy_header(args.sampled_particle_list,output_file)

    sampled_particles = np.empty(shape=[0, 12])
    event_s = 0
    event_c = 0

    for line in open(args.sampled_particle_list, "r"):
        line = line.split()
        # event end line
        if "end" in line:
            corona_filter = corona_particles[corona_particles[:, 0] == str(event_c)]
            particle_number = len(corona_filter)+len(sampled_particles)
            with open(output_file, 'a') as f:
                f.write("# event {} out {}\n".format(event_s,particle_number))
            # write sampled
            with open(output_file, 'a') as f:
                np.savetxt(f, sampled_particles, delimiter=' ', fmt='%s')
            # write corona
            with open(output_file, 'a') as f:
                np.savetxt(f, corona_filter[:,1:], delimiter=' ', fmt='%s')
            with open(output_file, 'a') as f:
                f.write("# event {} end \n".format(event_s))

            if event_s % 100 == 0:
                print("read and write event "+str(event_s))
            # reset relevant variables
            if event_c < (n_events_ic-1):
                event_c += 1
            else:
                event_c = 0
            event_s += 1
            sampled_particles = np.empty(shape=[0, 12])
        # ignore event headers
        elif "#" in line[0]:
            continue
        # particle line
        else:
            particle = np.array(line[:12])
            sampled_particles = np.append(sampled_particles,[particle], axis=0)

if __name__ == '__main__':
    # pass arguments from the command line to the script
    parser = argparse.ArgumentParser()
    parser.add_argument("-s","--sampled_particle_list", required = True,
                        help="File containing the sampled particle lists.")
    parser.add_argument("-c","--corona_particle_lists", nargs='+', required = True,
                        help="Particle list from the initial conditions SMASH run.")
    parser.add_argument("-o","--output_file", required = True,
                        help="Resulting particle list containing " \
                        "sampled and spectator particles.")
    parser.add_argument("-f", "--force", action='store_true',
                        help = "Ignore pre-existing output file")
    args = parser.parse_args()

    output = args.output_file
    if os.path.isfile(output):
        print(output+" already exists!", file=sys.stderr)
        if not args.force:
            sys.exit(5)

    # find number of corona events, they should all be the same
    n_events_corona = find_out_event_number(args.corona_particle_lists[0])
    corona_particles = gather_corona_particles(args.corona_particle_lists)

    read_sampled_and_write_full_particle_list(args, corona_particles,
                                              n_events_corona)

    sys.exit(0)
