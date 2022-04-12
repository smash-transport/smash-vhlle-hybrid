import numpy as np
import argparse
import os

'''
    This script adds the spectators of the collision, that were not included in
    the hydrodynamics evolution, to the sampled particle list. The newly-generated
    list contains the particles resulting from the sampling procedure and
    also the spectators from the initial SMASH run.
'''


def get_initial_nucleons_from_config():
    '''
        Determine the number of initial nucleons of the collision from the
        SMASH config employed to provide the initial conditions.
        We need to find the indented configuration of the projectile and target
        nuclei and read off the number of constituents.
    '''

    N_initial_nucleons = 0
    with open(args.smash_config) as config:
        for line in config:
            if line.startswith('      Particles:'):
                split_line = line.split(':')
                if len(split_line) != 4:
                    print ('ERROR: Cannot cope with more than two particle '
                           'species forming the initial nucleons. Pleae modify '
                           'the \'python_scripts/add_spectators.py\' script.')
                    break
                N_initial_nucleons += int(line.split(':')[2].split(',')[0])
                N_initial_nucleons += int(line.split(':')[3].split('}')[0])

    return N_initial_nucleons


def extract_spectators():
    '''
        1) Find spectators in the initial conditions oscar output of SMASH.
        2) Extract the corresponding lines and store them in a separate list
           that is passed to write_full_particle_list() where the entries are
           written to the output file.
    '''

    N_nucleons = get_initial_nucleons_from_config()

    spectator_list = []
    with open(args.initial_particle_list, 'r') as f:
        for line in f:
            if (len(line.split()) != 20): continue  # Comment line
            # Is initial nucleon and has not interacted
            if ((int(line.split()[10]) <= N_nucleons) and (int(line.split()[12]) == 0) ):
                # To properly determine the spectators, we need the extended output.
                # For the final particle list that is used to run the afterburner
                # we do however only need it in the non-extended version. So we
                # extract columns 1 - 12 to be written to the output file
                spectator_line = ' '.join(line.split()[:12]) + '\n'
                spectator_list.append(spectator_line)

    return spectator_list


def write_full_particle_list(spectator_list):
    '''
        1) Read each line from sampled particle list
        2) Write the OSCAR2013 header (copied from sampler output)
        3) At beginning of new event:
           a) Update event header with corrected total number of particles
           b) Write updated event header
           c) Write particle lines of spectators
        4) At the end of or within an event:
           a) Write particle lines from sampled particle list
           b) Write event end header
    '''
    N_spectators = len(spectator_list)
    updated_particle_list = open(args.output_file, 'w')

    with open(args.sampled_particle_list, 'r') as f:
        for line in f:
            # Find header of each new event
            if (line.startswith('# event') and len(line.split()) == 5 ):
                # 5th column contains the number of sampled particles for each
                # event. To this value the number of spectators needs to be added
                particles_in_event = int(line.split()[4]) + N_spectators
                # Update last entry in list (number of particles)
                newline = ' '.join(line.split()[:-1]) + str(particles_in_event) + '\n'

                # (I) write header for new event
                updated_particle_list.write(newline)

                # (II) write spectators
                for particle_line in spectator_list:
                    updated_particle_list.write(particle_line)

            else:
                # (0) write OSCAR header comments or
                # (III) write sampled particles and event end header
                updated_particle_list.write(line)

    updated_particle_list.close()


if __name__ == '__main__':
    # pass arguments from the command line to the script
    parser = argparse.ArgumentParser()
    parser.add_argument("--sampled_particle_list", required = True,
                        help="File containing the sampled particle lists.")
    parser.add_argument("--initial_particle_list", required = True,
                        help="Particle list from the initial conditions SMASH run.")
    parser.add_argument("--output_file", required = True,
                        help="Resulting particle list containing sampled and spectator particles.")
    parser.add_argument("--smash_config", required = True,
                        help="SMASH config file employed for the initial conditions.")
    args = parser.parse_args()


    get_initial_nucleons_from_config()
    spectators = extract_spectators()
    write_full_particle_list(spectators)
