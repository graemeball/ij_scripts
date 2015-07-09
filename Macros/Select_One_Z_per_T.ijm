// Spot_Noise_Demo.ijm: macro to reduce a hyperstack to one chosen Z per time
// Usage: 
//   user must specify a comma-separated list of Z slices (no spaces)
// Author: graemeball@googlemail.com, Dundee Imaging Facility (2015)
// License: Public Domain (CC0)
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

zArray = parseIntegersIntoArray(chosenZlist);

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
function parseIntegersIntoArray(csvString) {
	// return array of integers parsed from a string of comma separated values
	if (lengthOf(csvString) != 2*nt - 1) {
		exit("Error, you did not enter one Z per time!");
	}
	zArray = newArray(nt);
	t = 1;
	while(lengthOf(csvString) > 2) {
		zArray[t - 1] = parseInt(substring(csvString, 0, 1));
		csvString = substring(csvString, 2);
		t++;
	}
	zArray[t - 1] = parseInt(csvString);
	return zArray;
}
