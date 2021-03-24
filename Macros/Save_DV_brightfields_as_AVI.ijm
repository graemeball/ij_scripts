// Macro to enhance brightfield .dv movies and save as uncompressed .avi
// Corrects illumination flicker and enhances display contrast
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), 2017
// License: GNU GPL
//

dir = getDirectory("Choose folder containing .dv movies");
files = getFileList(dir)

run("Bio-Formats Macro Extensions");
// -- start macro (batch mode) ---
setBatchMode(true);
// create arrays of PRJ and  REF filenames
for (f = 0; f < files.length; f++) {
	thisFile = files[f];
	if (matches(thisFile, ".*.dv")) {
		basename = substring(thisFile, 0, lastIndexOf(thisFile, ".dv"));
		run("Bio-Formats Windowless Importer", "open=" + dir + File.separator + thisFile);
		run("Bleach Correction", "correction=[Simple Ratio] background=0");
		run("Z Project...", "projection=[Max Intensity]");
		getStatistics(area, mean, min, max);
		close();  // close max-projected
		setMinAndMax(floor(min/2), max);  // series
		rate = 1.0 / Stack.getFrameInterval();
		output = dir + basename + ".avi";
		run("AVI... ", "compression=None frame=" + rate + " save=" + output);
		//print("saveAs " + output + ", rate=" + rate);
		//waitForUser;
		close();  // bleach-corrected
		close();  // original
	}
}
