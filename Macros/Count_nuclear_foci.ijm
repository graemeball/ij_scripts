// ImageJ Macro for batch analysis of focus count per nucleus
// with a folder of multi-channel images
//
// Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility
// License Creative Commons CC-BY


// Parameters
AUTO_THRESH = "Otsu dark";  // auto-thresholding method used to find nuclei
NUC_AREA_UM2 = 100;  // minimum size of a nucleus in Micron^2
MED_FILT_RAD = 2;  // median filter radius used to clean up nuclear segmentation results
TOL_STD = 3;  // **Tolerance used to find foci** -- number of standard deviations above local background
              // Note: standard deviation of intensities is calculated separately for each nucleus 
CHANNEL_NUC = 1;  // channel number for nuclei (i.e. DAPI)
CHANNEL_FOCI = 2;  // channel number for foci to count


// Main Macro -- get folder of images to analyze and loop over images finding nuclei + counting foci
path = getDirectory("Choose a folder of images to analyze (count foci in nuclei)");
images = getFileList(path);
run("Clear Results");
setBatchMode(true);
for (i=0; i<images.length; i++) {
	open(path + File.separator + images[i]);
	imageID = getImageID();
	countNuclearFoci(imageID, path);
	selectImage(imageID);
	close();
}
setBatchMode(false);
columnsNonBlank = newArray("Image");
columnsToKeep = newArray("Image", "Nucleus", "Nuc_X", "Nuc_Y", "Area_um2", "Tolerance", "nFoci");
cleanResults(columnsNonBlank, columnsToKeep);
saveAs("Results", path + File.separator + "Results_Foci.csv");


// --- helper functions ---

function countNuclearFoci(imageID, path) {
	// auto-segment nuclei and count foci per nucleus
	// - save result overlay image
	// - append foci count & other info to results table
	// requires getRoiCentre()
	title = getTitle();
	run("Z Project...", "projection=[Average Intensity]");
	projID = getImageID();
	roiManager("Reset");
	Stack.setChannel(CHANNEL_NUC);
	run("Duplicate...", " ");
	setAutoThreshold(AUTO_THRESH);
	run("Convert to Mask");
	run("Median...", "radius=" + MED_FILT_RAD);
	run("Watershed");
	run("Analyze Particles...", "size=" + NUC_AREA_UM2 + "-Infinity show=Overlay exclude include add");
	// N.B "Analyze Particles..." adds junk intensity stats to Results table -- clean up later 
	nNuclei = roiManager("count");
	close();
	selectImage(projID);
	Stack.setChannel(CHANNEL_FOCI);
	focusCounts = newArray(nNuclei);
	for (n=0; n<nNuclei; n++) {
		roiManager("select", n);
		nucleusName = "N" + n;
		roiManager("Rename", nucleusName);
		nucXY = getRoiCentre();
		getStatistics(area, mean, min, max, std);
		run("Colors...", "foreground=white background=black selection=cyan");
		run("Add Selection...");
		tolerance = std * TOL_STD;
		run("Find Maxima...", "noise=" + tolerance + " output=[Point Selection]");
		getSelectionCoordinates(xpts, ypts);
		nFoci = xpts.length;
		focusCounts[n] = nFoci;
		row = nResults;
		setResult("Image", row, title);
		setResult("Nucleus", row, nucleusName);
		setResult("Nuc_X", row, nucXY[0]);
		setResult("Nuc_Y", row, nucXY[1]);
		setResult("Area_um2", row, area);
		setResult("Tolerance", row, tolerance);
		setResult("nFoci", row, nFoci);
		run("Colors...", "foreground=white background=black selection=yellow");
		run("Add Selection...");
	}
	baseName = substring(title, 0, (lengthOf(title) - 4));	
	saveAs("Tiff", path + File.separator + baseName + "_Foci.tif");
	close();
}

function getRoiCentre() {
	// return array of (x, y) coords for centre of active selection bounding box
	Roi.getBounds(x, y, width, height);
	xc = x + width/2;
	yc = y + height/2;
	return newArray(xc, yc);
}

function cleanResults(columnsNonBlank, columnsToKeep) {
	// remove rows where columns named in "columnsNonBlank" Array are 0
	// keep only columns named in "columnsToKeep" Array
	// requires getCol()
	nNonBlank = columnsNonBlank.length;
	for (n=0; n<nNonBlank; n++) {
		rows = nResults;
		for (r=rows-1; r>=0; r--) {
			if (getResult(columnsNonBlank[n], r) == 0) {
				IJ.deleteRows(r,r);
			}
		}
	}
	nRows = nResults;
	nCols = columnsToKeep.length;
	allValues = newArray();  // for all columns of results, joined into 1 sequence
	for (c=0; c<nCols; c++) {
		column = getCol(columnsToKeep[c]);
		// IJ Macros cannot have arrays of arrays, so need to join all cols
		allValues = Array.concat(Array.copy(allValues), column);
	}
	run("Clear Results");
	for (r=0; r<nRows; r++) {
		for (c=0; c<nCols; c++) {
			// N.B indexing into "allValues", which increments over rows then columns
			setResult(columnsToKeep[c], r, allValues[r+(c*nRows)]);	
		}
	}
}

function getCol(columnName) {
	// copy contents of a named Column in Results table to an Array
	rows = nResults;
	values = newArray(rows);
	for (r=0; r<nResults; r++) {
		value = getResult(columnName, r);
		if (isNaN(value)) {
			value = getResultString(columnName, r);
		}
		values[r] = value;
	}
	return values;
}
