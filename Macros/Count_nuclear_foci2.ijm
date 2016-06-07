// ImageJ Macro for batch analysis of focus count per nucleus (per channel)
// with a folder of multi-channel images.
// - Assumes all images have the same number / arrangement of channels
// - Assumes all non-nucleus channels contain foci to count
// - Threshold to find peaks is a fraction of slice max - local background
// 
// Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility
// License Creative Commons CC-BY


// Parameters
AUTO_THRESH = "Otsu dark";  // auto-thresholding method used to find nuclei
NUC_AREA_UM2 = 130;  // minimum size of a nucleus in Micron^2
MED_FILT_RAD = 2;  // median filter radius used to clean up nuclear segmentation results
GAUSS_SIGMA = 1;  // gaussian filter sigma for smoothing noise in foci channel
PEAK_BG_TO_MAX_FRACTION = 5  // fraction of (slice max - local background) difference
                             // used as tolerance for peak-finding -- background is
                             // calculated separately for each nucleus 
CHANNEL_NUC = 1;  // channel number for nuclei (i.e. DAPI)
fociColors = newArray("green", "red");  // at least 1 color per focus channel needed!

// update parameters from dialog
Dialog.create("Count Nuclear Foci");
Dialog.addNumber("Nucleus Channel", 1);
Dialog.addString("Nuclear Threshold", AUTO_THRESH);
Dialog.addNumber("Minimum Nuclear Area (um^2)", NUC_AREA_UM2);
Dialog.addNumber("Foci Gaussian Blur Sigma", GAUSS_SIGMA);
Dialog.addNumber("Foci Background-to-Max Fraction, 1/", PEAK_BG_TO_MAX_FRACTION);
Dialog.show();
CHANNEL_NUC = Dialog.getNumber();
AUTO_THRESH = Dialog.getString();
NUC_AREA_UM2 = Dialog.getNumber();
GAUSS_SIGMA = Dialog.getNumber();
PEAK_BG_TO_MAX_FRACTION = Dialog.getNumber();


// Main Macro -- get folder of images to analyze and loop over images finding nuclei + counting foci
path = getDirectory("Choose a folder of images to analyze (count foci in nuclei)");
images = getFileList(path);
run("Clear Results");
setBatchMode(true);
for (i=0; i<images.length; i++) {
	open(path + File.separator + images[i]);
	imageID = getImageID();
	fc = countNuclearFoci(imageID, path);
	selectImage(imageID);
	close();
}
setBatchMode(false);
columnsNonBlank = newArray("Image");
columnsToKeep = newArray("Image", "Nucleus", "Nuc_X", "Nuc_Y", "Area_um2");
for (c=0; c<fc.length; c++) {
	columnsToKeep = Array.concat(columnsToKeep, newArray("Tolerance" + fc[c], "nFoci" + fc[c]));
}
cleanResults(columnsNonBlank, columnsToKeep);
saveAs("Results", path + File.separator + "Results_Foci.csv");


// --- helper functions ---

function countNuclearFoci(imageID, path) {
	// auto-segment nuclei and count foci per nucleus
	// - save result overlay image
	// - append foci count & other info to results table
	// - returns Array of foci Channel numbers meaasured
	// requires getRoiCentre()
	title = getTitle();
	run("Z Project...", "projection=[Average Intensity]");
	projID = getImageID();
	roiManager("Reset");
	Stack.setChannel(CHANNEL_NUC);
	run("Duplicate...", " ");
	getPixelSize(unit, pixelWidth, pixelHeight);
	nuclearRadius = sqrt(NUC_AREA_UM2) / pixelWidth;
	fl = nuclearRadius * 2.5;
	fs = nuclearRadius / 10;
	run("Bandpass Filter...", "filter_large=" + fl + " filter_small=" + fs + " suppress=None tolerance=5 autoscale saturate");
	setAutoThreshold(AUTO_THRESH);
	run("Convert to Mask");
	run("Watershed");
	run("Analyze Particles...", "size=" + NUC_AREA_UM2 + "-Infinity show=Overlay exclude include add");
	// N.B "Analyze Particles..." adds junk intensity stats to Results table -- clean up later 
	nNuclei = roiManager("count");
	close();
	selectImage(projID);

	// assume all non-nucleus channels contain foci to count...
	getDimensions(w, h, nc, nz, nt);
	fociChannels = newArray();
	channelsMax = newArray();
	for (c=1; c<=nc; c++) {
		if (c != CHANNEL_NUC) {
			fociChannels = Array.concat(fociChannels, c);
			Stack.setChannel(c);
			run("Gaussian Blur...", "sigma=" + GAUSS_SIGMA + " slice");
			run("Select All");
			getStatistics(area, mean, min, max);
			channelsMax = Array.concat(channelsMax, max);
		}
	}
	
	for (n=0; n<nNuclei; n++) {	
		tolAll = newArray();
		nFociAll = newArray();
		for (c=0; c<fociChannels.length; c++) {
			roiManager("select", n);
			Stack.setChannel(fociChannels[c]);
			if (c==0) {  // name nuclear ROI, get coords, add outline to overlay
				nucleusName = "N" + n;
				roiManager("Rename", nucleusName);
				nucXY = getRoiCentre();	run("Colors...", "foreground=white background=black selection=cyan");
				run("Add Selection...");
			}
			//getStatistics(area, nuclearFociMean, min, max);
			run("Set Measurements...", "modal median"); 
			List.setMeasurements();
			fociBackground = List.getValue("Median");
			// i.e. tolerance a fraction of distance between local background and slice max
			tolerance = (channelsMax[c] - fociBackground) / PEAK_BG_TO_MAX_FRACTION;
			run("Find Maxima...", "noise=" + tolerance + " output=[Point Selection]");
			nFoci = 0;
			if (selectionType() == 10) {
				// i.e. Find Maxima created a point selection (selectionType=10) 
				getSelectionCoordinates(xpts, ypts);
				nFoci = xpts.length;
				run("Colors...", "foreground=white background=black selection=" + fociColors[c]);
				run("Add Selection...");
			}
			tolAll = Array.concat(tolAll, tolerance);
			nFociAll = Array.concat(nFociAll, nFoci);
		}
		row = nResults;
		setResult("Image", row, title);
		setResult("Nucleus", row, nucleusName);
		setResult("Nuc_X", row, nucXY[0]);
		setResult("Nuc_Y", row, nucXY[1]);
		setResult("Area_um2", row, area);
		//Array.print(fociChannels);
		//Array.print(tolAll);
		//Array.print(nFociAll);
		//waitForUser;
		for (c=0; c<fociChannels.length; c++) {
			setResult("Tolerance" + fociChannels[c], row, tolAll[c]);
			setResult("nFoci" + fociChannels[c], row, nFociAll[c]);			
		}
	}
	baseName = substring(title, 0, (lengthOf(title) - 4));	
	saveAs("Tiff", path + File.separator + baseName + "_Foci.tif");
	close();
	return fociChannels;
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
