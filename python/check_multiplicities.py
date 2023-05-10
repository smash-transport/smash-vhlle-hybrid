#!/usr/bin/python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import argparse
import linecache
import sys
from scipy.special import kn #for bessel functions
import matplotlib.gridspec as gridspec

'''
    This script determines the expectation values of the particle multiplicites
    from the freezeout hypersurface and compares the results to the
    multiplicities sampled by the particle sampler.
'''

# constant for conversion
hbarc = 0.197327

def scalar_product(a, b):
    # No need to consider the metric or similar here. u_\mu is contravariant,
    # dSigma_\mu is covariant. So the metric tensor does not need to be applied.
    # The scalar product is then simply the sum of the multiplied components
    a_dot_b = a[0] * b[0] + a[1] * b[1] + a[2] * b[2] + a[3] * b[3]

    return a_dot_b

def get_multiplicities_boltzmann(g, mass, temp, volume, chem_pot):
    if (temp > 0.0):
        multiplicity = g * mass * mass * temp * volume / (2.0 * np.pi * np.pi)
        multiplicity *= kn(2, mass / temp)
        multiplicity *= np.exp(chem_pot / temp)

    else:
        multiplicity = 0.0
    return multiplicity / hbarc**3

def get_multiplicities_bose(g, mass, temp, volume, chem_pot):
    if temp > 0.0:
        multiplicity = g * mass * mass * temp * volume / (2.0 * np.pi * np.pi)

        sum = 0.0
        for k in range(1, 21):
            sum += 1/float(k) * kn(2, k * mass / temp)

        multiplicity *= sum
        multiplicity *= np.exp(chem_pot / temp)
    else:
        multiplicity = 0.0

    return multiplicity / hbarc**3

def Multiplicities_from_Hypersurface(file):
    hyp_data = np.loadtxt(file, unpack = True)

    # get T and muB
    temp = hyp_data[12]
    muB = hyp_data[13]
    muQ = hyp_data[14]
    muS = hyp_data[15]

    # get dSigma and u^mu
    dSigma_mu = []
    umu = []
    for i in range(0, len(temp)):
        dSigma_mu.append([hyp_data[4][i], hyp_data[5][i],
               hyp_data[6][i], hyp_data[7][i]])
        umu.append([hyp_data[8][i], hyp_data[9][i],
               hyp_data[10][i], hyp_data[11][i]])

    # Determine expected multiplicities:
    Npion_plus = 0.0
    Npion_minus = 0.0
    Npion_zero = 0.0
    Nrho_plus = 0.0
    Nrho_minus = 0.0
    Nrho_zero = 0.0
    Nproton = 0.0
    Nantiproton = 0.0
    for element in range(0, len(temp)):
        V = scalar_product(umu[element], dSigma_mu[element])
        T = temp[element]

        # pi+: Q = 1, pi-: Q = -1, pi0: Q = 0
        Npion_plus += get_multiplicities_bose(1.0, 0.138, T, V, muQ[element] * 1.0)
        Npion_minus += get_multiplicities_bose(1.0, 0.138, T, V, muQ[element] * (-1.0))
        Npion_zero += get_multiplicities_bose(1.0, 0.138, T, V, 0.0)
        # rho+: Q = 1, rho-: Q = -1, rho: Q = 0
        Nrho_plus += get_multiplicities_boltzmann(3.0, 0.776, T, V,  muQ[element] * 1.0)
        Nrho_minus += get_multiplicities_boltzmann(3.0, 0.776, T, V,  muQ[element] * (-1.0))
        Nrho_zero += get_multiplicities_boltzmann(3.0, 0.776, T, V,  0.0)
        # proton: B=Q=+1, antiproton: B=Q=-1
        Nproton += get_multiplicities_boltzmann(2.0, 0.938, T, V, muB[element] * 1.0 + muQ[element] * 1.0)
        Nantiproton += get_multiplicities_boltzmann(2.0, 0.938, T, V, -muB[element] * 1.0 - muQ[element] * 1.0)

    return [[Npion_plus, Npion_minus, Npion_zero], [Nrho_plus, Nrho_minus, Nrho_zero], [Nproton, Nantiproton]]

def Multiplicities_from_Sampled_List(file):

    Multiplicities = {'211' : [0], '-211' : [0], '111' : [0],
                      '213' : [0], '-213' : [0], '113' : [0],
                      '2112' : [0], '-2112' : [0]}

    i = 0
    with open(file) as f:
        for line in f:
            # if i > 19: continue
            if line.startswith('#!OSCAR2013'): continue
            elif line.startswith('# Units:'): continue
            elif line.startswith('# SMASH'): continue
            elif line.startswith('# event'):
                if i != (int(line.split(' ')[2])):
                    i = int(line.split(' ')[2])
                    for value in Multiplicities.values():
                        value.append(0)
            else:
                PDG_id = int(line.split()[9])
                if str(PDG_id) in Multiplicities.keys():
                    Multiplicities[str(PDG_id)][i] += 1

    return Multiplicities

def plot_Multiplicities(Mult_Hyper, Mult_Sampler):

    Nevents = len(Mult_Sampler['211'])
    x = np.arange(1, Nevents + 1, 1).astype(int)
    width = 0.2

    ##############
    # Pions
    ##############
    gs = gridspec.GridSpec(1,20)
    plt.figure(figsize=(8,4))
    plt.subplot(gs[:, :18])
    plt.bar(x - width, Mult_Sampler['211'], width, label = r'$\pi^+$', color = 'C0')
    plt.bar(x, Mult_Sampler['-211'], width, label = r'$\pi^-$', color = 'C1')
    plt.bar(x + width, Mult_Sampler['111'], width, label = r'$\pi^0$', color = 'darkred')
    plt.axhline(10 * Mult_Hyper[0][0], color = 'grey', label = 'Theo. Exp.', lw = 4, alpha = 0.7) #dummy for legend entry
    plt.legend(ncol = 4)
    plt.xlim(0.5, 20.5)
    plt.ylim(0, 125)
    plt.xticks([5,10,15,20])
    plt.xlabel('Events')
    plt.ylabel('Multiplicity')

    plt.subplot(gs[:, 18:])
    plt.bar(1 - width, np.mean(Mult_Sampler['211']), width, label = r'$\pi^+$', color = 'C0')
    plt.bar(1, np.mean(Mult_Sampler['-211']), width, label = r'$\pi^-$', color = 'C1')
    plt.bar(1 + width, np.mean(Mult_Sampler['111']), width, label = r'$\pi^0$', color = 'darkred')
    plt.axhline(Mult_Hyper[0][0], color = 'C0', label = 'Theo. Exp.', lw = 4, alpha = 0.7)
    plt.axhline(Mult_Hyper[0][1], color = 'C1', label = 'Theo. Exp.', lw = 4, alpha = 0.7)
    plt.axhline(Mult_Hyper[0][2], color = 'darkred', label = 'Theo. Exp.', lw = 4, alpha = 0.7)
    plt.xlim(0.5, 1.5)
    plt.ylim(0, 125)
    plt.figtext(0.921, 0.85, 'Mean:\n' + str(Nevents) + '\nevents', bbox=dict(facecolor='none', edgecolor='gainsboro', boxstyle='round'), fontsize = 8)
    plt.xticks([], [])
    plt.yticks([], [])
    plt.tight_layout()
    plt.savefig(args.output_path + '/Pions.pdf')
    plt.close()


    ##############
    # Rhos
    ##############

    gs = gridspec.GridSpec(1,20)
    plt.figure(figsize=(8,4))
    plt.subplot(gs[:, :18])
    plt.bar(x - width, Mult_Sampler['213'], width, label = r'$\rho^+$', color = 'C0')
    plt.bar(x, Mult_Sampler['-213'], width, label = r'$\rho^-$', color = 'C1')
    plt.bar(x + width, Mult_Sampler['113'], width, label = r'$\rho^0$', color = 'darkred')
    plt.axhline(10 * Mult_Hyper[1][1], color = 'grey', label = 'Theo. Exp.', lw = 4, alpha = 0.7) #dummy for legend entry
    plt.legend(ncol = 4)
    plt.xlim(0.5, 20.5)
    plt.ylim(0, 30)
    plt.xticks([5,10,15,20])
    plt.xlabel('Events')
    plt.ylabel('Multiplicity')

    plt.subplot(gs[:, 18:])
    plt.bar(1 - width, np.mean(Mult_Sampler['213']), width, label = r'$\pi^+$', color = 'C0')
    plt.bar(1, np.mean(Mult_Sampler['-213']), width, label = r'$\pi^-$', color = 'C1')
    plt.bar(1 + width, np.mean(Mult_Sampler['113']), width, label = r'$\pi^0$', color = 'darkred')
    plt.axhline(Mult_Hyper[1][0], color = 'C0', label = 'Theo. Exp.', lw = 4, alpha = 0.7)
    plt.axhline(Mult_Hyper[1][1], color = 'C1', label = 'Theo. Exp.', lw = 4, alpha = 0.7)
    plt.axhline(Mult_Hyper[1][2], color = 'darkred', label = 'Theo. Exp.', lw = 4, alpha = 0.7)
    plt.xlim(0.5, 1.5)
    plt.ylim(0, 30)
    plt.figtext(0.921, 0.85, 'Mean:\n' + str(Nevents) + '\nevents', bbox=dict(facecolor='none', edgecolor='gainsboro', boxstyle='round'), fontsize = 8)
    plt.xticks([], [])
    plt.yticks([], [])
    plt.tight_layout()
    plt.savefig(args.output_path + '/Rhos.pdf')
    plt.close()

    ##############
    # Protons
    ##############
    width = 0.5
    gs = gridspec.GridSpec(1,20)
    plt.figure(figsize=(8,4))
    plt.subplot(gs[:, :18])
    plt.bar(x, Mult_Sampler['2112'], width, label = r'p', color = 'C0')
    plt.bar(x, Mult_Sampler['-2112'], width, label = r'$\bar{\mathrm{p}}$', color = 'C1')
    plt.axhline(10 * Mult_Hyper[2][0], color = 'grey', label = 'Theo. Exp.', lw = 4, alpha = 0.7) #dummy for legend entry
    plt.legend(ncol = 4)
    plt.xlim(0.5, 20.5)
    plt.ylim(0, 110)
    plt.xticks([5,10,15,20])
    plt.xlabel('Events')
    plt.ylabel('Multiplicity')

    plt.subplot(gs[:, 18:])
    plt.bar(1, np.mean(Mult_Sampler['2112']), width, color = 'C0')
    plt.bar(1, np.mean(Mult_Sampler['-2112']), width, color = 'C1')
    plt.axhline(Mult_Hyper[2][0], color = 'C0', label = 'Theo. Exp.', lw = 4, alpha = 0.7)
    plt.axhline(Mult_Hyper[2][1], color = 'C1', label = 'Theo. Exp.', lw = 4, alpha = 0.7)
    plt.xlim(0.5, 1.5)
    plt.ylim(0, 110)
    plt.figtext(0.921, 0.85, 'Mean:\n' + str(Nevents) + '\nevents', bbox=dict(facecolor='none', edgecolor='gainsboro', boxstyle='round'), fontsize = 8)
    plt.xticks([], [])
    plt.yticks([], [])
    plt.tight_layout()
    plt.savefig(args.output_path + '/Protons.pdf')
    plt.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--Freezeout_Surface", required = True,
                        help = "Freezeout hypersurface from hydrodynamics.")
    parser.add_argument("--Sampler", required = True,
                        help = "Sampled particle lists.")
    parser.add_argument("--output_path", required = True,
                        help = "Path to store results.")
    args = parser.parse_args()


    Mult_Hypersurface = Multiplicities_from_Hypersurface(args.Freezeout_Surface)
    Mult_Sampler = Multiplicities_from_Sampled_List(args.Sampler)

    plot_Multiplicities(Mult_Hypersurface, Mult_Sampler)
