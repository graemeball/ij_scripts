// apply_gamma.ijm - macro to apply gamma correction to current slice
//  N.B. converts image to 32-bit
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2022)
// License: MIT
//

gamma = getNumber("gamma", 1);
if (gamma < 0) {
	exit("gamma cannot be negative!");
}

if (bitDepth() != 32) {
	run("32-bit");
}

getDimensions(width, height, nc, nz, nt);
for (y = 0; y < height; y++) {
	for (x = 0; x < width; x++) {
		value = getPixel(x, y);
		setPixel(x, y, pow(value, gamma));
	}
}
