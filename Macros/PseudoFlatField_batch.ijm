// Batch pseduo-flat-field correction ImageJ1 Macro
// - uses gaussian blur of 1/4 image height as pseudo-flat-field
// - assumes a single channel!
//
// Usage: you will be prompted for,
//   - an input folder of images to correct
//   - an output folder for the corrected images
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2015)
// License: MIT

// prompt for input and output folders
dInput = getDirectory("Choose a folder containing images to flat-field correct");
dOutput = getDirectory("Choose a folder to save flat-field corrected images");

// hide images and prevent intensity rescaling/autoscaling
setBatchMode(true);
run("Conversions...", " ");

// build input file list
inputs = getFileList(dInput);

// loop over input images, flat-field correct, save in dOutput
for (i = 0; i < inputs.length; i++) {
	input = inputs[i];
	open(dInput + input);
	inTitle = getTitle();
	outputTitle = "" + filenameWithoutExtension(input) + "_FF.tif";
	pseudoFFcorrect();
	save(dOutput + outputTitle);
	close();
	selectWindow(inTitle);
	close();
}
setBatchMode(false);


// -- helper function definitions --

function filenameWithoutExtension(filename) {
    // return filename with last .ext chopped off
    lastDot = lastIndexOf(filename, ".");
    nameWithoutExtension = substring(filename, 0, lastDot);
    return nameWithoutExtension;
}

function pseudoFFcorrect() {
	// pseudo-flat-field correction of active image
	// uses gaussian blur of 1/4 image height as pseudo-flat-field
	inTitle = getTitle();
	run("32-bit");
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=" + (getHeight() / 4));
	getStatistics(area, mean, min, max, std, histogram);
	run("Divide...", "value=" + mean);
	ffTitle = getTitle();
	imageCalculator("Divide create 32-bit", inTitle, ffTitle);
	resultTitle = getTitle();
	selectWindow(ffTitle);
	close();
	selectWindow(resultTitle);
}
