import numpy as np
import matplotlib.pyplot as plt
import re

'''
    This script reads in the freezeout hypersurface created by CORNELIUS within
    vHLLE and reformats it such that:
    - No trailing whitespaces at the beginning of the line
    - Different line entries are separated by only whitespace
    - Hypersurface patches with vanishing energy density or temperature are
      removed. Those patches usually originate from the boundaries of the EoS,
      where the baryon density may become unphysically large for certain regions
      of the energy density. Since those patches are seemingly unphysical, they
      can be ignored.

    The reformatted file can be applied within Sangwook's Cooper-Frye sampler
    for particlization.
'''

hypersurface_contributions = open('freezeout_contributions_only.dat', 'w')

with open("freezeout.dat", 'r') as f:
    for line in f:
        line = re.sub(' +', ' ',line) # remove whitespaces between entries
        newline = line[1:]
        line = line.split()

        if ((float(line[13]) > 0.0) and (float(line[12]) > 0.0)):
            # if non-zero energy-density and temperature, print to hypersurface
            # file that contains only non-zero contributions
            hypersurface_contributions.write(newline)

hypersurface_contributions.close()
