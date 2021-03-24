// ImageJ macro to show intensity stats for each slice in a stack
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2018)
// License: MIT license
//

Stack.getDimensions(w, h, nc, nz, nt);

run("Clear Results");
row = 0;
for (c = 1; c <= nc; c++) {
	for (t = 1; t <= nt; t++) {
		for (z = 1; z <= nz; z++) {
			Stack.setPosition(c, z, t);
			getStatistics(area, mean, min, max, std, hist);
			setResult("Channel", row, c);
			setResult("tFrame", row, t);
			setResult("zSlice", row, z);
			setResult("Area", row, area);
			setResult("Mean", row, mean);
			setResult("Min", row, min);
			setResult("Max", row, max);	
			setResult("Std", row, std);
			row++;
		}
	}
}
