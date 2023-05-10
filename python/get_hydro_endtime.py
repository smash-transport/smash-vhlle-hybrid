#!/usr/bin/python
import numpy as np
import argparse
import sys

def Endtime_from_hydro(file):
    with open(file) as f:
        for index, line in enumerate(f.readlines()):
            if index <= 42: continue
            if line.endswith('nan\n') and line.split()[-3] == '0':
                lastline = line

    endtime = lastline.split()[0]

    return endtime

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--Hydro_Info", required = True,
                        help = "File with the vhlle output from the terminal.")
    parser.add_argument("--output_path", required = True,
                        help = "Path to store results.")
    args = parser.parse_args()


    endtime = Endtime_from_hydro(args.Hydro_Info)

    with open(args.output_path + '/Hydro_Endtime.txt', 'w') as f:
        f.write('# endtime \n')
        f.write(endtime + '\n')
    f.close()
