#!/usr/bin/env python3
import argparse
import numpy as np
import ast
from pyDOE import lhs

#scale the hypercube to the specified ranges
def generate_points_from_ranges(ranges, unit_points):
    points = []
    for i in range(len(unit_points)):
        sample = []
        for j in range(len(unit_points[i])):
            range_min, range_max = ranges[j]
            unit_point = unit_points[i][j]
            value = range_min + (range_max - range_min) * unit_point
            sample.append(value)
        points.append(sample)
    return np.array(points)

if __name__ == '__main__':
    # pass arguments from the command line to the script
    parser = argparse.ArgumentParser()
    parser.add_argument("--parameter_names", required = True, nargs='+',
                        help="Names of the parameters to be sampled.")
    parser.add_argument("--parameter_ranges", required = True, nargs='+',
                        help="Ranges of the parameters to be sampled.")
    parser.add_argument("--num_samples", required = True, 
                        help="Number of samples to be drawn.")
    args = parser.parse_args()
    parameter_names = args.parameter_names
    parameter_ranges = args.parameter_ranges
    if len(parameter_names) != len(parameter_ranges) or int(args.num_samples) < 2:
        raise ValueError("The number of parameter names and parameter ranges must match and"
                          +"number of samples must be greater 0")
    parameter_ranges = np.array([ast.literal_eval(i) for i in parameter_ranges])
    unit = lhs(parameter_ranges.shape[0], samples=int(args.num_samples), criterion='centermaximin')
    result=generate_points_from_ranges(parameter_ranges, unit).transpose()
    return_string=""
    for i in range(len(parameter_names)):
        return_string += parameter_names[i] + "=["
        for j in range(result.shape[1]):
            return_string += str(result[i][j]) 
            if j != result.shape[1]-1:
                return_string += ","
            else:
                return_string += "]\n"
            
    print(return_string, end='')
