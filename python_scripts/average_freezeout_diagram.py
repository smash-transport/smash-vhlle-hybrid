#!/usr/bin/python
import numpy as np
import argparse
import linecache


def find_average():
    T_mean, muB_mean = [], []
    T_sigma, muB_sigma = [], []
    for file in args.files:
        data = np.loadtxt(file)
        print data
        muB_mean.append(data[0])
        muB_sigma.append(data[1])
        T_mean.append(data[2])
        T_sigma.append(data[3])

    return np.mean(muB_mean), np.mean(muB_sigma), np.mean(T_mean), np.mean(T_sigma)


def print_to_file(data):
    file = open(args.output_dir + '/T_muB.txt', 'w')
    file.write('# muB_mean \t muB_std \t T_mean \t T_std \n')
    file.write(str(data[0]) + '\t' + str(data[1]) + '\t' + str(data[2]) + '\t' + str(data[3]))
    file.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--files", nargs = '+', required = True,
                        help = "Path to the individual files")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    parser.add_argument("--Nevents", required = True, type=float,
                        help = "Number of afterburner events in individual runs.")
    args = parser.parse_args()


    averaged_T_muB = find_average()
    print_to_file(averaged_T_muB)
