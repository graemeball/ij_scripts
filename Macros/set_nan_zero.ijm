// set_nan_zero.ijm - macro to set nan pixels in current slice to zero
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2022)
// License: MIT
//


getDimensions(width, height, nc, nz, nt);
for (y = 0; y < height; y++) {
	for (x = 0; x < width; x++) {
		value = getPixel(x, y);
		if (isNaN(value)) {
			setPixel(x, y, 0);
		} else {
			setPixel(x, y, value);
		}
	}
}
