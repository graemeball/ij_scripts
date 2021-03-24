// Select_One_Z_per_T.ijm: macro to reduce a hyperstack to one chosen Z per time
// Usage: (runs on active image)
//   user must specify a comma-separated list of Z slices (no spaces)
// Author: graemeball@googlemail.com, Dundee Imaging Facility (2015)
// License: MIT license
// 

getDimensions(w,h,nc,nz,nt);
inputID = getImageID();

// get user choice of Z slices, default slice Z=1 for all t
defaultZlist = "";
for (i=1; i<nt; i++) {
	defaultZlist = defaultZlist + "1,";
}
defaultZlist = defaultZlist + "1";
nCols = lengthOf(defaultZlist);
Dialog.create("Select one Z per t");
Dialog.addString("comma-separated Z slices", defaultZlist, nCols);
Dialog.show();
chosenZlist = Dialog.getString();

zArray = parseIntegersIntoArray(chosenZlist, nt);

// create new hyperstack with one Z per t
setBatchMode(true);
run("Duplicate...", " ");
outputID = getImageID();
nOutputSlices = nc*nt;
for (t = 1; t <= nt; t++) {
	for (c = 1; c <= nc; c++) {
		selectImage(inputID);
		Stack.setPosition(c, zArray[t - 1], t);
		run("Select All");
		run("Copy");
		selectImage(outputID);
		run("Paste");
		run("Add Slice");
	}
}
run("Delete Slice");
run("Stack to Hyperstack...", "order=xyczt(default) channels=" + nc + " slices=1 frames=" + nt + " display=Composite");
setBatchMode(false);


// -- helper functions --

function parseIntegersIntoArray(csvString, nt) {
	// return array of integers parsed from a string of comma separated values
	zArray = newArray(nt);  // we expect 1 Z-slice specified per time
	t = 1;  // time point
	do {
		nextComma = indexOf(csvString, ",");
		if (nextComma > -1) {
			nextIntString = substring(csvString, 0, nextComma);
			csvString = substring(csvString, nextComma+1);  // pop
		} else {
			nextIntString = csvString;
			csvString = "";  // all gone
		}
		nextInt = parseInt(nextIntString);
		if (isNaN(nextInt)) {
			exit("Error, " + nextIntString + " is not an integer!");
		} else {
			if (t <= zArray.length) {
				zArray[t - 1] = nextInt;
			}  // else ... out-of-bounds, so just forget it
			t++;
		}
	} while (lengthOf(csvString) > 0);
	if (t != nt + 1) {
		exit("Error, expected " + nt + " Z slices but you entered " + (t - 1));
	}
	return zArray;
}
