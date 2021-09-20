#!/usr/bin/python
import numpy as np
import argparse
import linecache

'''
    This script combines all Ennergy conservation outputs of the individual
    event-by-event runs of a specific setup to yield the mean and an error
    estimate.
'''

def get_average(files):

    full_data = []
    for file in files:
        data = np.loadtxt(file)
        full_data.append(data)

    print full_data
    Nevents = float(len(files))
    mean = np.mean(full_data, axis = 0)
    sigma = np.std(full_data, axis = 0)
    error = sigma / np.sqrt(Nevents - 1.0) if Nevents > 1 else np.zeros(sigma.shape)

    print mean
    return mean, error


def print_to_file(mean, error, name):

    file = open(args.output_dir + name + '.txt', 'w')
    if name == 'E_cons':  file.write('# E_Fraction_IC E_Fraction_IC_error E_Fraction_hydro E_Fraction_hydro_error E_Fraction_sampler E_Fraction_sampler_error E_Fraction_afterburner E_Fraction_afterburner_error \n')
    elif name == 'B_cons':  file.write('# B_Fraction_IC B_Fraction_IC_error B_Fraction_hydro B_Fraction_hydro_error B_Fraction_sampler B_Fraction_sampler_error B_Fraction_afterburner B_Fraction_afterburner_error \n')
    else: file.write('# Q_Fraction_IC Q_Fraction_IC_error Q_Fraction_hydro Q_Fraction_hydro_error Q_Fraction_sampler Q_Fraction_sampler_error Q_Fraction_afterburner Q_Fraction_afterburner_error \n')

    line = ''
    for i in range(0,len(mean)):
        line += str(mean[i]) + '\t' + str(error[i]) + '\t'
    line += '\n'
    file.write(line)

    file.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--E_files", nargs = '+', required = True,
                        help = "Path to the E conservation files")
    parser.add_argument("--B_files", nargs = '+', required = True,
                        help = "Path to the B conservation files")
    parser.add_argument("--Q_files", nargs = '+', required = True,
                        help = "Path to the Q conservation files")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    args = parser.parse_args()

    print 'Averaging over ' + str(len(args.E_files)) + 'E  events.'
    print 'Averaging over ' + str(len(args.B_files)) + 'B  events.'
    print 'Averaging over ' + str(len(args.Q_files)) + 'Q  events.'

    E_mean, E_error = get_average(args.E_files)
    B_mean, B_error = get_average(args.B_files)
    Q_mean, Q_error = get_average(args.Q_files)

    print_to_file(E_mean, E_error, 'E_cons')
    print_to_file(B_mean, B_error, 'B_cons')
    print_to_file(Q_mean, Q_error, 'Q_cons')
