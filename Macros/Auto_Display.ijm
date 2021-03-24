// ImageJ Macro to auto-scale all channels and display composite if multi-channel
//
// Author: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2019)
// License: Public Domain (Creative Commons CC0)
//

macro "Auto Display [A]" {
	// macro to auto-scale all channels and display composite if multi-channel
	getDimensions(w, h, nc, nz, nt);
	if (nc > 1) {
		Stack.setDisplayMode("composite");
		for (c = 1; c <= nc; c++) {
			Stack.setChannel(c);
			run("Enhance Contrast", "saturated=0.35");
		}
		Stack.setChannel(1);
	} else {
		run("Grays");
		run("Enhance Contrast", "saturated=0.35");
	}
	// also show B&C and Channels tools
	run("Brightness/Contrast...");
	run("Channels Tool...");
}

