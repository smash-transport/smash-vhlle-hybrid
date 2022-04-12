#!/usr/bin/python
import numpy as np
import argparse
import linecache

'''
    This script combines all analysis outputs of the individual event-by-event
    runs of a specific setup to yield the mean and an error estimate.
    For now, averaging is only implemented for pT, mT, rapidity spectra as well
    as mean pT and multiplicity at midrapidity and v2.
'''

def get_average(obs):
    if obs == 'pT': files = args.pT_files
    elif obs == 'dNdy': files = args.y_files
    elif obs == 'mT': files = args.mT_files
    elif obs == 'v2': files = args.v2_files
    elif obs == 'midyY': files = args.midyY_files
    elif obs == 'meanpT': files = args.meanpT_files
    else: print ('Observable not known')

    full_data = []
    for file in files:
        data = np.loadtxt(file, unpack = True)
        full_data.append(data)

    Nevents = float(len(files))     # Number of parallel runs
    mean = np.mean(full_data, axis = 0)
    sigma = np.std(full_data, axis = 0)
    error = sigma / np.sqrt(Nevents - 1.0) if Nevents > 1 else np.zeros(sigma.shape)

    return mean, error


def print_to_file(mean, error, obs):
    if obs == 'pT': files = args.pT_files
    elif obs == 'mT': files = args.mT_files
    elif obs == 'dNdy': files = args.y_files
    elif obs == 'v2': files = args.v2_files
    elif obs == 'midyY': files = args.midyY_files
    elif obs == 'meanpT': files = args.meanpT_files

    # find bin widths from analysis scripts
    mtbins = linecache.getline(args.smash_ana_dir + '/test/energy_scan/mult_and_spectra.py', 20)
    ybins = linecache.getline(args.smash_ana_dir + '/test/energy_scan/mult_and_spectra.py', 21)
    ptbins = linecache.getline(args.smash_ana_dir + '/test/energy_scan/mult_and_spectra.py', 22)
    midybins = linecache.getline(args.smash_ana_dir + '/test/energy_scan/mult_and_spectra.py', 23)
    if midybins.split()[0] != 'midrapidity_cut' or mtbins.split()[0] != 'mtbins' or ptbins.split()[0] != 'ptbins' or ybins.split()[0] != 'ybins':
        print ('Problem in determination of bin width. '
               'The smash-analysis script \'smash-analysis/test/energy_scan/mult_and_spectra.py\' '
               'was modified after this file was created. Please check and update accordingly.')

    mtbin_edges = eval(mtbins.split('=')[1][:-2])
    ptbin_edges = eval(ptbins.split('=')[1][:-2])
    ybin_edges = eval(ybins.split('=')[1][:-2])
    midy_bin_width = 2.0 * float(midybins.split()[-1].split(')')[0])

    # create files and write content
    if obs == 'v2': file = open(args.output_dir + obs + 'spectra.txt', 'w')
    else: file = open(args.output_dir + obs + '.txt', 'w')
    if obs in ['midyY', 'meanpT']: file.write('# ' + obs + ' spectra, already divided by events\n')
    else: file.write('# ' + obs + ' spectra, already divided by bin width and events\n')
    if obs == 'v2': file.write('# pT_bin_center 211 211_error -211 -211_error 111 111_error 321 321_error -321 -321_error 2212 2212_error -2212 -2212_error 3122 3122_error -3122 -3122_error\n')
    else: file.write('# ' + obs + '_bin_center 211 211_error -211 -211_error 111 111_error 321 321_error -321 -321_error 2212 2212_error -2212 -2212_error 3122 3122_error -3122 -3122_error\n')

    if obs not in ['midyY', 'meanpT']:
        if obs == 'mT': bin_width = mtbin_edges[1:] - mtbin_edges[:-1]
        elif obs in ['pT', 'v2']: bin_width = ptbin_edges[1:] - ptbin_edges[:-1]
        elif obs == 'dNdy': bin_width = ybin_edges[1:] - ybin_edges[:-1]

        Nevents_sampler = float(args.Nevents)
        for i in range(0,len(mean[0])):
            line = ''
            line += str(mean[0][i])
            for particle_index in range(1, 10):
                if obs != 'v2': line += '\t' + str(mean[particle_index][i]/(bin_width[i] * Nevents_sampler)) + '\t' + str(error[particle_index][i]/(bin_width[i] * Nevents_sampler))
                else: line += '\t' + str(mean[particle_index][i]/(bin_width[i] * midy_bin_width)) + '\t' + str(error[particle_index][i]/(bin_width[i] * midy_bin_width))
            line += '\n'
            file.write(line)
    elif obs == 'meanpT':
         line = ''
         for particle_index in range(0, 9):
             line += '\t' + str(mean[particle_index]) + '\t' + str(error[particle_index])
         line += '\n'
         file.write(line)
    elif obs == 'midyY':
        line = ''
        Nevents_sampler = float(args.Nevents)
        line = ''
        for particle_index in range(0, 9):
            line += '\t' + str(mean[particle_index]/(midy_bin_width * Nevents_sampler)) + '\t' + str(error[particle_index]/(midy_bin_width * Nevents_sampler))
        line += '\n'
        file.write(line)
    else:
        print ('Problem: Observable ' + obs + ' not implemented.')

    file.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--smash_ana_dir", required = True,
                        help = "Path to the smash analysis to find mid-y bin width")
    parser.add_argument("--pT_files", nargs = '+', required = True,
                        help = "Path to the pT files")
    parser.add_argument("--mT_files", nargs = '+', required = True,
                        help = "Path to the pT files")
    parser.add_argument("--y_files", nargs = '+', required = True,
                        help = "Path to the dN/dy files")
    parser.add_argument("--midyY_files", nargs = '+', required = True,
                        help = "Path to the midy yield files")
    parser.add_argument("--v2_files", nargs = '+', required = True,
                        help = "Path to the v2 files")
    parser.add_argument("--meanpT_files", nargs = '+', required = True,
                        help = "Path to the mean pT files")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    parser.add_argument("--Nevents", required = True, type=float,
                        help = "Number of afterburner events in individual runs.")
    args = parser.parse_args()

    if (len(args.pT_files) != len(args.mT_files)) or (len(args.pT_files) != len(args.y_files)):
        print ('Loaded ' + str(len(args.pT_files)) + ' pT files, but ' + str(len(args.mT_files)) + ' mT files and ' + str(len(args.y_files)) + '  files.')
    print ('Averaging over ' + str(len(args.pT_files)) + ' events.')

    mean_pT, error_pT = get_average('pT')
    mean_mT, error_mT = get_average('mT')
    mean_y, error_y = get_average('dNdy')
    mean_v2, error_v2 = get_average('v2')
    mean_midyY, error_midyY = get_average('midyY')
    mean_meanpT, error_meanpT = get_average('meanpT')

    print_to_file(mean_pT, error_pT, 'pT')
    print_to_file(mean_mT, error_mT, 'mT')
    print_to_file(mean_y, error_y, 'dNdy')
    print_to_file(mean_v2, error_v2, 'v2')
    print_to_file(mean_midyY, error_midyY, 'midyY')
    print_to_file(mean_meanpT, error_meanpT, 'meanpT')
