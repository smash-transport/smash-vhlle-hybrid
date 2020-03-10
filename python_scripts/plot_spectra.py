#!/usr/bin/python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import argparse
import linecache

mpl.rcParams['lines.linewidth'] = 2.0

def plot_y_spectra(file, output_path, energy, system, Nevents):
    ydata = np.loadtxt(file, unpack = True)

    Npionsplus = np.sum(ydata[1]) / float(Nevents)

    print 'Number of pi+ = ' + str(Npionsplus)
    print 'Midrapiity pion yield = ' + str(ydata[1][16] / float(Nevents))

    # rapidity bins are uniform
    bin_width = ydata[0][1] - ydata[0][0]

    plt.figure(figsize=(10,5))
    plt.subplot(121)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')
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
    plt.legend(ncol = 2, loc = 'upper right')
    plt.ylabel('dN/dy')
    plt.xlabel('y')
    plt.xlim(-4,4)

    plt.subplot(122)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')
    plt.plot(ydata[0], ydata[6]/(Nevents * bin_width), label = r'p', ls = '-', color = 'C0')
    plt.plot(ydata[0], ydata[7]/(Nevents * bin_width), label = r'$\bar{p}$', ls = '-', color = 'C1')
    plt.plot(ydata[0], ydata[8]/(Nevents * bin_width), label = r'$\Lambda$', ls = '--', color = 'C0')
    plt.plot(ydata[0], ydata[9]/(Nevents * bin_width), label = r'$\bar{\Lambda}$', ls = '--', color = 'C1')

    plt.fill_between(ydata[0], ydata[6]/(Nevents * bin_width) - np.sqrt(ydata[6])/(Nevents * bin_width), ydata[6]/(Nevents * bin_width) + np.sqrt(ydata[6])/(Nevents * bin_width), color = 'C0', alpha = 0.4, lw = 0.0)
    plt.fill_between(ydata[0], ydata[7]/(Nevents * bin_width) - np.sqrt(ydata[7])/(Nevents * bin_width), ydata[7]/(Nevents * bin_width) + np.sqrt(ydata[7])/(Nevents * bin_width), color = 'C1', alpha = 0.4, lw = 0.0)
    plt.fill_between(ydata[0], ydata[8]/(Nevents * bin_width) - np.sqrt(ydata[8])/(Nevents * bin_width), ydata[8]/(Nevents * bin_width) + np.sqrt(ydata[8])/(Nevents * bin_width), color = 'C0', alpha = 0.4, lw = 0.0)
    plt.fill_between(ydata[0], ydata[9]/(Nevents * bin_width) - np.sqrt(ydata[9])/(Nevents * bin_width), ydata[9]/(Nevents * bin_width) + np.sqrt(ydata[9])/(Nevents * bin_width), color = 'C1', alpha = 0.4, lw = 0.0)

    plt.legend(ncol = 2, loc = 'upper right')
    plt.ylabel('dN/dy')
    plt.xlabel('y')
    plt.xlim(-4,4)

    plt.savefig(output_path)
    plt.close()


def plot_mT_spectra(file, output_path, energy, system, Nevents):
    ydata = np.loadtxt(file, unpack = True)

    # Get uneven bin sizes
    bin_edges = linecache.getline(file, 4)[17:-2].split(' ')
    # Remove white spaces
    for num, element in enumerate(bin_edges):
        if element == '': bin_edges.pop(num)
    bin_edges = np.array(bin_edges).astype('float')
    bin_width = bin_edges[1:] - bin_edges[:-1]


    m_pi = 0.138
    m_kaon = 0.495
    m_proton = 0.938
    m_lambda = 1.321

    plt.figure(figsize=(10,5))
    plt.subplot(121)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')
    plt.plot(ydata[0], ydata[1]/(Nevents * bin_width * (ydata[0] + m_pi)), label = r'$\pi^+$')
    plt.plot(ydata[0], ydata[2]/(Nevents * bin_width * (ydata[0] + m_pi)), label = r'$\pi^-$')
    plt.plot(ydata[0], ydata[3]/(Nevents * bin_width * (ydata[0] + m_pi)), label = r'$\pi^0$', color = 'darkred')
    plt.plot(ydata[0], ydata[4]/(Nevents * bin_width * (ydata[0] + m_kaon)), label = r'$K^+$', ls = '--', color = 'C0')
    plt.plot(ydata[0], ydata[5]/(Nevents * bin_width * (ydata[0] + m_kaon)), label = r'$K^-$', ls = '--', color = 'C1')
    plt.legend(ncol = 2, loc = 'upper right')
    plt.ylabel(r'1/m$_\mathrm{T}$ d$^2$N/dm$_\mathrm{T}$dy|$_{y=0}$   [Gev$^{-2}$]')
    plt.yscale('log')
    plt.xlabel(r'm$_\mathrm{T}$ - m$_0$ [GeV]')
    plt.xlim(0,2.2)

    plt.subplot(122)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')
    plt.plot(ydata[0], ydata[6]/(Nevents * bin_width * (ydata[0] + m_proton)), label = r'p', ls = '-', color = 'C0')
    plt.plot(ydata[0], ydata[7]/(Nevents * bin_width * (ydata[0] + m_proton)), label = r'$\bar{p}$', ls = '-', color = 'C1')
    plt.plot(ydata[0], ydata[8]/(Nevents * bin_width * (ydata[0] + m_lambda)), label = r'$\Lambda$', ls = '--', color = 'C0')
    plt.plot(ydata[0], ydata[9]/(Nevents * bin_width * (ydata[0] + m_lambda)), label = r'$\bar{\Lambda}$', ls = '--', color = 'C1')
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

    # Get uneven bin sizes
    bin_edges = linecache.getline(file, 4)[17:-2].split(' ')
    # Remove white spaces
    for num, element in enumerate(bin_edges):
        if element == '': bin_edges.pop(num)
    bin_edges = np.array(bin_edges).astype('float')
    bin_width = bin_edges[1:] - bin_edges[:-1]

    print bin_width

    plt.figure(figsize=(10,5))
    plt.subplot(121)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')
    plt.plot(ydata[0], ydata[1]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\pi^+$')
    plt.plot(ydata[0], ydata[2]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\pi^-$')
    plt.plot(ydata[0], ydata[3]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\pi^0$', color = 'darkred')
    plt.plot(ydata[0], ydata[4]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$K^+$', ls = '--', color = 'C0')
    plt.plot(ydata[0], ydata[5]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$K^-$', ls = '--', color = 'C1')
    plt.legend(ncol = 2, loc = 'upper right')
    plt.yscale('log')
    plt.ylabel(r'1/(2$\pi$ p$_\mathrm{T}$) d$^2$N/dp$_\mathrm{T}$dy|$_{y=0}$   [Gev$^{-2}$]')
    plt.xlabel(r'p$_\mathrm{T}$ [GeV]')
    plt.xlim(0,2.0)
    plt.ylim(1e-1, 1e3)

    plt.subplot(122)
    plt.title(str(system) + r' @ $\sqrt{s}$ = ' + str(energy) + ' GeV')
    plt.plot(ydata[0], ydata[6]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'p', ls = '-', color = 'C0')
    plt.plot(ydata[0], ydata[7]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\bar{p}$', ls = '-', color = 'C1')
    plt.plot(ydata[0], ydata[8]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\Lambda$', ls = '--', color = 'C0')
    plt.plot(ydata[0], ydata[9]/(Nevents * bin_width * 2 * np.pi * ydata[0]), label = r'$\bar{\Lambda}$', ls = '--', color = 'C1')
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
    args = parser.parse_args()

    for file in args.input_files:
        observable = file.split('/')[-1].split('.')[0]
        plot_path_and_name = '/'.join(file.split('/')[:-1]) + '/' + observable + '.pdf'

        if observable == 'yspectra':
            plot_y_spectra(file, plot_path_and_name, args.energy, args.system, float(args.Nevents))
        elif observable ==  'mtspectra':
            plot_mT_spectra(file, plot_path_and_name, args.energy, args.system, float(args.Nevents))
        elif observable ==  'ptspectra':
            plot_pT_spectra(file, plot_path_and_name, args.energy, args.system, float(args.Nevents))
