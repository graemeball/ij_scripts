// Write out tiled "t-series" as numbered stacked tiffs to a selected folder
// - Intended as input for Fiji's Grid/Collection Stitching plugin
// - Runs on active open image
// - Image numbering is 1-based, and the macro handles 1-999 tiles
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2015)
// License: MIT license

folder = getDirectory("Choose a Folder to save tiffs for stitching");
title = getTitle();
basename = substring(title, 0, min(10, lengthOf(title)));
getDimensions(nx, ny, nc, nz, nt);

if (nt > 999) {
	exit(">999 tiles!? You're gonna need a bigger macro...");
}

setBatchMode(true);
if (nz==1 && nc==1) {
	// "Duplicate" just 1 slice for a simple stack
	for (t = 1; t <= nt; t++) {
		setSlice(t);
		run("Duplicate...", " ");
		path = folder + basename + "_" + threeDigit(t) + ".tif";
		saveAs("tiff", path);
		close();
	}
} else {
	// where we have more than 1 Z or channel
	for (t = 1; t <= nt; t++) {
		run("Duplicate...", "duplicate frames=" + t);
		path = folder + basename + "_" + threeDigit(t) + ".tif";
		saveAs("tiff", path);
		close();
	}
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
