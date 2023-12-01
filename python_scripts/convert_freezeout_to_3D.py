#!/usr/bin/env python3
# -*- coding: utf-8 -*-

'''
This file needs to be called via command line like
python3 freezeout_2d_to_3d.py "--freezeout [Path to freezeout.dat as string]"

'''

import argparse
from pathlib import Path
import sys
import numpy as np
import os


def get_nz_etamin_etamax_from_vhlle_config():
    PATH_VHLLE_CONFIG = '../configs/vhlle_hydro'
    fname = open(PATH_VHLLE_CONFIG, 'r')
    vhlle_config = fname.read().split('\n')

    nz = None
    etamin = None
    etamax = None

    for line_in_config in vhlle_config:
        line_without_spaces = [x for x in line_in_config.split(' ') if x != '']
        
        if line_without_spaces:
            if line_without_spaces[0] == 'nz':
                nz = int(line_without_spaces[1])
            elif line_without_spaces[0] == 'etamin':
                etamin = float(line_without_spaces[1])
            elif line_without_spaces[0] == 'etamax':
                etamax = float(line_without_spaces[1])
            else:
                continue
        else:
            continue
                
    if not nz or not etamin or not etamax:
        raise ValueError('Unable to find values for nz, etamin and etamax in vhlle_hydro')
                
    fname.close()
    
    return nz, etamin, etamax


# pass arguments from the command line to the script
parser = argparse.ArgumentParser()
parser.add_argument("--freezeout", required=True)
args = parser.parse_args()

PATH_TO_FREEZEOUT = Path(args.freezeout)
DIR_FREEZEOUT = os.path.dirname(args.freezeout)


if not Path(DIR_FREEZEOUT).exists():
    sys.exit("Fatal Error:  freezeout.dat not found!")

else:
    
    # Parameters from the vhlle_config file. n_z must be odd so that 
    # a central cell exists
    nz, etamin, etamax = get_nz_etamin_etamax_from_vhlle_config()
    small_value = 0.000001
    
    
    # compute the boundary space-time rapidities of the central cell.
    # epsilon is needed to make sure that cells at the boundary are still
    # counted in
    eta_min_central = etamin/(nz-1) - small_value
    eta_max_central = etamax/(nz-1) + small_value
    
    freezeout=np.loadtxt(PATH_TO_FREEZEOUT, dtype=float)
    
    # vHLLE has optional outputs. Here, it is checked how many output
    # quantities one line of the freezeout.dat has
    number_of_output_quantities=int(freezeout[0].size)
    
    # Here, the number of hypersurface cells (equivalent to the number of lines
    # in the freezeout.dat) is computed
    number_of_elements = int(freezeout.size/number_of_output_quantities)

    # keep only the central cell elements which are within the rapidity range
    # defined by eta_min and eta_max
    eta_list=freezeout[:,3]
    central_cell = freezeout[np.where((eta_list >= eta_min_central) & 
                                      (eta_list <= eta_max_central))]

    del freezeout
    del eta_list
    
    
    # rename the 2d freezeout.dat so that it is not overwritten
    os.rename(PATH_TO_FREEZEOUT, DIR_FREEZEOUT+"/freezeout_2D.dat" )
    
    np.savetxt(DIR_FREEZEOUT+'/freezeout.dat', central_cell)
