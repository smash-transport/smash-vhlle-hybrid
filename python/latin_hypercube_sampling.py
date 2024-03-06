#!/usr/bin/env python3
import argparse
import numpy as np
import ast
from pyDOE import lhs

#scale the hypercube to the specified ranges
def generate_points_from_ranges(ranges, probabilities):
    points = []
    for i in range(len(probabilities)):
        sample = []
        for j in range(len(probabilities[i])):
            range_min, range_max = ranges[j]
            probability = probabilities[i][j]
            value = range_min + (range_max - range_min) * probability
            sample.append(value)
        points.append(sample)
    return np.array(points)

if __name__ == '__main__':
    # pass arguments from the command line to the script
    parser = argparse.ArgumentParser()
    parser.add_argument("--parameter_ranges", required = True,
                        help="Ranges of the parameters to be sampled.")
    parser.add_argument("--num_samples", required = True,
                        help="Number of samples to be drawn.")
    args = parser.parse_args()

    list_of_strings = args.parameter_ranges.split('] [')
    list_of_strings[0] = list_of_strings[0] + ']'
    list_of_strings[-1] = '[' + list_of_strings[-1]

    for i in range(1, len(list_of_strings) - 1):
        list_of_strings[i] = '[' + list_of_strings[i] + ']'

    # parse each string into a list
    list_of_lists = [ast.literal_eval(sublist) for sublist in list_of_strings]

    # convert the list of lists into a numpy array
    arr = np.array(list_of_lists)
    unit = lhs(arr.shape[0], samples=int(args.num_samples), criterion='maximin')
    result= generate_points_from_ranges(arr, unit)
    return_string=""
    for row in result:
        for elem in row:
            return_string += str(elem) + " "
        return_string += "\n"
    print(return_string)

