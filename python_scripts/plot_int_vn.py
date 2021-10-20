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
                       'values' : {'v2' : [], 'v3' : []},
                       'errors' : {'v2' : [], 'v3' : []}}

    for file in files:
        energy = file.split('/')[-3].split('_')[1]
        with open(file) as f:
            f.readline()    # skip header
            f.readline()    # skip header
            data = f.readline().split()
            print energy
            data_collection['energies'].append(float(data[0]))
            data_collection['values']['v2'].append(float(data[1]))
            data_collection['values']['v3'].append(float(data[3]))
            data_collection['errors']['v2'].append(float(data[2]))
            data_collection['errors']['v3'].append(float(data[4]))


    # return collections.OrderedDict(sorted(data_collection.items(), key=lambda kv: kv[0]))
    return data_collection


def write_data(data, filename):
    with open(args.output_dir + filename, 'w') as f:
        f.write('# energy v2 v2_error v3 v3_error \n')
        for i in range(0, len(data['energies'])):
            f.write(str(data['energies'][i]) + '\t' +
                    str(data['values']['v2'][i]) + '\t' + str(data['errors']['v2'][i]) + '\t' +
                    str(data['values']['v3'][i]) + '\t' + str(data['errors']['v3'][i]) + '\n')
    f.close()


def plotting(data):
    sns.set_palette("mako", 3)

    # plt.errorbar(data['energies'], data['values']['211'], data['errors']['211'], label = r'$\pi^+$', marker = 'o', ls = ':', lw = 0.5)
    plt.errorbar(data['energies'], data['values']['v2'], data['errors']['v2'], label = r'$v_2$', marker = 'o', ls = ':', lw = 0.5)
    plt.errorbar(data['energies'], data['values']['v3'], data['errors']['v3'], label = r'$v_3$', marker = '^', ls = ':', lw = 0.5)
    plt.legend()

    plt.xlim(1,500)
    plt.xscale('log')
    plt.xlabel(r'$\sqrt{s_\mathrm{NN}}$')
    plt.ylabel(r'$v_2$ or $v_3$')

    plt.tight_layout()
    plt.savefig(args.output_dir + 'Integrated_vn_exc_func.pdf')
    plt.close()



if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("--vn_files", nargs = '+', required = False,
                        help = "Files containing the analyzed integrated vn.")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    args = parser.parse_args()

    data = collect_data(args.vn_files)
    write_data(data, 'Excitation_Func_int_vn.txt')

    plotting(data)
    # plotting(data_v2, 'v2')
    # plotting(data_meanpT, 'meanpT')
