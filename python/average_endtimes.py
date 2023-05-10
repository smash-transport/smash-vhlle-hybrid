#!/usr/bin/python
import numpy as np
import argparse
import linecache
import matplotlib.pyplot as plt

'''
    This script averages the endtimes of all hydrodynamical evolutions.
'''

def get_average():
    files = args.endtime_files

    full_data = []
    for file in files:
        data = np.loadtxt(file, unpack = True)
        full_data.append(data)

    Nevents = float(len(files))     # Number of parallel runs
    mean = np.mean(full_data, axis = 0)
    sigma = np.std(full_data, axis = 0)
    error = sigma / np.sqrt(Nevents - 1.0) if Nevents > 1 else np.zeros(sigma.shape)

    return mean, error


def print_to_file(mean, error):

    # create files and write content
    file = open(args.output_dir + '/Endtime.txt', 'w')
    file.write('# endtime_mean endtime_error \n')

    file.write(str(mean) + '\t' + str(error) + '\n')
    file.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--endtime_files", nargs = '+', required = True,
                        help = "Path to the endtime files")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    parser.add_argument("--energy", required = True, type=float,
                        help = "Collision energy.")
    args = parser.parse_args()


    mean_endtime, error_endtime = get_average()
    print_to_file(mean_endtime, error_endtime)
