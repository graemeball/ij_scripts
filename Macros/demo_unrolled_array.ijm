// Answer to question by Matt Pearson on ImageJ list (5-Oct-2016)
// Q: Creating "n" arrays in a loop
//
// Demonstrates using an unrolled/flat array instead of array of arrays
// "version 2"!
//
// Author: Graeme Ball (graemeball@gmail.com) 2016
// License: Public Domain (CC0)
//


nChannels = 3;  // this could be any number of channels
nMeasures = 4;  // this could be any number of measurements
nRows = 2;  // i.e. 1 row for each of the selections I create below


run("Fluorescent Cells (400K)");
roiManager("reset");
run("Clear Results");

makeRectangle(0, 0, 128, 128);
roiManager("add");
makeRectangle(256, 16, 128, 128);
roiManager("add");

flatArray = newArray(nChannels * nMeasures * nRows);
i = 0;  // index for flatArray
for (c = 1; c <= nChannels; c++) {
	// note that channels count from 1, but elsewhere I use 0-based indices!
	for (r = 0; r < nRows; r++) {
		roiManager("select", r);
		Stack.setChannel(c);  // N.B. selecting ROI changes channel, so setChannel 2nd
		getStatistics(area, mean, min, max);
		// N.B. 'i' is incremented just after use via ++ 
		flatArray[i++] = area;
		flatArray[i++] = mean;
		flatArray[i++] = min;
		flatArray[i++] = max;
		// in filling flatArray we increment 'measure', then 'row', then channel
	}
}

// now populate the Results table row by row
for (r = 0; r < nRows; r++) {
	for (c = 1; c <= nChannels; c++) {
		for (m = 0; m < nMeasures; m++) {
			column = "C" + c + "Measure" + (m+1);
			// calculating the correct index into the flat array is the tricky bit!
			value = flatArray[m + r*nMeasures + (c-1)*nRows*nMeasures];
			setResult(column, r, value);
		}
	}
}

