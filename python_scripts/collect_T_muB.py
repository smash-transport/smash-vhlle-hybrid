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

def parametrization_cleymans(sqrts):
    # taken from \cite{Cleymans:2006qe}, \cite{Cleymans:1998fq}
    muB = 1.308 / (1.0 + 0.273 * sqrts)
    T = 0.166 - 0.139 * muB*muB - 0.053 * muB*muB*muB*muB

    return muB, T

def assemble_coordinates():
    energies = []
    T, muB = [], []
    T_sigma, muB_sigma = [], []
    for file in args.files:
        energy = float(file.split('/')[-3].split('_')[-1])
        energies.append(energy)
        data = np.loadtxt(file)
        muB.append(data[0])
        muB_sigma.append(data[1])
        T.append(data[2])
        T_sigma.append(data[3])

    # sort in order of energies
    energies, muB, muB_sigma, T, T_sigma =[list(v) for v in zip(*sorted(zip(energies, muB, muB_sigma, T, T_sigma)))]
    print energies

    return energies, muB, muB_sigma, T, T_sigma



def plot_freezeout(data):
    sns.set_palette('mako_r', len(data[1]))

    # parametrization
    sqrts = np.arange(1, 2000, 0.1)
    param = parametrization_cleymans(sqrts)

    plt.figure(figsize=(4.5,3.5))
    # plot data from hybrid
    for i in range(0, len(data[1])):
        if i == 0 or i == len(data[1])-1: plt.errorbar(data[1][i], data[3][i], xerr = data[2][i], yerr = data[4][i], marker = 's', ls = 'none', lw = 2, label = r'$\sqrt{s_\mathrm{NN}}$ = ' + str(data[0][i]) + ' GeV', markersize = 3)
        else: plt.errorbar(data[1][i], data[3][i], xerr = data[2][i], yerr = data[4][i], marker = 's', ls = 'none', lw = 2, markersize = 3)

    # plot parametrization
    plt.plot(param[0], param[1], color ='#B1306B', lw = 1.8, label = 'Cleymans et al.', zorder = 0, ls = '-')

    plt.legend(frameon = False)
    plt.ylabel('T [GeV]')
    plt.xlabel(r'$\mu_\mathrm{B}$ [GeV]')
    plt.xlim(0,0.8)
    plt.ylim(0.12, 0.18)

    plt.tight_layout()
    plt.savefig(args.output_dir + 'freezeout_diagram.pdf')
    plt.close()


def write_file(data):
    with open(args.output_dir + 'Freezeout_Diagram.txt', 'w') as f:
        f.write('# energy \t muB \t muB_sigma \t T \t T_sigma \n')
        for i in range(0, len(data[0])):
            line = ''
            for k in range(0, 5):
                if k == 0: line += str(data[k][i])
                else: line += '\t' + str(data[k][i])
            line += '\n'
            f.write(line)
    f.close()


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("--files", nargs = '+', required = False,
                        help = "Files containing the analyzed midy particle spectra.")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    args = parser.parse_args()


    coordinates = assemble_coordinates()
    plot_freezeout(coordinates)
    write_file(coordinates)
