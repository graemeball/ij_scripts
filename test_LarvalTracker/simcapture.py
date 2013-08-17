#!/usr/bin/env python

"""
Simple test script for simulating live camera capture by copying files
from a source to a destination directory one file at a time, separated
by a given time interval.
"""

import os
import shutil
import time

# setup parameters
src_dir = './test_images'
dest_dir = './live_capture'
interval = 2

# blank the destination directory and count source files
shutil.rmtree(dest_dir)
os.makedirs(dest_dir)
dest_files = 0
src_files = len(os.listdir(src_dir))
print(str(len(os.listdir(src_dir))) + ' files in ' + src_dir)

# simulate "capture" by copying with time interval delay
print('\nSimulating live capture ... Ctrl-C to abort')
for src_file in os.listdir(src_dir):
    dest_files += 1
    src_path = os.path.join(src_dir, src_file)
    dest_path = os.path.join(dest_dir, src_file)
    shutil.copy2(src_path, dest_path)
    print('"captured" ' + str(dest_files) + ' files')
    time.sleep(interval)
