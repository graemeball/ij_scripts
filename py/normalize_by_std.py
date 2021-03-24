# Normalize the intensity of each slice such that stdDev is constant over t
# - normalize t-series for each channel and z-slice separately
# - convert to 32-bit float for processing
#
# Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2018)
# License: MIT license
#

from ij import IJ
from ij import WindowManager

imp = WindowManager.getCurrentImage()
[w, h, nc, nz, nt] = imp.getDimensions()

IJ.run("32-bit");  # to avoid rounding errors during intensity rescaling

for c in range(nc):
    for z in range(nz):
        stdev0 = 1;
        for t in range(nt):
            imp.setPosition(c, z, t)
            ip = imp.getProcessor()
            stats = ip.getStats()
            stdev = stats.stdDev
            if t == 0:
                stdev0 = stdev
            scaleFactor = stdev0 / stdev;
            IJ.run("Multiply...", "value=" + str(scaleFactor) + " slice")
