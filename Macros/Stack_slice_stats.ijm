// ImageJ macro to show intensity stats for each slice in a stack
//  and finally, print stack intensity stats to log window
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2018-21)
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
print("# Stack_slice_stats.ijm - stack intensity stats...");
for (c = 1; c <= nc; c++) {
	Stack.getStatistics(voxelCount, mean, min, max, stdDev);
	stackStats = ": Mean=" + mean;
	stackStats = stackStats + ", Min=" + min;
	stackStats = stackStats + ", Max=" + max;
	stackStats = stackStats + ", Std=" + stdDev;
	print("Channel" + c + stackStats);
}

