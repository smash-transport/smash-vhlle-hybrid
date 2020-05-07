#!/usr/bin/python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import argparse
import linecache

mpl.rcParams['lines.linewidth'] = 2.0

def plot_y_spectra(file, output_path, energy, system, Nevents):
    ydata = np.loadtxt(file, unpack = True)

    plt.figure(figsize=(10,5))
    plt.subplot(121)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')

    if not args.average:
        # rapidity bins are uniform
        bin_width = ydata[0][1] - ydata[0][0]

        plt.plot(ydata[0], ydata[1]/(Nevents * bin_width), label = r'$\pi^+$')
        plt.plot(ydata[0], ydata[2]/(Nevents * bin_width), label = r'$\pi^-$')
        plt.plot(ydata[0], ydata[3]/(Nevents * bin_width), label = r'$\pi^0$', color = 'darkred')
        plt.plot(ydata[0], ydata[4]/(Nevents * bin_width), label = r'$K^+$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[5]/(Nevents * bin_width), label = r'$K^-$', ls = '--', color = 'C1')

        plt.fill_between(ydata[0], ydata[1]/(Nevents * bin_width) - np.sqrt(ydata[1])/(Nevents * bin_width), ydata[1]/(Nevents * bin_width) + np.sqrt(ydata[1])/(Nevents * bin_width), color = 'C0', alpha = 0.4, lw = 0.0)
        plt.fill_between(ydata[0], ydata[2]/(Nevents * bin_width) - np.sqrt(ydata[2])/(Nevents * bin_width), ydata[2]/(Nevents * bin_width) + np.sqrt(ydata[2])/(Nevents * bin_width), color = 'C1', alpha = 0.4, lw = 0.0)
        plt.fill_between(ydata[0], ydata[3]/(Nevents * bin_width) - np.sqrt(ydata[3])/(Nevents * bin_width), ydata[3]/(Nevents * bin_width) + np.sqrt(ydata[3])/(Nevents * bin_width), color = 'darkred', alpha = 0.4, lw = 0.0)
        plt.fill_between(ydata[0], ydata[4]/(Nevents * bin_width) - np.sqrt(ydata[4])/(Nevents * bin_width), ydata[4]/(Nevents * bin_width) + np.sqrt(ydata[4])/(Nevents * bin_width), color = 'C0', alpha = 0.4, lw = 0.0)
        plt.fill_between(ydata[0], ydata[5]/(Nevents * bin_width) - np.sqrt(ydata[5])/(Nevents * bin_width), ydata[5]/(Nevents * bin_width) + np.sqrt(ydata[5])/(Nevents * bin_width), color = 'C1', alpha = 0.4, lw = 0.0)

    else:
        plt.plot(ydata[0], ydata[1], label = r'$\pi^+$')
        plt.plot(ydata[0], ydata[3], label = r'$\pi^-$')
        plt.plot(ydata[0], ydata[5], label = r'$\pi^0$', color = 'darkred')
        plt.plot(ydata[0], ydata[7], label = r'K$^+$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[9], label = r'K$^-$', ls = '--', color = 'C1')

        plt.fill_between(ydata[0], ydata[1] - ydata[2], ydata[1] + ydata[2], alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], ydata[3] - ydata[4], ydata[3] + ydata[4], alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], ydata[5] - ydata[6], ydata[5] + ydata[6], alpha = 0.5, color = 'darkred', lw = 0.0)
        plt.fill_between(ydata[0], ydata[7] - ydata[8], ydata[7] + ydata[8], alpha = 0.5, color = 'C0', lw = 0.0)
        plt.fill_between(ydata[0], ydata[9] - ydata[10], ydata[9] + ydata[10], alpha = 0.5, color = 'C1', lw = 0.0)

    plt.legend(ncol = 2, loc = 'upper right')
    plt.ylabel('dN/dy')
    plt.xlabel('y')
    plt.xlim(-4,4)

    plt.subplot(122)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')

    if not args.average:
        plt.plot(ydata[0], ydata[6]/(Nevents * bin_width), label = r'p', ls = '-', color = 'C0')
        plt.plot(ydata[0], ydata[7]/(Nevents * bin_width), label = r'$\bar{p}$', ls = '-', color = 'C1')
        plt.plot(ydata[0], ydata[8]/(Nevents * bin_width), label = r'$\Lambda$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[9]/(Nevents * bin_width), label = r'$\bar{\Lambda}$', ls = '--', color = 'C1')

        plt.fill_between(ydata[0], ydata[6]/(Nevents * bin_width) - np.sqrt(ydata[6])/(Nevents * bin_width), ydata[6]/(Nevents * bin_width) + np.sqrt(ydata[6])/(Nevents * bin_width), color = 'C0', alpha = 0.4, lw = 0.0)
        plt.fill_between(ydata[0], ydata[7]/(Nevents * bin_width) - np.sqrt(ydata[7])/(Nevents * bin_width), ydata[7]/(Nevents * bin_width) + np.sqrt(ydata[7])/(Nevents * bin_width), color = 'C1', alpha = 0.4, lw = 0.0)
        plt.fill_between(ydata[0], ydata[8]/(Nevents * bin_width) - np.sqrt(ydata[8])/(Nevents * bin_width), ydata[8]/(Nevents * bin_width) + np.sqrt(ydata[8])/(Nevents * bin_width), color = 'C0', alpha = 0.4, lw = 0.0)
        plt.fill_between(ydata[0], ydata[9]/(Nevents * bin_width) - np.sqrt(ydata[9])/(Nevents * bin_width), ydata[9]/(Nevents * bin_width) + np.sqrt(ydata[9])/(Nevents * bin_width), color = 'C1', alpha = 0.4, lw = 0.0)

    else:
        plt.plot(ydata[0], ydata[11], label = r'p')
        plt.plot(ydata[0], ydata[13], label = r'$\bar{p}$')
        plt.plot(ydata[0], ydata[15], label = r'$\Lambda$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[17], label = r'$\bar{\Lambda}$', ls = '--', color = 'C1')

        plt.fill_between(ydata[0], ydata[11] - ydata[12], ydata[11] + ydata[12], alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], ydata[13] - ydata[14], ydata[13] + ydata[14], alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], ydata[15] - ydata[16], ydata[15] + ydata[16], alpha = 0.5, color = 'C0', lw = 0.0)
        plt.fill_between(ydata[0], ydata[17] - ydata[18], ydata[17] + ydata[18], alpha = 0.5, color = 'C1', lw = 0.0)


    plt.legend(ncol = 2, loc = 'upper right')
    plt.ylabel('dN/dy')
    plt.xlabel('y')
    plt.xlim(-4,4)

    plt.savefig(output_path)
    plt.close()


def plot_mT_spectra(file, output_path, energy, system, Nevents):
    ydata = np.loadtxt(file, unpack = True)

    m_pi = 0.138
    m_kaon = 0.495
    m_proton = 0.938
    m_lambda = 1.321

    plt.figure(figsize=(10,5))
    plt.subplot(121)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')

    if not args.average:
        # Get uneven bin sizes
        bin_edges = linecache.getline(file, 4)[17:-2].split(' ')
        # Remove white spaces
        for num, element in enumerate(bin_edges):
            if element == '': bin_edges.pop(num)
        bin_edges = np.array(bin_edges).astype('float')
        bin_width = bin_edges[1:] - bin_edges[:-1]

        plt.plot(ydata[0], ydata[1]/(Nevents * bin_width * (ydata[0] + m_pi)), label = r'$\pi^+$')
        plt.plot(ydata[0], ydata[2]/(Nevents * bin_width * (ydata[0] + m_pi)), label = r'$\pi^-$')
        plt.plot(ydata[0], ydata[3]/(Nevents * bin_width * (ydata[0] + m_pi)), label = r'$\pi^0$', color = 'darkred')
        plt.plot(ydata[0], ydata[4]/(Nevents * bin_width * (ydata[0] + m_kaon)), label = r'$K^+$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[5]/(Nevents * bin_width * (ydata[0] + m_kaon)), label = r'$K^-$', ls = '--', color = 'C1')

    else:
        plt.plot(ydata[0], ydata[1] / (ydata[0] + m_pi), label = r'$\pi^+$')
        plt.plot(ydata[0], ydata[3] / (ydata[0] + m_pi), label = r'$\pi^-$')
        plt.plot(ydata[0], ydata[5] / (ydata[0] + m_pi), label = r'$\pi^0$', color = 'darkred')
        plt.plot(ydata[0], ydata[7] / (ydata[0] + m_kaon), label = r'$K^+$', color = 'C0', ls = '--')
        plt.plot(ydata[0], ydata[9] / (ydata[0] + m_kaon), label = r'$K^-$', color = 'C1', ls = '--')

        plt.fill_between(ydata[0], (ydata[1] - ydata[2]) / (ydata[0] + m_pi), (ydata[1] + ydata[2]) / (ydata[0] + m_pi), alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], (ydata[3] - ydata[4]) / (ydata[0] + m_pi), (ydata[3] + ydata[4]) / (ydata[0] + m_pi), alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], (ydata[5] - ydata[6]) / (ydata[0] + m_pi), (ydata[5] + ydata[6]) / (ydata[0] + m_pi), alpha = 0.5, lw = 0.0, color = 'darkred')
        plt.fill_between(ydata[0], (ydata[7] - ydata[8]) / (ydata[0] + m_kaon), (ydata[7] + ydata[8]) / (ydata[0] + m_kaon), alpha = 0.5, lw = 0.0, color = 'C0')
        plt.fill_between(ydata[0], (ydata[9] - ydata[10]) / (ydata[0] + m_kaon), (ydata[9] + ydata[10]) / (ydata[0] + m_kaon), alpha = 0.5, lw = 0.0, color = 'C1')


    plt.legend(ncol = 2, loc = 'upper right')
    plt.ylabel(r'1/m$_\mathrm{T}$ d$^2$N/dm$_\mathrm{T}$dy|$_{y=0}$   [Gev$^{-2}$]')
    plt.yscale('log')
    plt.xlabel(r'm$_\mathrm{T}$ - m$_0$ [GeV]')
    plt.xlim(0,2.2)

    plt.subplot(122)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')

    if not args.average:
        plt.plot(ydata[0], ydata[6]/(Nevents * bin_width * (ydata[0] + m_proton)), label = r'p', ls = '-', color = 'C0')
        plt.plot(ydata[0], ydata[7]/(Nevents * bin_width * (ydata[0] + m_proton)), label = r'$\bar{p}$', ls = '-', color = 'C1')
        plt.plot(ydata[0], ydata[8]/(Nevents * bin_width * (ydata[0] + m_lambda)), label = r'$\Lambda$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[9]/(Nevents * bin_width * (ydata[0] + m_lambda)), label = r'$\bar{\Lambda}$', ls = '--', color = 'C1')

    else:
        plt.plot(ydata[0], ydata[11] / (ydata[0] + m_proton), label = r'$p$')
        plt.plot(ydata[0], ydata[13] / (ydata[0] + m_proton), label = r'$\bar{p}$')
        plt.plot(ydata[0], ydata[15] / (ydata[0] + m_lambda), label = r'$\Lambda$', color = 'C0', ls = '--')
        plt.plot(ydata[0], ydata[17] / (ydata[0] + m_lambda), label = r'$\bar{\Lambda}$', color = 'C1', ls = '--')

        plt.fill_between(ydata[0], (ydata[11] - ydata[12]) / (ydata[0] + m_proton), (ydata[11] + ydata[12]) / (ydata[0] + m_proton), alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], (ydata[13] - ydata[14]) / (ydata[0] + m_proton), (ydata[13] + ydata[14]) / (ydata[0] + m_proton), alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], (ydata[15] - ydata[16]) / (ydata[0] + m_lambda), (ydata[15] + ydata[16]) / (ydata[0] + m_lambda), alpha = 0.5, lw = 0.0, color = 'C0')
        plt.fill_between(ydata[0], (ydata[17] - ydata[18]) / (ydata[0] + m_lambda), (ydata[17] + ydata[18]) / (ydata[0] + m_lambda), alpha = 0.5, lw = 0.0, color = 'C1')

    plt.legend(ncol = 2, loc = 'upper right')
    plt.ylabel(r'1/m$_\mathrm{T}$ d$^2$N/dm$_\mathrm{T}$dy|$_{y=0}$   [Gev$^{-2}$]')
    plt.yscale('log')
    plt.xlabel(r'm$_\mathrm{T}$ - m$_0$ [GeV]')
    plt.xlim(0,2.2)

    plt.tight_layout()
    plt.savefig(output_path)
    plt.close()


def plot_pT_spectra(file, output_path, energy, system, Nevents):
    ydata = np.loadtxt(file, unpack = True)

    plt.figure(figsize=(10,5))
    plt.subplot(121)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')

    if not args.average:
        # Get uneven bin sizes
        bin_edges = linecache.getline(file, 4)[17:-2].split(' ')
        # Remove white spaces
        for num, element in enumerate(bin_edges):
            if element == '': bin_edges.pop(num)
        bin_edges = np.array(bin_edges).astype('float')
        bin_width = bin_edges[1:] - bin_edges[:-1]

        plt.plot(ydata[0], ydata[1]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\pi^+$')
        plt.plot(ydata[0], ydata[2]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\pi^-$')
        plt.plot(ydata[0], ydata[3]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\pi^0$', color = 'darkred')
        plt.plot(ydata[0], ydata[4]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$K^+$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[5]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$K^-$', ls = '--', color = 'C1')

    else:
        plt.plot(ydata[0], ydata[1]/(2 * np.pi * ydata[0]), label = r'$\pi^+$')
        plt.plot(ydata[0], ydata[3]/(2 * np.pi * ydata[0]), label = r'$\pi^-$')
        plt.plot(ydata[0], ydata[5]/(2 * np.pi * ydata[0]), label = r'$\pi^0$', color = 'darkred')
        plt.plot(ydata[0], ydata[7]/(2 * np.pi * ydata[0]), label = r'$K^+$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[9]/(2 * np.pi * ydata[0]), label = r'$K^-$', ls = '--', color = 'C1')

        plt.fill_between(ydata[0], (ydata[1] - ydata[2]) / (2 * np.pi * ydata[0]), (ydata[1] + ydata[2]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], (ydata[3] - ydata[4]) / (2 * np.pi * ydata[0]), (ydata[3] + ydata[4]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], (ydata[5] - ydata[6]) / (2 * np.pi * ydata[0]), (ydata[5] + ydata[6]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0, color = 'darkred')
        plt.fill_between(ydata[0], (ydata[7] - ydata[8]) / (2 * np.pi * ydata[0]), (ydata[7] + ydata[8]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0, color = 'C0')
        plt.fill_between(ydata[0], (ydata[9] - ydata[10]) / (2 * np.pi * ydata[0]), (ydata[9] + ydata[10]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0, color = 'C1')



    plt.legend(ncol = 2, loc = 'upper right')
    plt.yscale('log')
    plt.ylabel(r'1/(2$\pi$ p$_\mathrm{T}$) d$^2$N/dp$_\mathrm{T}$dy|$_{y=0}$   [Gev$^{-2}$]')
    plt.xlabel(r'p$_\mathrm{T}$ [GeV]')
    plt.xlim(0,2.0)
    plt.ylim(1e-1, 1e3)

    plt.subplot(122)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')

    if not args.average:
        plt.plot(ydata[0], ydata[6]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'p', ls = '-', color = 'C0')
        plt.plot(ydata[0], ydata[7]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\bar{p}$', ls = '-', color = 'C1')
        plt.plot(ydata[0], ydata[8]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\Lambda$', ls = '--', color = 'C0')
        plt.plot(ydata[0], ydata[9]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\bar{\Lambda}$', ls = '--', color = 'C1')

    else:
        plt.plot(ydata[0], ydata[11] / (2 * np.pi * ydata[0]), label = r'$p$')
        plt.plot(ydata[0], ydata[13] / (2 * np.pi * ydata[0]), label = r'$\bar{p}$')
        plt.plot(ydata[0], ydata[15] / (2 * np.pi * ydata[0]), label = r'$\Lambda$', color = 'C0', ls = '--')
        plt.plot(ydata[0], ydata[17] / (2 * np.pi * ydata[0]), label = r'$\bar{\Lambda}$', color = 'C1', ls = '--')

        plt.fill_between(ydata[0], (ydata[11] - ydata[12]) / (2 * np.pi * ydata[0]), (ydata[11] + ydata[12]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], (ydata[13] - ydata[14]) / (2 * np.pi * ydata[0]), (ydata[13] + ydata[14]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0)
        plt.fill_between(ydata[0], (ydata[15] - ydata[16]) / (2 * np.pi * ydata[0]), (ydata[15] + ydata[16]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0, color = 'C0')
        plt.fill_between(ydata[0], (ydata[17] - ydata[18]) / (2 * np.pi * ydata[0]), (ydata[17] + ydata[18]) / (2 * np.pi * ydata[0]), alpha = 0.5, lw = 0.0, color = 'C1')

    plt.legend(ncol = 2, loc = 'upper right')
    plt.ylabel(r'1/(2$\pi$ p$_\mathrm{T}$) d$^2$N/dp$_\mathrm{T}$dy|$_{y=0}$   [Gev$^{-2}$]')
    plt.yscale('log')
    plt.xlabel(r'p$_\mathrm{T}$ [GeV]')
    plt.xlim(0,2.0)

    plt.tight_layout()
    plt.savefig(output_path)
    plt.close()


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("--input_files", nargs = '+', required = False,
                        help = "Files containing the analyzed particle spectra.")
    parser.add_argument("--energy", required = True,
                        help = "Collision energy (sqrt(s)).")
    parser.add_argument("--system", required = True,
                        help = "Collision system.")
    parser.add_argument("--Nevents", required = True,
                        help = "Number of events.")
    parser.add_argument("--average", required = False, default = False,
                        help = "Whether to plot averaged quantities.")
    args = parser.parse_args()

    for file in args.input_files:
        observable = file.split('/')[-1].split('.')[0]
        plot_path_and_name = '/'.join(file.split('/')[:-1]) + '/' + observable + '.pdf'


        if observable in ['yspectra', 'dNdy']:
            plot_y_spectra(file, plot_path_and_name, args.energy, args.system, float(args.Nevents))
        elif observable in ['mtspectra', 'mT']:
            plot_mT_spectra(file, plot_path_and_name, args.energy, args.system, float(args.Nevents))
        elif observable in ['ptspectra', 'pT']:
            plot_pT_spectra(file, plot_path_and_name, args.energy, args.system, float(args.Nevents))
