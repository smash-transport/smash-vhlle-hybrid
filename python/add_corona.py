#!/usr/bin/python3

import numpy as np
import os
import sys
import argparse

def read_corona_file(file_path):
    # Open the file and read lines
    #with open(file_path, 'r') as file:
    #    lines = file.readlines()
    
    # Convert each line into a list of floats, excluding lines that start with '#'
    # array = np.array([list(map(float, line.strip().split())) for line in lines if not line.strip().startswith('#')])
    #array = np.array([list(line.strip().split()) for line in lines if not line.strip().startswith('#')])
    with open(file_path, 'r') as f:
        lines = [line.strip().split() for line in f if not line.startswith('#')]
        #print(lines)
    array = np.atleast_2d(np.array(lines, dtype=str)) if len(lines) != 0 else []
    #print(array)
    return array

def initialize_final_file(file_path):
    header_string = "#!OSCAR2013 particle_lists t x y z mass p0 px py pz pdg ID charge \n\
# Units: fm fm fm fm GeV GeV GeV GeV GeV none none e \n\
# SMASH-3.2 \n"
    
    with open(file_path, 'w') as f:
        f.write(header_string)

def read_Sampler_file(file_path, file_path_new, array_to_append):
    # Open the file and read lines
    lines_buffer = np.empty((0, 12), dtype=str)
    event_no = 0
    with open(file_path, 'r') as file:
        for line in file:
            if '#!OSCAR2013' in line or 'Units:' in line or 'SMASH-3.2' in line:
                continue
            if 'end' in line:
                # Convert the accumulated lines to a NumPy array when 'end' is encountered
                one_event_array = lines_buffer
                #print(f"NumPy Array up until 'end': {one_event_array}")
            
                # Join IC and Sampler
                first_event_line = "# event {} out \n".format(event_no)
                final_event_line = "# event {} end \n".format(event_no)
                
                with open(file_path_new, 'a') as f:
                    f.write(first_event_line)

                #array = np.array(lines_buffer)
                array = lines_buffer
                with open(file_path_new, 'a') as f:
                    np.savetxt(f, array, delimiter=' ', fmt='%s')
                with open(file_path_new, 'a') as f:
                    np.savetxt(f, array_to_append, delimiter=' ', fmt='%s')
                
                with open(file_path_new, 'a') as f:
                    f.write(final_event_line)


                # Reset the buffer for the next set of lines
                #lines_buffer = []
                lines_buffer = np.empty((0, 12), dtype=str)

                # Increase event number
                event_no += 1
            else:
                # Add the line to the buffer if it's not 'end'
                #lines_buffer = [line.strip().split() for line in lines if not line.startswith('#')]
                if not line.strip().startswith('#'):
                    #np.append(lines_buffer, line.strip().split())  # strip() to remove trailing newline/whitespace
                    line_array = np.array(line.split())
                    #print(line_array)
                    lines_buffer = np.vstack([lines_buffer, line_array])


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", "--sampled_particle_list", help = "File with sampled particles.")
    parser.add_argument("-c", "--corona_particle_lists", nargs='+', help = "Files to be added.")
    parser.add_argument("-o", "--output_file", help = "File path for output.")
    parser.add_argument("-f", "--force", action='store_true', help = "Ignore pre-existing output file")
    args = parser.parse_args()

    output = args.output_file
    if os.path.isfile(output):
        print(output+" already exists!", file=sys.stderr)
        if not args.force:
            sys.exit(10)

    is_any_corona_file_present = False
    corona = []
    for i_file,corona_file in enumerate(args.corona_particle_lists):
        if not os.path.isfile(corona_file):
            print(corona_file+" not present!")
            continue
        is_any_corona_file_present = True
        if len(corona) == 0:
            file_read = read_corona_file(corona_file)
            if len(file_read) != 0:
               corona = file_read[:,:12]
        else:
            corona = np.r_[corona,read_corona_file(corona_file)[:,:12]]
    if len(corona) == 0:
        print("no corona particles! Making symlink")
        sys.exit(9)

    initialize_final_file(output)
    read_Sampler_file(args.sampled_particle_list, output, corona)