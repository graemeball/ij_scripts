// Create Difference-of-Gaussian filtered version of active image
// (for single slice 2D image)
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2020)
// License: MIT license
//


// parameters / defaults
g1 = 2;
multipl = 3;

// check input
inputID = getImageID();
if (nSlices > 1) {
	exit("Test_DoG.ijm expects a single slice 2D image");
}

// dialog to adjust parameters
Dialog.create("Test DoG filter");
getPixelSize(unit, pw, ph);
Dialog.addNumber("Base size (" + unit + ")", g1);
Dialog.addNumber("Multiplyer", multipl);
Dialog.show();
g1 = Dialog.getNumber();
multiple = Dialog.getNumber();

// filter
outputID = dogFilter(inputID, g1, multipl);
selectImage(outputID);


// --- function definitions ---
function dogFilter(imageID, scale, multiplier) {
	// return imageID of new, DoG-filtered image; scale in calibrated units
	selectImage(imageID);
	outputTitle = "DoG" + scale + "x" + multiplier + "_" + getTitle();
	run("Select None");
	run("Duplicate...", " ");
	run("32-bit");
	baseImageID = getImageID;
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=" + scale + " scaled");
	rename("dogTemp1");
	selectImage(baseImageID);
	scale2 = scale * multiplier;
	run("Gaussian Blur...", "sigma=" + scale2 + " scaled");
	rename("dogTemp2");
	imageCalculator("Subtract create 32-bit", "dogTemp1","dogTemp2");
	outputImageID = getImageID;
	rename(outputTitle);
	selectWindow("dogTemp1");
	close();
	selectWindow("dogTemp2");
	close();
	return outputImageID;
}
