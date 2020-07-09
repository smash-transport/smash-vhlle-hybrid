#!/usr/bin/python
import numpy as np
import argparse
import linecache

def get_average(obs):
    if obs == 'pT': files = args.pT_files
    elif obs == 'dNdy': files = args.y_files
    elif obs == 'mT': files = args.mT_files
    else: print 'Observable not known'

    full_data = []
    for file in files:
        data = np.loadtxt(file, unpack = True)
        full_data.append(data)

    Nevents = float(len(files))     # Number of parallel runs
    mean = np.mean(full_data, axis = 0)
    sigma = np.std(full_data, axis = 0)
    error = sigma / np.sqrt(Nevents - 1.0) if Nevents > 1 else 0.0

    return mean, error


def print_to_file(mean, error, obs):
    if obs == 'pT': files = args.pT_files
    elif obs == 'mT': files = args.mT_files
    elif obs == 'dNdy': files = args.y_files

    file = open(args.output_dir + obs + '.txt', 'w')
    file.write('# ' + obs + ' spectra, already divided by bin width and events\n')
    file.write('# ' + obs + '_bin_center 211 211_error -211 -211_error 111 111_error 321 321_error -321 -321_error 2212 2212_error -2212 -2212_error 3122 3122_error -3122 -3122_error\n')

    bin_edges = linecache.getline(files[0], 4)[17:-2].split(' ')
    # Remove white spaces
    for num, element in enumerate(bin_edges):
        if element == '': bin_edges.pop(num)
    for num, element in enumerate(bin_edges):
        if element == '': bin_edges.pop(num)
    bin_edges = np.array(bin_edges).astype('float')
    bin_width = bin_edges[1:] - bin_edges[:-1]

    Nevents_sampler = float(args.Nevents)
    for i in range(0,len(mean[0])):
        line = ''
        line += str(mean[0][i])
        for particle_index in range(1, 10):
            line += '\t' + str(mean[particle_index][i]/(bin_width[i] * Nevents_sampler)) + '\t' + str(error[particle_index][i]/(bin_width[i] * Nevents_sampler))
        line += '\n'
        file.write(line)

    file.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--pT_files", nargs = '+', required = True,
                        help = "Path to the pT files")
    parser.add_argument("--mT_files", nargs = '+', required = True,
                        help = "Path to the pT files")
    parser.add_argument("--y_files", nargs = '+', required = True,
                        help = "Path to the dN/dy files")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    parser.add_argument("--Nevents", required = True, type=float,
                        help = "Number of afterburner events in individual runs.")
    args = parser.parse_args()

    if (len(args.pT_files) != len(args.mT_files)) or (len(args.pT_files) != len(args.y_files)):
        print 'Loaded ' + str(len(args.pT_files)) + ' pT files, but ' + str(len(args.mT_files)) + ' mT files and ' + str(len(args.y_files)) + '  files.'
    print 'Averaging over ' + str(len(args.pT_files)) + ' events.'

    mean_pT, error_pT = get_average('pT')
    mean_mT, error_mT = get_average('mT')
    mean_y, error_y = get_average('dNdy')

    print_to_file(mean_pT, error_pT, 'pT')
    print_to_file(mean_mT, error_mT, 'mT')
    print_to_file(mean_y, error_y, 'dNdy')
