#!/usr/bin/python
import numpy as np
import matplotlib as mpl
import matplotlib.pyplot as plt
import argparse
import linecache
import sys

PDG_codes =   [1112, 1114, 1116, 1118, 1212, 1214, 1216, 1218, 2112, 2114, 2116,
               2118, 2122, 2124, 2126, 2128, 2212, 2214, 2216, 2218, 2222, 2224,
               2226, 2228, 3112, 3114, 3116, 3118, 3122, 3124, 3126, 3128, 3212,
               3214, 3216, 3218, 3222, 3224, 3226, 3228, 3312, 3314, 3322, 3324,
               3334, 4112, 4114, 4122, 4132, 4212, 4214, 4222, 4224, 4232, 4312,
               4314, 4322, 4324, 4332, 4334, 4412, 4414, 4422, 4424, 4432, 4434,
               4444, 5112, 5114, 5122, 5132, 5142, 5212, 5214, 5222, 5224, 5232,
               5242, 5312, 5314, 5322, 5324, 5332, 5334, 5342, 5412, 5414, 5422,
               5424, 5432, 5434, 5442, 5444, 5512, 5514, 5522, 5524, 5532, 5534,
               5542, 5544, 5554, 11112, 11114, 11116, 11212, 11216, 12112, 12114,
               12116, 12122, 12126, 12212, 12214, 12216, 12222, 12224, 12226,
               13112, 13114, 13116, 13122, 13124, 13126, 13212, 13214, 13216,
               13222, 13224, 13226, 13314, 13324, 14122, 21112, 21114, 21212,
               21214, 22112, 22114, 22122, 22124, 22212, 22214, 22222, 22224,
               23112, 23114, 23122, 23124, 23126, 23212, 23214, 23222, 23224,
               31214, 32112, 32124, 32212, 33122, 42112, 42212, 43122, 53122,
               103316, 103326, 203312, 203316, 203322, 203326, 203338, 9902114,
               9902118, 9902214, 9902218, 9903118, 19903129, 9903218, 9903228,
               9912114, 9912214, 9922114, 9922116, 19922119, 9922214, 9922216,
               19922219, 9932114, 19932119, 9932214, 19932219, 9952112, 9952212,
               9962112, 9962212, 9972112, 9972212, -1112, -1114, -1116, -1118,
               -1212, -1214, -1216, -1218, -2112, -2114, -2116, -2118, -2122,
               -2124, -2126, -2128, -2212, -2214, -2216, -2218, -2222, -2224,
               -2226, -2228, -3112, -3114, -3116, -3118, -3122, -3124, -3126,
               -3128, -3212, -3214, -3216, -3218, -3222, -3224, -3226, -3228,
               -3312, -3314, -3322, -3324, -3334, -4112, -4114, -4122, -4132,
               -4212, -4214, -4222, -4224, -4232, -4312, -4314, -4322, -4324,
               -4332, -4334, -4412, -4414, -4422, -4424, -4432, -4434, -4444,
               -5112, -5114, -5122, -5132, -5142, -5212, -5214, -5222, -5224,
               -5232, -5242, -5312, -5314, -5322, -5324, -5332, -5334, -5342,
               -5412, -5414, -5422, -5424, -5432, -5434, -5442, -5444, -5512,
               -5514, -5522, -5524, -5532, -5534, -5542, -5544, -5554, -11112,
               -11114, -11116, -11212, -11216, -12112, -12114, -12116, -12122,
               -12126, -12212, -12214, -12216, -12222, -12224, -12226, -13112,
               -13114, -13116, -13122, -13124, -13126, -13212, -13214, -13216,
               -13222, -13224, -13226, -13314, -13324, -14122, -21112, -21114,
               -21212, -21214, -22112, -22114, -22122, -22124, -22212, -22214,
               -22222, -22224, -23112, -23114, -23122, -23124, -23126, -23212,
               -23214, -23222, -23224, -31214, -32112, -32124, -32212, -33122,
               -42112, -42212, -43122, -53122, -103316, -103326, -203312,
               -203316, -203322, -203326, -203338, -9902114, -9902118, -9902214,
               -9902218, -9903118, -19903129, -9903218, -9903228, -9912114,
               -9912214, -9922114, -9922116, -19922119, -9922214, -9922216,
               -19922219, -9932114, -19932119, -9932214, -19932219, -9952112,
               -9952212, -9962112, -9962212, -9972112, -9972212]

def energy_from_binary(file):
    with sbs.BinaryReader(file) as reader:
        smash_version = reader.smash_version

        E_tot = 0.0
        num_events = -1         # Counter to dynamically determine event number
        net_baryon_number = 0
        Baryon_numbers = [0]
        for block in reader:
            if block["type"] == 'f':
                num_events = block["nevent"]
                if num_events < args.Nevents:
                    Baryon_numbers.append(0)
                net_baryon_number = 0
            if block["type"] == 'i': continue
            if block["type"] == 'p':
                for particle in block['part']:
                    PDG_id = particle[3]
                    E_tot += particle[2][0]
                    if abs(PDG_id) in PDG_codes:
                        NB = 1 if PDG_id > 0 else -1
                        net_baryon_number += NB
                Baryon_numbers[num_events + 1] = net_baryon_number

    return np.mean(Baryon_numbers),  E_tot / (float(args.Nevents))

def energy_from_hydro(file):
    f = open(file, 'r')
    lines_header = 37   #to be skipped
    for index, line in enumerate(f.readlines()):
        # skip header
        if index <= 37: continue
        if line.startswith('corona'): continue
        # Find values before grid resize
        if line.startswith('grid'):
            NB_before = baryon_number
            E_before = energy
            baryon_number = 0.0
            energy = 0.0
        else:
            baryon_number, energy = float(line.split()[3]), float(line.split()[5])
    # Find values before grid resize
    NB_after = baryon_number
    E_after = energy

    NB_tot = NB_before + NB_after
    E_tot = E_before + E_after

    return NB_tot, E_tot


def energy_from_oscar(file):

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

def plotting_E_conservation(IC_energy, hydro_energy, Sampler_energy, Final_State_energy):

    Nevents = int(args.Nevents)
    x = np.arange(1, len(Sampler_energy) + 1, 1)

    system, energy = args.output_path.split('/')[-3].split('_')

    plt.plot(x, [IC_energy]*Nevents, label = 'SMASH: Initial Energy', color = 'darkred', lw = 2)
    plt.bar(x, Sampler_energy, alpha = 0.3, label = 'Sampler: Energy per Event')
    plt.plot(x, [hydro_energy] * Nevents, label = 'Hydro: Energy through Surface', color = 'green', lw = 2)
    plt.plot(x, [np.mean(Sampler_energy)]*Nevents, label = 'Sampler: Mean Energy', color = 'midnightblue', lw = 2)
    plt.plot(x, [Final_State_energy]*Nevents, label = 'SMASH: Final State Energy', color = 'orange', lw = 2, ls = '--')
    plt.legend(title = r'$\Delta$E = ' + str(round(100*(np.mean(Final_State_energy)/IC_energy - 1),2)) + ' %')
    # plt.legend(title = r'$\Delta$E (Final / Initial) = ' + str(round(100*(np.mean(Final_State_energy)/IC_energy - 1),2)) + ' %')
    plt.title(system + r' @ $\mathbf{\sqrt{s}}$ = ' + energy + ' GeV', fontweight = 'bold')
    plt.xlim(0,Nevents + 1)
    plt.xlabel('Event')
    plt.ylabel(r'E$_\mathsf{tot}$ [GeV]')
    plt.tight_layout()

    plt.savefig(args.output_path + '/Energy_Conservation.pdf')
    plt.close()

def plotting_NB_conservation(IC_NB, hydro_NB, Sampler_NB, Final_State_NB):

    Nevents = int(args.Nevents)
    x = np.arange(1, len(Sampler_NB) + 1, 1)

    system, energy = args.output_path.split('/')[-3].split('_')

    plt.plot(x, [IC_NB]*Nevents, label = r'SMASH: Initial N$_\mathsf{B - \bar{B}}$', color = 'darkred', lw = 2)
    plt.bar(x, Sampler_NB, alpha = 0.3, label = r'Sampler: N$_\mathsf{B - \bar{B}}$ per Event')
    plt.plot(x, [hydro_NB]*Nevents, label = r'Hydro: N$_\mathsf{B - \bar{B}}$', color = 'green', lw = 2)
    plt.plot(x, [np.mean(Sampler_NB)]*Nevents, label = r'Sampler: Mean N$_\mathsf{B - \bar{B}}$', color = 'midnightblue', lw = 2)
    plt.plot(x, [Final_State_NB]*Nevents, label = r'SMASH: Final State N$_\mathsf{B - \bar{B}}$', color = 'orange', lw = 2, ls = '--')
    plt.legend(title = r'$\Delta$N$_\mathsf{B}$ = ' + str(round(100*(np.mean(Final_State_NB)/IC_NB - 1),2)) + ' %')
    plt.title(system + r' @ $\mathbf{\sqrt{s}}$ = ' + energy + ' GeV', fontweight = 'bold')
    plt.xlim(0,Nevents + 1)
    plt.xlabel('Event')
    plt.ylabel(r'N$_\mathsf{B - \bar{ B}}$')
    plt.tight_layout()
    plt.savefig(args.output_path + '/Baryon_Number_Conservation.pdf')
    plt.close()



if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--SMASH_IC", required = True,
                        help = "SMASH initial conditions.")
    parser.add_argument("--Hydro_Info", required = True,
                        help = "File with the vhlle output from the terminal.")
    parser.add_argument("--Sampler", required = True,
                        help = "Sampled particle lists.")
    parser.add_argument("--SMASH_final_state", required = True,
                        help = "Final state particle lists.")
    parser.add_argument("--SMASH_ana_path", required = True,
                        help = "Path to smash-analysis.")
    parser.add_argument("--output_path", required = True,
                        help = "Path to store results.")
    parser.add_argument("--Nevents", required = True,
                        help = "Number of events in the afterburner/sampler.")
    args = parser.parse_args()

    sys.path.append(args.SMASH_ana_path + '/python_scripts')
    import smash_basic_scripts as sbs

    NB_SMASH_IC, E_SMASH_IC = energy_from_oscar(args.SMASH_IC)
    NB_hydro, E_hydro = energy_from_hydro(args.Hydro_Info)
    NB_sampler_per_Event, E_sampler_per_Event = energy_from_oscar(args.Sampler)
    NB_SMASH_final_state, E_SMASH_final_state = energy_from_binary(args.SMASH_final_state)


    plotting_E_conservation(E_SMASH_IC, E_hydro, E_sampler_per_Event, E_SMASH_final_state)

    print 'Initial SMASH energy: ' + str(E_SMASH_IC)
    print 'Hydro energy through surface: ' + str(E_hydro)
    print 'Sampler energy: ' + str(np.mean(E_sampler_per_Event))
    print 'Final SMASH energy: ' + str(E_SMASH_final_state)
    print 'Energy gain/loss: ' + str(round(100 * ((E_SMASH_final_state / E_SMASH_IC) -1),2) ) + ' %'
    plotting_NB_conservation(NB_SMASH_IC, NB_hydro, NB_sampler_per_Event, NB_SMASH_final_state)
