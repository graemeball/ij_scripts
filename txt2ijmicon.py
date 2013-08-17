#!/usr/bin/env python

"""
Convert a 16x16 8-bit grayscale text image exported from ImageJ 
into an ImageJ macro icon text string.
"""

import sys
import fileinput

if len(sys.argv) < 2:
    print("Usage: txt2ijmicon.py textimage.txt")
    sys.exit()

txtfile = sys.argv[1]


########################
# Function definitions #
########################

def dec2hex(dec):
    """
    Take a string representation of a decimal number from 0 to 15
    and return a hex representation (lowercase, not escaped).
    e.g. dec2hex('12') returns 'c'
    """
    d2h_dict = {'0':'0', '1':'1', '2':'2', '3':'3', '4':'4', '5':'5',\
                '6':'6', '7':'7', '8':'8', '9':'9', '10':'a', '11':'b',\
                '12':'c', '13':'d', '14':'e', '15':'f'}
    return d2h_dict[dec]



#########################
# Main body starts here #
#########################

ij_icon = ''  # this will be a long string representing the image
# NB. IJ macro icon X,Y position and colors count 0->f
line_no = 0  # i.e. the y-coord
for line in fileinput.input(txtfile):
    if not line:
        break
    values = line.split()
    value_no = 0  # i.e. the x-coord
    for value in values:
        # point color (black/white, convert 8-bit to 0->f)
        ij_icon += 'C' + dec2hex(str(int(float(value)/16)))*3
        # point position
        ij_icon += 'D' + dec2hex(str(value_no)) + dec2hex(str(line_no))
        value_no += 1
    line_no += 1

# now print that sucker to stdout
print(ij_icon)

