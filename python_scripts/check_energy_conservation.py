#!/usr/bin/python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import argparse
import linecache
import sys

initial_nucleons = {'AuAu' : 394,
                    'PbPb' : 416}
PDG_codes =   [2112, 2212, 12112, 12212, 1214, 2124, 22112,
               22212, 32112, 32212, 2116, 2216, 12116, 12216, 21214,
               22124, 42112, 42212, 31214, 32124, 9902114, 9902214,
               9952112, 9952212, 9962112, 9962212, 9912114, 9912214,
               9902118, 9902218, 9922116, 9922216, 9922114, 9922214,
               9972112, 9972212, 9932114, 9932214, 1218, 2128,
               19922119, 19922219, 19932119, 19932219,
               1114, 2114, 2214, 2224, 31114, 32114, 32214,
               32224,1112, 1212, 2122, 2222, 11114, 12114,
               12214, 12224, 11112, 11212, 12122, 12222, 1116,
               1216, 2126, 2226, 21112, 21212, 22122, 22222,
               21114, 22114, 22214, 22224, 11116, 11216,
               12126, 12226, 1118, 2118, 2218, 2228,
               3122, 13122, 3124, 23122, 23122, 13124,
               43122, 53122, 3126, 13126, 23124, 3128,
               23126, 19903129,
               3112, 3212, 3222, 3114, 3214, 3224, 13112,
               13212, 13222, 13114, 13214, 13224, 23112,
               23212, 23222, 3116, 3216, 3226, 13116, 13216,
               13226, 23114, 23214, 23224, 3118, 3218, 3228,
               9903118, 9903218, 9903228,
               3312, 3322, 3314, 3324, 203312, 203322, 13314,
               13324, 103316, 103326, 203316, 203326,
               3334, 203338]

def energy_from_SMASH(file, N_initial):
    with sbs.BinaryReader(file) as reader:
        smash_version = reader.smash_version

        N_spectators = 0
        E_tot = 0.0         # Total energy excluding spectators
        num_events = -1
        net_baryon_number = 0
        Baryon_numbers = [0]
        for block in reader:
            if block["type"] == 'f':
                num_events = block["nevent"]
                if num_events < 49:
                    Baryon_numbers.append(0)
                net_baryon_number = 0
            if block["type"] == 'i': continue
            if block["type"] == 'p':
                for particle in block['part']:
                    PDG_id = particle[3]
                    if 'IC' in file:
                        if num_events > 0:  # start counting at 0
                            sys.exit('More than 1 event in SMASH initial conditions. Please adjust script.')
                        # only the IC file is in extended format.
                        # Script would crash if column 6 was read for non-extended format
                        p_id = particle[4]
                        Ncoll = particle[6]
                        if (p_id <= N_initial and Ncoll == 0):
                            N_spectators += 1
                        else:
                            E_tot += particle[2][0]
                            if abs(PDG_id) in PDG_codes:
                                NB = 1 if PDG_id > 0 else -1
                                # net_baryon_number += NB
                    else:
                        E_tot += particle[2][0]
                        if abs(PDG_id) in PDG_codes:
                            NB = 1 if PDG_id > 0 else -1
                            net_baryon_number += NB
                Baryon_numbers[num_events + 1] = net_baryon_number

    # print float(net_baryon_number) / (float(num_events) + 1.0)
    # return net_baryon_number / (num_events + 1),  E_tot / (num_events + 1)
    return np.mean(Baryon_numbers),  E_tot / (num_events + 1)

def energy_from_sampler(file):

    Energies = [0.0]
    Net_Baryons = [0]
    i = 0
    with open(file) as f:
        for line in f:
            if line.startswith('#!OSCAR2013'): continue
            elif line.startswith('# Units:'): continue
            elif line.startswith('# SMASH'): continue
            elif line.startswith('# event'):
                if i != (int(line.split(' ')[2]) - 1):
                    i = int(line.split(' ')[2]) - 1
                    Energies.append(0.0)
                    Net_Baryons.append(0)
            else:
                Energies[i] += float(line.split()[5])
                PDG_id = int(line.split()[9])
                if abs(PDG_id) in PDG_codes:
                    NB = 1 if PDG_id > 0 else -1
                    Net_Baryons[i] += NB

    return Net_Baryons, Energies

def plotting_E_conservation(IC_energy, Sampler_energy, Final_State_energy):

    Nevents = len(Sampler_energy)
    x = np.arange(1, len(Sampler_energy) + 1, 1)

    system, energy = args.output_path.split('/')[-2].split('_')

    plt.plot(x, [IC_energy]*Nevents, label = 'SMASH: Initial Energy', color = 'darkred', lw = 2)
    plt.bar(x, Sampler_energy, alpha = 0.5, label = 'Sampler: Energy per Event')
    plt.plot(x, [np.mean(Sampler_energy)]*Nevents, label = 'Sampler: Mean Energy', color = 'midnightblue', lw = 2)
    plt.plot(x, [Final_State_energy]*Nevents, label = 'SMASH: Final State Energy', color = 'orange', lw = 2, ls = '--')
    plt.legend()
    plt.title(system + r' @ $\mathbf{\sqrt{s}}$ = ' + energy + ' GeV', fontweight = 'bold')
    plt.xlim(0,51)
    plt.xlabel('Event')
    plt.ylabel(r'E$_\mathsf{tot}$ [GeV]')
    plt.tight_layout()
    plt.savefig(args.output_path + '/Energy_Conservation.pdf')
    plt.close()

def plotting_NB_conservation(IC_NB, Sampler_NB, Final_State_NB):

    Nevents = len(Sampler_NB)
    x = np.arange(1, len(Sampler_NB) + 1, 1)

    system, energy = args.output_path.split('/')[-2].split('_')

    plt.plot(x, [IC_NB]*Nevents, label = r'SMASH: Initial N$_\mathsf{B - \bar{B}}$', color = 'darkred', lw = 2)
    plt.bar(x, Sampler_NB, alpha = 0.5, label = r'Sampler: N$_\mathsf{B - \bar{B}}$ per Event')
    plt.plot(x, [np.mean(Sampler_NB)]*Nevents, label = r'Sampler: Mean N$_\mathsf{B - \bar{B}}$', color = 'midnightblue', lw = 2)
    plt.plot(x, [Final_State_NB]*Nevents, label = r'SMASH: Final State N$_\mathsf{B - \bar{B}}$', color = 'orange', lw = 2, ls = '--')
    plt.legend()
    plt.title(system + r' @ $\mathbf{\sqrt{s}}$ = ' + energy + ' GeV', fontweight = 'bold')
    plt.xlim(0,51)
    plt.xlabel('Event')
    plt.ylabel(r'N$_\mathsf{B - \bar{B}}$')
    plt.tight_layout()
    plt.savefig(args.output_path + '/Baryon_Number_Conservation.pdf')
    plt.close()



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--SMASH_IC", required = False,
                        help = "SMASH initial conditions.")
    parser.add_argument("--Sampler", required = True,
                        help = "Sampled particle lists.")
    parser.add_argument("--SMASH_final_state", required = True,
                        help = "Final state particle lists.")
    parser.add_argument("--SMASH_ana_path", required = True,
                        help = "Path to smash-analysis.")
    parser.add_argument("--output_path", required = True,
                        help = "Path to store results.")
    args = parser.parse_args()

    sys.path.append(args.SMASH_ana_path + '/python_scripts')
    import smash_basic_scripts as sbs

    collision_system = args.SMASH_IC.split('/')[-3].split('_')[0]
    initial_number_of_nucleons = initial_nucleons[collision_system]

    NB_SMASH_IC, E_SMASH_IC = energy_from_SMASH(args.SMASH_IC, initial_number_of_nucleons)
    NB_sampler_per_Event, E_sampler_per_Event = energy_from_sampler(args.Sampler)
    NB_SMASH_final_state, E_SMASH_final_state = energy_from_SMASH(args.SMASH_final_state, initial_number_of_nucleons)


    plotting_E_conservation(E_SMASH_IC, E_sampler_per_Event, E_SMASH_final_state)
    print 'Initial SMASH energy: ' + str(E_SMASH_IC)
    print 'Sampler energy: ' + str(np.mean(E_sampler_per_Event))
    print 'Final SMASH energy: ' + str(E_SMASH_final_state)
    print 'Energy gain/loss: ' + str(round(100 * ((E_SMASH_final_state / E_SMASH_IC) -1),2) ) + ' %'
    # plotting_NB_conservation(NB_SMASH_IC, NB_sampler_per_Event, NB_SMASH_final_state)
