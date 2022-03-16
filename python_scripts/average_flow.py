#!/usr/bin/python
import numpy as np
import argparse
import linecache
import matplotlib.pyplot as plt

'''
    This script combines all event plane flow outputs of the individual
    event-by-event runs of a specific setup to yield the mean and an error
    estimate.
'''

def get_average(obs):
    if obs == 'v2': files = args.v2_files
    elif obs == 'v3': files = args.v3_files
    else: print 'Observable not known'

    full_data = []
    for file in files:
        data = np.loadtxt(file, unpack = True)
        full_data.append(data)

    Nevents = float(len(files))     # Number of parallel runs
    mean = np.mean(full_data, axis = 0)
    sigma = np.std(full_data, axis = 0)
    error = sigma / np.sqrt(Nevents - 1.0) if Nevents > 1 else np.zeros(sigma.shape)

    return mean, error


def average_integrated_vn(obs):
    if obs == 'v2': files = args.v2_files
    elif obs == 'v3': files = args.v3_files
    else: print 'Observable not known'

    int_vn_list = []
    for file in files:
        with open(file, 'r') as f:
            f.readline()    # skip, no info about int_vn
            f.readline()    # skip, no info about int_vn
            int_vn = float(f.readline().split()[-1])
            int_vn_list.append(int_vn)

    Nevents = float(len(files))
    mean = np.mean(int_vn_list)
    error = np.std(int_vn_list) / np.sqrt(Nevents - 1.0) if Nevents > 1 else 0.0

    return mean, error

def print_to_file(mean, error, obs):
    if obs == 'v2': files = args.v2_files
    elif obs == 'v3': files = args.v3_files

    # create files and write content
    file = open(args.output_dir + obs + '.txt', 'w')
    file.write('# event plane charged particle ' + obs + '\n')
    file.write('# pT \t' + obs + '\t error \n')

    for i in range(0, len(mean[0])):
        file.write(str(mean[0][i]) + '\t' + str(mean[1][i]) + '\t' + str(error[1][i]) + '\n')

    file.close()

def print_int_to_file(mean_v2, error_v2, mean_v3, error_v3):

    # create files and write content
    file = open(args.output_dir + 'int_vn.txt', 'w')
    file.write('# event plane charged particle integrated v2 and v3 \n')
    file.write('# sqrts \t v2 \t v2_error \t v3 \t v3_error \n')

    file.write(str(args.energy) + '\t' + str(mean_v2) + '\t' + str(error_v2) + '\t' + str(mean_v3) + '\t' + str(error_v3))
    file.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--v2_files", nargs = '+', required = True,
                        help = "Path to the v2 files")
    parser.add_argument("--v3_files", nargs = '+', required = True,
                        help = "Path to the v3 files")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    parser.add_argument("--energy", required = True, type=float,
                        help = "Collision energy.")
    args = parser.parse_args()

    if (len(args.v2_files) != len(args.v3_files)):
        print 'Loaded ' + str(len(args.v2_files)) + ' v2 files, but ' + str(len(args.v3_files)) + ' v3 files.'
    print 'Averaging over ' + str(len(args.v2_files)) + ' events.'

    mean_v2, error_v2 = get_average('v2')
    mean_v3, error_v3 = get_average('v3')
    mean_int_v2, error_int_v2 = average_integrated_vn('v2')
    mean_int_v3, error_int_v3 = average_integrated_vn('v3')

    print_int_to_file(mean_int_v2, error_int_v2, mean_int_v3, error_int_v3)
    print_to_file(mean_v2, error_v2, 'v2')
    print_to_file(mean_v3, error_v3, 'v3')
