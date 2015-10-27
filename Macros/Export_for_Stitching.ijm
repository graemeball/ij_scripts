// Write out tiled "t-series" as numbered stacked tiffs to a selected folder
// -- intended as input for Fiji's Grid/Collection Stitching plugin.
// Image numbering is 1-based, and the macro handles 1-999 tiles. 
//
// Copyright: graemeball@gmail.com, Dundee Imaging Facility (2015)
// License: Creative Commons CC-BY


folder = getDirectory("Choose a Folder to save tiffs for stitching");
title = getTitle();
basename = substring(title, 0, min(10, lengthOf(title)));
getDimensions(nx, ny, nc, nz, nt);

if (nt > 999) {
	exit(">999 tiles!? You're gonna need a bigger macro...");
}

setBatchMode(true);
for (t = 1; t <= nt; t++) {
	run("Duplicate...", "duplicate frames=" + t);
	path = folder + basename + "_" + threeDigit(t) + ".tif";
	saveAs("tiff", path);
	close();
}
setBatchMode(false);


// -- helper functions --

function threeDigit(n) {
	// for a number from 0-999, return a 3-digit string: 000, 001, ..., 011, ..., 999
	// where n is greater than 999, return "XXX" (macro should abort for n>999)
	if (n > 999) {
		return "XXX";
	} else if (n > 99) {
		return "" + n;
	} else if (n > 9) {
		return "0" + n;
	} else {
		return "00" + n;
	}
}

function min(a, b) {
	// return minimum of 2 numbers, a and b
	if (a < b) {
		return a;
	} else {
		return b;
	}
}
