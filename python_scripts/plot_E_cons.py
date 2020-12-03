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

def collect_data():
    data_collection = {}
    for file in args.files:
        energy = file.split('/')[-3].split('_')[1]
        data = np.loadtxt(file)
        data_collection[float(energy)] = {'ratio' : [1.0, data[0], data[2], data[4], data[6]],
                                   'error' : [0.0, data[1], data[3], data[5], data[7]]}

    return collections.OrderedDict(sorted(data_collection.items(), key=lambda kv: kv[0]))


def write_data(data):
    with open(args.output_dir + 'E_conservation.txt', 'w') as f:
        f.write(str(data))
    f.close()


def plotting(data):
    colors = sns.color_palette("mako", len(args.files) + 1)

    i = 0
    for key in data:
        if key == 7.7: continue
        i += 1
        plt.plot([0,1,2,3,4], data[key]['ratio'], label = r'$\sqrt{\mathsf{s}}$ = ' + str(key) + ' GeV', color = colors[len(args.files) + 1 - i])
        plt.fill_between([0,1,2,3,4], np.array(data[key]['ratio']) - np.array(data[key]['error']), np.array(data[key]['ratio']) + np.array(data[key]['error']), lw = 0, alpha = 0.5, color = colors[len(args.files) + 1 - i])
    plt.show()

    plt.axvline(1.0, ls = ':', lw = 0.5, color = 'grey', zorder = 0)
    plt.axvline(2.0, ls = ':', lw = 0.5, color = 'grey', zorder = 0)
    plt.axvline(3.0, ls = ':', lw = 0.5, color = 'grey', zorder = 0)

    plt.figtext(0.17, 0.9, 'SMASH IC', fontweight = 'bold')
    plt.figtext(0.4, 0.9, 'vHLLE', fontweight = 'bold')
    plt.figtext(0.6, 0.9, 'Sampler', fontweight = 'bold')
    plt.figtext(0.8, 0.9, 'Afterburner', fontweight = 'bold')

    plt.legend(ncol = 1, loc = 'lower left')
    plt.ylabel(r'$\mathrm{E} \ / \ \mathrm{E}_\mathrm{Initial \ State}$')
    plt.ylim(0.7, 1.1)
    plt.xlim(0,4)
    plt.xticks([])

    plt.tight_layout()
    plt.savefig(args.output_dir + 'E_cons.pdf')
    plt.close()



if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("--files", nargs = '+', required = False,
                        help = "Files containing the analyzed particle spectra.")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    args = parser.parse_args()

    data = collect_data()
    write_data(data)

    plotting(data)
