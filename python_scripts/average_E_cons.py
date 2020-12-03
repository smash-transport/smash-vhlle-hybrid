#!/usr/bin/python
import numpy as np
import argparse
import linecache

'''
    This script combines all Ennergy conservation outputs of the individual
    event-by-event runs of a specific setup to yield the mean and an error
    estimate.
'''

def get_average():
    files = args.files

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


def print_to_file(mean, error):

    file = open(args.output_dir + 'E_cons.txt', 'w')
    file.write('# E_Fraction_IC E_Fraction_IC_error E_Fraction_hydro E_Fraction_hydro_error E_Fraction_sampler E_Fraction_sampler_error E_Fraction_afterburner E_Fraction_afterburner_error \n')

    line = ''
    for i in range(0,len(mean)):
        line += str(mean[i]) + '\t' + str(error[i]) + '\t'
    line += '\n'
    file.write(line)

    file.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--files", nargs = '+', required = True,
                        help = "Path to the E conservation files")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    args = parser.parse_args()

    print 'Averaging over ' + str(len(args.files)) + ' events.'

    mean, error = get_average()

    print_to_file(mean, error)
