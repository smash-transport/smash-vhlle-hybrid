#!/usr/bin/python
import numpy as np
import matplotlib
matplotlib.use('Agg')
from matplotlib import cm
import matplotlib.pyplot as plt
import argparse
import linecache
import seaborn as sns
import collections


'''
   This scripts combines the hydrodynamical start and end times for all
   collision energies.
'''

matplotlib.rcParams['axes.labelsize'] = 15
matplotlib.rcParams['legend.fontsize'] = 11


start_times = {'4.3' : 6.18676,
               '6.4' : 4.08994,
               '7.7' : 3.20539,
               '8.8' : 2.91076,
               '17.3' : 1.45516,
               '27.0' : 0.888732,
               '39.0' : 0.6145,
               '62.4' : 0.5,
               '130.0' : 0.5,
               '200.0' : 0.5
               }

def collect_data(files):
    data_collection = {'energies' : [],
                       'starttimes' : [],
                       'endtimes' : [],
                       'lifetimes' : [],
                       'errors' : []}

    for file in files:
        energy = file.split('/')[-3].split('_')[1]
        with open(file) as f:
            f.readline()    # skip header
            data = f.readline().split()
            endtime = float(data[0])
            starttime = start_times[energy]
            lifetime = endtime - start_times[energy]
            data_collection['energies'].append(float(energy))
            data_collection['starttimes'].append(starttime)
            data_collection['endtimes'].append(data[0])
            data_collection['lifetimes'].append(lifetime)
            data_collection['errors'].append(data[1])

    sqrts = np.array(data_collection['energies'], dtype = 'float')
    inds = sqrts.argsort()

    return {'energies' : np.array(data_collection['energies'])[inds],
            'starttimes' : np.array(data_collection['starttimes'])[inds],
            'endtimes' : np.array(data_collection['endtimes'])[inds],
            'lifetimes' : np.array(data_collection['lifetimes'])[inds],
            'errors' : np.array(data_collection['errors'])[inds]
            }

    return data_collection


def write_data(data, filename):
    with open(args.output_dir + filename, 'w') as f:
        f.write('# energy starttime endtime time_difference error \n')
        for i in range(0, len(data['energies'])):
            f.write(str(data['energies'][i]) + '\t' +
                    str(data['starttimes'][i]) + '\t' + str(data['endtimes'][i]) + '\t' +
                    str(data['lifetimes'][i]) + '\t' + str(data['errors'][i]) + '\n')
    f.close()


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument("--endtime_files", nargs = '+', required = False,
                        help = "Files containing the analyzed integrated vn.")
    parser.add_argument("--output_dir", required = True,
                        help = "Where to store the avareged results.")
    args = parser.parse_args()

    data = collect_data(args.endtime_files)
    write_data(data, 'hydro_lifetime.txt')
