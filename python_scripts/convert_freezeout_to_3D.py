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


# pass arguments from the command line to the script
parser = argparse.ArgumentParser()
parser.add_argument("--freezeout", required=True)
args = parser.parse_args()

PATH_TO_FREEZEOUT = Path(args.freezeout)
DIR_FREEZEOUT = os.path.dirname(args.freezeout)


# The boost follows the convention of line 267 ff of
# https://root.cern.ch/doc/master/TLorentzVector_8cxx_source.html#l00267
def boost(u4, vx, vy, vz):
    t  = u4[0] 
    ux = u4[1]
    uy = u4[2]
    uz = u4[3]
    
    v_2 = vx*vx + vy*vy + vz*vz
    gamma = 1.0/np.sqrt(1.0 - v_2)
    u3v = u4[1]*vx + u4[2]*vy + u4[3]*vz
    gamma_2 = (gamma-1.0)/v_2 if v_2>0 else 0.0
    
    u0_new = gamma*(t+u3v)
    ux_new = ux + gamma_2*u3v*vx + gamma*vx*t
    uy_new = uy + gamma_2*u3v*vy + gamma*vy*t
    uz_new = uz + gamma_2*u3v*vz + gamma*vz*t
    
    return u0_new, ux_new, uy_new, uz_new


if not Path(DIR_FREEZEOUT).exists():
    sys.exit("Fatal Error:  freezeout.dat not found!")

else:
    number_of_eta_slices = 41
    
    # Parameters from the vhlle_config file. n_z must be odd so that 
    # a central cell exists
    n_z_config = 7
    etamin_config = -0.5
    etamax_config = 0.5
    
    # eta range for the 3D file
    etamin = -5.0
    etamax = 5.0
    small_value = 0.0000001
    
    # Construct slice_positions_eta which holds the positions 
    # of every central cell slice in eta centered around 0
    slice_width = (etamax - etamin)/(number_of_eta_slices-1)
    half_eta_length = int((number_of_eta_slices-1)/2)
    slice_positions_eta = np.zeros(number_of_eta_slices)
    
    for i in range(-half_eta_length, half_eta_length+1):
        slice_positions_eta[i+half_eta_length] = i * slice_width
    
    
    # compute the boundary space-time rapidities of the central cell.
    # epsilon is needed to make sure that cells at the boundary are still
    # counted in
    eta_min_central = etamin_config/(2*((n_z_config-1)/2)) - small_value
    eta_max_central = etamax_config/(2*((n_z_config-1)/2)) + small_value
    
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
    central_cell_shape = central_cell.shape
    
    
    # Create number_of_eta_slices copies of the central cell and shift each 
    # copy in eta to span the whole range [etamin, etamax]
    freezeout_slices = np.zeros((number_of_eta_slices, central_cell_shape[0], 
                                central_cell_shape[1]))
    
    freezeout_slices[:] = np.copy(central_cell)
    
    del freezeout
    del central_cell
    del eta_list
    
    for j in range(number_of_eta_slices):
        freezeout_slices[j, :, 3] += slice_positions_eta[j]
      
        cells_in_slice = freezeout_slices[j,:,0].size
        
        # Apply a boost to the four velocity of every cell by the shifted eta
        for k in range(cells_in_slice):
            eta = freezeout_slices[j, k, 3]
            eta_before = eta - slice_positions_eta[j]
            u0 = freezeout_slices[j, k, 8]
            u1 = freezeout_slices[j, k, 9]
            u2 = freezeout_slices[j, k, 10]
            u3 = freezeout_slices[j, k, 11]
            u  = freezeout_slices[j, k, 8:12]
    
            # Following SMASH-hadron-sampler: gen.cpp, lines 314-320
            vx = u1/u0*np.cosh(eta_before)/np.cosh(eta)
            vy = u2/u0*np.cosh(eta_before)/np.cosh(eta)
            vz = np.tanh(eta)
            
            u0_new, u1_new, u2_new, u3_new = boost(u, vx, vy, vz)
            
            freezeout_slices[j, k, 8:12] = np.array([u0_new, u1_new, u2_new, u3_new])
        
        
    # Put the slices in one big array and sort them after tau
    freezeout_slices = freezeout_slices.reshape(
        number_of_eta_slices*central_cell_shape[0], central_cell_shape[1])
    
    freezeout_slices = freezeout_slices[freezeout_slices[:,0].argsort()]
    
    # rename the 2d freezeout.dat so that it is not overwritten
    os.rename(PATH_TO_FREEZEOUT, DIR_FREEZEOUT+"/freezeout_2D.dat" )
    
    np.savetxt(DIR_FREEZEOUT+'/freezeout.dat', freezeout_slices)
