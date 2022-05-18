// bitplanes_8bit.ijm - macro to separate 8-bit image into bitplane images
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2022)
// License: MIT
//


// check input
inputID = getImageID();
if (nSlices > 1) {
	exit("bitplanes_8bit requires a single slice 2D image");
}
if (bitDepth() != 8) {
	exit("bitplanes_8bit requires an 8-bit image");
}

// get linearised array of all pixels and separate into bit-planes
getDimensions(width, height, nc, nz, nt);
pix = getPixels(width, height);
nPix = pix.length;
bp128 = newArray(nPix);
bp64 = newArray(nPix);
bp32 = newArray(nPix);
bp16 = newArray(nPix);
bp8 = newArray(nPix);
bp4 = newArray(nPix);
bp2 = newArray(nPix);
bp1 = newArray(nPix);
for (i = 0; i < pix.length; i++) {
	if (pix[i] > 127) {
		bp128[i] = 1;
		pix[i] = pix[i] - 128;
	}
	if (pix[i] > 63) {
		bp64[i] = 1;
		pix[i] = pix[i] - 64;
	}
	if (pix[i] > 31) {
		bp32[i] = 1;
		pix[i] = pix[i] - 32;
	}
	if (pix[i] > 15) {
		bp16[i] = 1;
		pix[i] = pix[i] - 16;
	}
	if (pix[i] > 7) {
		bp8[i] = 1;
		pix[i] = pix[i] - 8;
	}
	if (pix[i] > 3) {
		bp4[i] = 1;
		pix[i] = pix[i] - 4;
	}
	if (pix[i] > 1) {
		bp2[i] = 1;
		pix[i] = pix[i] - 2;
	}
	bp1[i] = pix[i];
}

newImage("bp128", "8-bit", width, height, 1);
setPixels(bp128, width, height);
run("Enhance Contrast", "saturated=0.35");

newImage("bp64", "8-bit", width, height, 1);
setPixels(bp64, width, height);
run("Enhance Contrast", "saturated=0.35");

newImage("bp32", "8-bit", width, height, 1);
setPixels(bp32, width, height);
run("Enhance Contrast", "saturated=0.35");

newImage("bp16", "8-bit", width, height, 1);
setPixels(bp16, width, height);
run("Enhance Contrast", "saturated=0.35");

newImage("bp8", "8-bit", width, height, 1);
setPixels(bp8, width, height);
run("Enhance Contrast", "saturated=0.35");

newImage("bp4", "8-bit", width, height, 1);
setPixels(bp4, width, height);
run("Enhance Contrast", "saturated=0.35");

newImage("bp2", "8-bit", width, height, 1);
setPixels(bp2, width, height);
run("Enhance Contrast", "saturated=0.35");

newImage("bp1", "8-bit", width, height, 1);
setPixels(bp1, width, height);
run("Enhance Contrast", "saturated=0.35");


// --- function definitions ---

function getPixels(width, height) {
	// return 1D array of all pixel intensities for current 2D image (column-first, i.e. x then y)
	I = newArray(width * height);
	i = 0;
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			I[i] = getPixel(x, y);
			i++;
		}
	}
	return I;
}

function setPixels(I, width, height) {
	// set pixel intensities of current 2D image using 1D array of all pixel intensities (column-first, i.e. x then y)
	i = 0;
	for (y = 0; y < height; y++) {
		for (x = 0; x < width; x++) {
			setPixel(x, y, I[i]);
			i++;
		}
	}
}

