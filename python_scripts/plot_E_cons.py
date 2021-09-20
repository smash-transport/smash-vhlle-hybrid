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
   This scripts plots the evolution of the energy conservation
'''

matplotlib.rcParams['lines.linewidth'] = 2.0
matplotlib.rcParams['axes.labelsize'] = 15
matplotlib.rcParams['legend.fontsize'] = 11

def collect_data(files):
    data_collection = {}
    for file in files:
        energy = file.split('/')[-3].split('_')[1]
        data = np.loadtxt(file)
        data_collection[float(energy)] = {'ratio' : [1.0, data[0], data[2], data[4], data[6]],
                                   'error' : [0.0, data[1], data[3], data[5], data[7]]}

    return collections.OrderedDict(sorted(data_collection.items(), key=lambda kv: kv[0]))


def write_data(data, name):
    with open(args.output_dir + name + '.txt', 'w') as f:
        f.write(str(data))
    f.close()


def plotting(data, name):
    colors = sns.color_palette("mako", len(args.E_files) + 1)

    i = 0
    for key in data:
        i += 1
        plt.plot([0,1,2,3,4], data[key]['ratio'], label = r'$\sqrt{\mathsf{s}}$ = ' + str(key) + ' GeV', color = colors[len(args.E_files) + 1 - i])
        plt.fill_between([0,1,2,3,4], np.array(data[key]['ratio']) - np.array(data[key]['error']), np.array(data[key]['ratio']) + np.array(data[key]['error']), lw = 0, alpha = 0.5, color = colors[len(args.E_files) + 1 - i])
    plt.show()

    plt.axvline(1.0, ls = ':', lw = 0.5, color = 'grey', zorder = 0)
    plt.axvline(2.0, ls = ':', lw = 0.5, color = 'grey', zorder = 0)
    plt.axvline(3.0, ls = ':', lw = 0.5, color = 'grey', zorder = 0)

    plt.figtext(0.17, 0.85, 'SMASH IC', fontweight = 'bold')
    plt.figtext(0.4, 0.85, 'vHLLE', fontweight = 'bold')
    plt.figtext(0.6, 0.85, 'Sampler', fontweight = 'bold')
    plt.figtext(0.8, 0.85, 'Afterburner', fontweight = 'bold')

    plt.title('Improved equation of state', color = 'darkred', fontweight = 'bold')

    plt.legend(ncol = 2, loc = 'lower left')
    if name == 'E_cons': plt.ylabel(r'$\mathrm{E} \ / \ \mathrm{E}_\mathrm{Initial \ State}$')
    elif name == 'B_cons': plt.ylabel(r'$\mathrm{B} \ / \ \mathrm{B}_\mathrm{Initial \ State}$')
    elif name == 'Q_cons': plt.ylabel(r'$\mathrm{Q} \ / \ \mathrm{Q}_\mathrm{Initial \ State}$')

    plt.ylim(0.85, 1.05)
    plt.xlim(0,4)
    plt.xticks([])
    plt.yticks([0.85, 0.9, 0.95, 1.0, 1.05])

    plt.tight_layout()
    plt.savefig(args.output_dir + name + '.pdf')
    plt.close()



if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("--E_files", nargs = '+', required = False,
                        help = "Files containing the E conservation.")
    parser.add_argument("--B_files", nargs = '+', required = False,
                        help = "Files containing the B conservation.")
    parser.add_argument("--Q_files", nargs = '+', required = False,
                        help = "Files containing the Q conservation.")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    args = parser.parse_args()

    E_data = collect_data(args.E_files)
    B_data = collect_data(args.B_files)
    Q_data = collect_data(args.Q_files)
    write_data(E_data, 'E_conservation')
    write_data(B_data, 'B_conservation')
    write_data(Q_data, 'Q_conservation')

    plotting(E_data, 'E_cons')
    plotting(B_data, 'B_cons')
    plotting(Q_data, 'Q_cons')
