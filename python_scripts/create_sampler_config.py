import numpy as np
import argparse
import os

'''
    This script generates a configuration file for the hadron sampler based on
    the 'default' file located in configs/AuAu_8.8GeV. For this, the example
    file is copied line by line, where the paths to the hydro output and the
    particle lists, that are yet to be produced, are replaced by the correct
    paths.
'''

# pass arguments from the command line to the script
parser = argparse.ArgumentParser()
parser.add_argument("--sampler_config", required = True,
                    help="Base config file to set up the sampler.")
parser.add_argument("--vhlle_config", required = True,
                    help="Config for hydro evolution.")
parser.add_argument("--output_file", required = True,
                    help="Updated vhlle config file")
parser.add_argument("--Nevents", required = True,
                    help="Number of events to sample")
args = parser.parse_args()

# Path to the results directory
basepath = '/'.join(args.vhlle_config.split('/')[:-2]) + '/'

# Extract critical energy density and shear viscosity from hydro config.
with open(args.vhlle_config, 'r') as f:
    for line in f:
        if line.split()[0] == 'etaS': eta_s = line.split()[1]
        elif line.split()[0] == 'e_crit': e_crit = line.split()[1]
        else: continue
f.close()

# Create new vhlle config, that contains the extracted proper time and the
# correct paths to the input and output files.
# The default config file is copied and modified where necessary.
config_updated = open(args.output_file, 'w')

with open(args.sampler_config, 'r') as f:
    for line in f:
        if line[0] != '\n':
            if line.split()[0] == 'surface':
                newline = 'surface          ' + basepath + 'Hydro/freezeout.dat' + '\n'
            elif line.split()[0] == 'spectra_dir':
                newline = 'spectra_dir      ' + basepath + 'Sampler' + '\n'
            elif line.split()[0] == 'number_of_events':
                newline = 'number_of_events ' + str(args.Nevents) + '\n'
            elif line.split()[0] == 'shear':
                if float(eta_s) == 0.0:
                    # Bool: Do not take shear corrections into consideration
                    newline = 'shear            ' + '0' + '\n'
                else:
                    # Bool: Take shear corrections into consideration
                    newline = 'shear            ' + '1' + '\n'

            elif line.split()[0] == 'ecrit':
                newline = 'ecrit            ' + e_crit + '\n'
            else:
                newline = line
            config_updated.write(newline)
        else: continue
f.close()
config_updated.close()
