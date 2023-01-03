#!/usr/bin/env python3

"""
gnisfixer.py

This python3 program "fixes" USGS GNIS NationalFile download.  GNIS is supposed to have unique ids.  However,
the file contains points with matching names for features in both the US and Canada that have the exact same
identifier as the point in the US.  This program loops through the CSV-format file and only outputs each line if
it contains a state that is actually in the US.

This depends on the Python us library that can be installed with pip3 install us.
"""

import us
import csv
import sys


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: {} inputgnisfile outputfile".format(sys.argv[0]))
        exit(-1)

    input_file  = sys.argv[1]
    output_file = sys.argv[2]

    try:
        infile = open(input_file, 'r')
        outfile = open(output_file, 'w')

        csvinfile = csv.DictReader(open(input_file, 'r'), delimiter='|')
        csvoutfile = csv.DictWriter(open(output_file, 'w'), delimiter='|', fieldnames = csvinfile.fieldnames)
        csvoutfile.writeheader()

        for inrow in csvinfile:
            try:
                if not us.states.lookup(inrow['STATE_ALPHA']):
                    continue
            except Exception as e:
                continue
            else:
                csvoutfile.writerow(inrow)

        print("Finished processing GNIS.")

    except Exception as e:
        print("An exception occurred during processing.")
        print("Exception was: {}".format(e))
        exit(-1)

