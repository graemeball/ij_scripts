// ImageJ Macro to auto-scale all channels and display composite if multi-channel
//
// Copyright g.ball@dundee.ac.uk (2019) Dundee Imaging Facility
// License: Creative Commons CC-BY-SA
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
		Stack.setDisplayMode("grayscale");
		run("Enhance Contrast", "saturated=0.35");
	}
	// also show B&C and Channels tools
	run("Brightness/Contrast...");
	run("Channels Tool...");
}
    

