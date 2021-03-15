#!/usr/bin/python
import numpy as np
import matplotlib
matplotlib.use('Agg')
from matplotlib import cm
import matplotlib.pyplot as plt
import argparse
import linecache
import seaborn as sns
import collections

'''
   This scripts plots the excitation functions of v2 and midy yield
'''

matplotlib.rcParams['axes.labelsize'] = 15
matplotlib.rcParams['legend.fontsize'] = 11


def collect_data(files):
    data_collection = {'energies' : [],
                       'values' : {'211' : [], '-211' : [],'111' : [],'321' : [],'-321' : [],'2212' : [],'-2212' : [], '3122' : [], '-3122' : []},
                       'errors' : {'211' : [], '-211' : [],'111' : [],'321' : [],'-321' : [],'2212' : [],'-2212' : [], '3122' : [], '-3122' : []}}

    for file in files:
        energy = file.split('/')[-3].split('_')[1]
        if 'v2' in file:
            data = np.loadtxt(file, unpack = True)
            bin_width = data[0][1] - data[0][0]
            data_collection['energies'].append(float(energy))

            data_collection['values']['211'].append(np.sum(data[1]) * bin_width)
            data_collection['values']['-211'].append(np.sum(data[3]) * bin_width)
            data_collection['values']['111'].append(np.sum(data[5]) * bin_width)
            data_collection['values']['321'].append(np.sum(data[7]) * bin_width)
            data_collection['values']['-321'].append(np.sum(data[9]) * bin_width)
            data_collection['values']['2212'].append(np.sum(data[11]) * bin_width)
            data_collection['values']['-2212'].append(np.sum(data[13]) * bin_width)
            data_collection['values']['3122'].append(np.sum(data[15]) * bin_width)
            data_collection['values']['-3122'].append(np.sum(data[17]) * bin_width)

            data_collection['errors']['211'].append(np.sum(data[2]) * bin_width)
            data_collection['errors']['-211'].append(np.sum(data[4]) * bin_width)
            data_collection['errors']['111'].append(np.sum(data[6]) * bin_width)
            data_collection['errors']['321'].append(np.sum(data[8]) * bin_width)
            data_collection['errors']['-321'].append(np.sum(data[10]) * bin_width)
            data_collection['errors']['2212'].append(np.sum(data[12]) * bin_width)
            data_collection['errors']['-2212'].append(np.sum(data[14]) * bin_width)
            data_collection['errors']['3122'].append(np.sum(data[16]) * bin_width)
            data_collection['errors']['-3122'].append(np.sum(data[18]) * bin_width)

        else:
            data = np.loadtxt(file)
            data_collection['energies'].append(float(energy))
            data_collection['values']['211'].append(data[0])
            data_collection['values']['-211'].append(data[2])
            data_collection['values']['111'].append(data[4])
            data_collection['values']['321'].append(data[6])
            data_collection['values']['-321'].append(data[8])
            data_collection['values']['2212'].append(data[10])
            data_collection['values']['-2212'].append(data[12])
            data_collection['values']['3122'].append(data[14])
            data_collection['values']['-3122'].append(data[16])

            data_collection['errors']['211'].append(data[1])
            data_collection['errors']['-211'].append(data[3])
            data_collection['errors']['111'].append(data[5])
            data_collection['errors']['321'].append(data[7])
            data_collection['errors']['-321'].append(data[9])
            data_collection['errors']['2212'].append(data[11])
            data_collection['errors']['-2212'].append(data[13])
            data_collection['errors']['3122'].append(data[15])
            data_collection['errors']['-3122'].append(data[17])

    # return collections.OrderedDict(sorted(data_collection.items(), key=lambda kv: kv[0]))
    return data_collection


def write_data(data, filename):
    with open(args.output_dir + filename, 'w') as f:
        f.write('# energy 211 211_error -211 -211_error 111 111_error 321 321_error -321 -321_error 2212 2212_error -2212 -2212_error 3122 3122_error -3122 -3122_error\n')
        for i in range(0, len(data['energies'])):
            f.write(str(data['energies'][i]) + '\t' +
                    str(data['values']['211'][i]) + '\t' + str(data['errors']['211'][i]) + '\t' +
                    str(data['values']['-211'][i]) + '\t' + str(data['errors']['-211'][i]) + '\t' +
                    str(data['values']['111'][i]) + '\t' + str(data['errors']['111'][i]) + '\t' +
                    str(data['values']['321'][i]) + '\t' + str(data['errors']['321'][i]) + '\t' +
                    str(data['values']['-321'][i]) + '\t' + str(data['errors']['-321'][i]) + '\t' +
                    str(data['values']['2212'][i]) + '\t' + str(data['errors']['2212'][i]) + '\t' +
                    str(data['values']['-2212'][i]) + '\t' + str(data['errors']['-2212'][i]) + '\t' +
                    str(data['values']['3122'][i]) + '\t' + str(data['errors']['3122'][i]) + '\t' +
                    str(data['values']['-3122'][i]) + '\t' + str(data['errors']['-3122'][i]) + '\n')
    f.close()


def plotting(data, obs):
    sns.set_palette("mako", 3)

    # plt.errorbar(data['energies'], data['values']['211'], data['errors']['211'], label = r'$\pi^+$', marker = 'o', ls = ':', lw = 0.5)
    plt.errorbar(data['energies'], data['values']['-211'], data['errors']['-211'], label = r'$\pi^-$', marker = 'o', ls = ':', lw = 0.5)
    plt.errorbar(data['energies'], data['values']['-321'], data['errors']['-321'], label = r'$K^-$', marker = 'o', ls = ':', lw = 0.5)
    # plt.errorbar(data['energies'], data['values']['321'], data['errors']['321'], label = r'$K^+$', marker = 'o', ls = ':', lw = 0.5)
    plt.errorbar(data['energies'], data['values']['2212'], data['errors']['2212'], label = r'$p$', marker = 'o', ls = ':', lw = 0.5)

    plt.legend()

    plt.xlim(1,500)
    plt.xscale('log')
    plt.xlabel(r'$\sqrt{s_\mathrm{NN}}$')
    if obs == 'midyY': plt.ylabel(r'dN/dy$|_{\mathrm{y=0}}$')
    else: plt.ylabel(r'$v_2^{\mathrm{int}}$')

    plt.tight_layout()
    if obs == 'midyY': plt.savefig(args.output_dir + 'midy_yield_exc_func.pdf')
    elif obs == 'v2': plt.savefig(args.output_dir + 'v2_exc_func.pdf')
    plt.close()



if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("--midyY_files", nargs = '+', required = False,
                        help = "Files containing the analyzed midy particle spectra.")
    parser.add_argument("--v2_files", nargs = '+', required = False,
                        help = "Files containing the analyzed v2 spectra.")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    args = parser.parse_args()

    data_midyY = collect_data(args.midyY_files)
    data_v2 = collect_data(args.v2_files)

    write_data(data_midyY, 'Excitation_Func_midy_Yield.txt')
    write_data(data_v2, 'Excitation_Func_int_v2.txt')

    plotting(data_midyY, 'midyY')
    plotting(data_v2, 'v2')
