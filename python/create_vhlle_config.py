import numpy as np
import argparse
import os
from hydro_parameters import hydro_params

'''
    This script generates a configuration file for vHLLE based on the 'default'
    file located in configs/AuAu_8.8GeV. For this, the example file is copied
    line by line, where the paths to the SMASH IC input file as well as to the
    output directory are replaced by the correct paths. Furthermore, the initial
    proper time for the hydro evolution is read from the SMASH output and also
    inserted to the vHLLE config file.
'''

# pass arguments from the command line to the script
parser = argparse.ArgumentParser()
parser.add_argument("--vhlle_config", required = True,
                    help="Config file to set up vhlle.")
parser.add_argument("--smash_ic", required = True,
                    help="SMASH_IC output in ASCII format.")
parser.add_argument("--output_file", required = True,
                    help="Updated vhlle config file")
parser.add_argument("--energy", required = False,
                    help="Collision energy")
parser.add_argument("--test", required = False, action='store_true', default = False,
                    help="Collision energy")
args = parser.parse_args()

# Path to the reults directory
basepath = '/'.join(args.smash_ic.split('/')[:-2]) + '/'

# Collision energy
if args.energy in hydro_params.keys():
    energy = args.energy
else:
    for key in hydro_params:
        if float(args.energy) >= float(key): energy = key

# Extract proper time of hypersurface from SMASH output, to pass it to
# vhlle configuration file
with open(args.smash_ic, 'r') as f:
    for i in range(0,4):        # Skip header
        f.readline()
    proper_time = f.readline().split()[0]
f.close()

# Create new vhlle config, that contains the extracted proper time and the
# correct paths to the input and output files.
# The default config file is copied and modified where necessary.
config_updated = open(args.output_file, 'w')

with open(args.vhlle_config, 'r') as f:
    for line in f:
        if line[0] != '\n':
            if line.split()[0] == 'etaS':
                newline = 'etaS      ' + str(hydro_params[energy]['etaS']) + '\n'
            elif line.split()[0] == 'Rg':
                newline = 'Rg      ' + str(hydro_params[energy]['Rg']) + '\n'
            elif line.split()[0] == 'Rgz':
                newline = 'Rgz     ' + str(hydro_params[energy]['Rgz']) + '\n'
            elif line.split()[0] == 'tau0':
                newline = 'tau0       ' + str(proper_time) + '\n'
            elif args.test and line.split()[0] == 'nx':
                newline = 'nx        81\n'
            elif args.test and line.split()[0] == 'ny':
                newline = 'ny        81\n'
            elif args.test and line.split()[0] == 'nz':
                newline = 'nz        151\n'
            else:
                newline = line
            config_updated.write(newline)
        else: continue
f.close()
config_updated.close()
