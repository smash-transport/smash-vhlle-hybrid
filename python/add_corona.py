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

'''
    This script adds the corona particles from the initial SMASH run
    to the sampled particle list.
'''

def find_out_event_number(tag):
    '''
        Looks into the last line of the file and finds the value
        of the number of events in the file
    '''
    if tag == 'ic':
        filepath = args.initial_particle_list
    elif tag == 'sampler':
        filepath = args.sampled_particle_list
    warning = "The number of events cannot be found for " + filepath

    with open(filepath, 'rb') as f:
        f.seek(0, os.SEEK_END)
        if f.tell() == 0:
            print("File ", filepath, "is empty.")
            return ''

        pos = -1
        while True:
            try:
                f.seek(pos, os.SEEK_END)
                if f.read(1) == b'\n' and pos != -1:
                    break
                pos -= 1
            except OSError:
                f.seek(0)
                break
        last_line = f.readline().decode().strip()

    words = last_line.split()
    if len(words) >= 4:
        if "end" in last_line:
            try:
                n_events = int(words[2])
            except ValueError:
                print(warning)
        else:
            print(warning)
    else:
        print(warning)

    return(n_events+1)

def extract_particles(filename):
    '''
        Particles are extracted from a file to a numpy array
    '''
    particles = np.empty(shape=[0, 13])
    n_event = 0

    for line in open(filename, "r"):
        line = line.split()
        # event end line
        if "end" in line:
            n_event += 1
        # unused line
        elif "#" in line or "#!OSCAR2013" in line or "#!OSCAR2013Extended" in line: continue
        # particle line
        else:
            particle = np.array(line[:12])
            particle = np.append(int(n_event), particle)
            particles = np.append(particles,[particle], axis=0)

    return(particles)

def gather_corona_particles():
    '''
        Extract particle lines from the initial conditions oscar output of SMASH
        and from vHLLE oscar output and join particles into one array
    '''
    particles_corona = extract_particles(args.initial_particle_list)
    if os.path.isfile(args.hydro_particle_list):
        particles_hydro = extract_particles(args.hydro_particle_list)
        particles_corona = np.append(particles_corona, particles_hydro, axis=0)
    return particles_corona

def read_sampled_and_write_full_particle_list(n_events_ic, n_events_sampler, corona):
    '''
        Event-by-event case: corona is added to to each sampled event
        Averaged IC: corona events are distributed among sampled events
    '''
    output_file = args.output_file
    header_string = "#!OSCAR2013 particle_lists t x y z mass p0 px py pz pdg ID charge \n" \
                    "# Units: fm fm fm fm GeV GeV GeV GeV GeV none none e \n" \
                    "# SMASH-3.2\n"
    with open(output_file, 'w') as f:
        f.write(header_string)

    sampled_particles = np.empty(shape=[0, 12])
    event_s = 0
    event_c = 0

    for line in open(args.sampled_particle_list, "r"):
        line = line.split()
        # event end line
        if "end" in line:

            corona_filter = corona[corona[:, 0] == str(event_c)]
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
        # ignore header
        elif "#" in line or "#!OSCAR2013" in line or "#!OSCAR2013Extended" in line:
            continue
        # particle line
        else:
            particle = np.array(line[:12])
            sampled_particles = np.append(sampled_particles,[particle], axis=0)

    if event_s != n_events_sampler:
        sys.exit("Number of sampled events written does not match with the inputfile.")

if __name__ == '__main__':
    # pass arguments from the command line to the script
    parser = argparse.ArgumentParser()
    parser.add_argument("--sampled_particle_list", required = True,
                        help="File containing the sampled particle lists.")
    parser.add_argument("--initial_particle_list", required = True,
                        help="Particle list from the initial conditions SMASH run.")
    parser.add_argument("--hydro_particle_list", required = False,
                        help="Particle list not accepted into hydro in dynamical IC. " \
                             "Even if passed, the code checks for its existence.")
    parser.add_argument("--output_file", required = True,
                        help="Resulting particle list containing sampled and spectator particles.")
    args = parser.parse_args()

    # find number of IC and sampled events
    n_events_ic = find_out_event_number('ic')
    print("ic: ", n_events_ic)

    corona = gather_corona_particles()
    # find number of sampled events
    n_events_sampler = find_out_event_number('sampler')
    print("sampler: ", n_events_sampler)

    read_sampled_and_write_full_particle_list(n_events_ic, n_events_sampler, corona)

    sys.exit(0)