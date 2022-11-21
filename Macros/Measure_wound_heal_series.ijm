// Measure_wound_heal_series.ijm
// Estimate wound area and mean thickness over time.
// - using "Find Edges" and median filter
// - wound area selections added to overlay for each frame
// - summary measurements written to results table
// - N.B. image is converted to 8-bit for analysis
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2022)
// License: GNU GPL
//


// default parameters
CELL_DIAMETER = 20;  // in calibrated units, e.g. um
THRESHOLD = 20;  // (1-255) after 8-bit conversion, edge find & filtering
MIN_WOUND_AREA = 1000;  // minimum wound area (i.e. smallest fragment), in units^2
setOption("BlackBackground", true);  // just because

// check active image is valid and prompt user to update parameters
imageID = getImageID();
imageTitle = getTitle();
checkImageValid(imageID, 1, 1, 1, 1, 1, -1, newArray(8, 16, 32), false, false);
Stack.getUnits(xu, yu, zu, tu, vu);
xunits = " (" + xu + ")";
au = xu + "^2";
aunits = " (" + au + ")";
Dialog.create("Measure_wound_heal_series");
Dialog.addNumber("Cell Diameter" + xunits, CELL_DIAMETER);
Dialog.addNumber("Threshold (1-255, after filter)", THRESHOLD);
Dialog.addNumber("Minimum wound fragment area" + aunits, MIN_WOUND_AREA);
Dialog.show();
cell_rad = Dialog.getNumber() / 2;
toUnscaled(cell_rad);  // cell radius in pixels (N.B. in-place conversion!)
thresh = Dialog.getNumber();
min_wound_area = Dialog.getNumber();

print("\n--- Measure_wound_heal_series.ijm ---");
logParameter("cell_diameter", cell_rad*2, xu);
logParameter("threshold", thresh, "");
logParameter("min_wound_area", min_wound_area, au);

run("8-bit");
Stack.getDimensions(w, h, nc, nz, nt);
setBatchMode("hide");

// 1st pass - find wound area ROIs
showStatus("Finding wound areas");
showProgress(0);
for (t = 0; t < nt; t++) {
	hasWound = addWoundSelectionToOverlay(t+1, cell_rad, thresh, min_wound_area);
	roiManager("reset");
	if (!hasWound) {
		t = nt;
	}
	showProgress(t / nt);
}

// 2nd pass - quantify wound area and average thickness
run("Clear Results");
run("To ROI Manager");
row = nResults;
frameInterval = Stack.getFrameInterval();
showStatus("Measuring wound areas");
showProgress(0);
nROIs = roiManager("count");
for (i = 0; i < nROIs; i++) {
	run("Select None");
	getStatistics(totalArea, mean, min, max, std);
	roiManager("select", i);
	Stack.getPosition(c, z, t);
	getStatistics(area, mean, min, max, std);
	if (i==0) {
		woundArea1 = area;
	}
	setResult("Image", row, imageTitle);
	setResult("Frame", row, t);
	setResult("Time", row, (t-1)*frameInterval);
	setResult("WoundArea", row, area);
	setResult("PctTotalArea", row, 100*area/totalArea);
	setResult("PctWoundArea1", row, 100*area/woundArea1);
	Xthicknesses = measureXthicknesses();
	Array.getStatistics(Xthicknesses, minTh, maxTh, meanXthickness, stdDevTh);
	toScaled(meanXthickness);
	setResult("meanXthickness", row, meanXthickness);
	row++;
	showProgress(i / nROIs);
}
run("From ROI Manager");

Stack.setFrame(1);
setBatchMode("exit and display");


// --- function definitions ---

function logParameter(parName, parVal, parUnit) {
	// print parameter values to log window
	print("" + parName + "=" + parVal + " " + parUnit);
}

function measureXthicknesses() {
	// return array (length nY) of X thicknesses in pixels for current selection
	run("Create Mask");
	getDimensions(w, h, nc, nz, nt);
	Xthicknesses = newArray(h);
	for (y = 0; y < h; y++) {
		makeRectangle(0, y, w, 1);
		getStatistics(area, mean, min, max, std);
		Xthicknesses[y] = mean * w / 255;
	}
	close();  // mask image for selection
	return Xthicknesses;
}

function addWoundSelectionToOverlay(frame, cell_rad, thresh, min_area) {
	// for specified frame, generate a selection for wound/scratch
	// - uses cell_rad (pixels) to tune median filter & gap closing
	// - thresh used to threshold processed edge-filtered image (0-thresh for wound)
	// - wound objects subject to min_area
	// - all area-filtered objects for frame combined to give final selection
	// - resulting selection is restored to input image
	// return "true" if a selection is found
	Stack.setFrame(frame);
	run("Select None");
	roiManager("reset");
	run("Duplicate...", "use");
	run("Find Edges");
	run("Median...", "radius=" + cell_rad/2);
	setThreshold(0, thresh);
	run("Convert to Mask");
	run("Options...", "iterations=" + cell_rad/2 + " count=1 black pad do=Nothing");
	run("Close-");
	run("Analyze Particles...", "size=" + min_area + "-Infinity add");
	nRois = roiManager("count");
	if (nRois > 0) {
		foundSelection = true;
		roiManager("deselect");
		roiManager("Combine");
		roiManager("add");
		close();
		roiManager("select", nRois);
		run("Add Selection...");
	} else {
		foundSelection = false;
		close();
	}
	run("Options...", "iterations=1 count=1 black do=Nothing");
	return foundSelection;
}

function checkImageValid(imageID, Cmin, Cmax, Zmin, Zmax, Tmin, Tmax, nBits, isHyper, isSquare) {
	// check an input image is valid for this macro, where:
	// - C,Z,Tmin/max are min, max dimension limits (-1 is no max)
	// - nBits is an array of valid bit depths
	// - isHyper and isSquare are bools - where false does not impose requirement
	// - requires arrayContains(), arraySprint()
	// exits macro with message explaining 1st fail or returns silently
	issues = "";
	getDimensions(w, h, nc, nz, nt);
	if (nc < Cmin) {
		issues = "number of channels " + nc + " < " + Cmin + " required minimum";
	}
	if (Cmax > -1 && nc > Cmax) {
		issues = "number of channels " + nc + " > " + Cmin + " required maximum";
	}
	if (nz < Zmin) {
		issues = "number of Z " + nz + " < " + Zmin + " required minimum";
	}
	if (Zmax > -1 && nz > Zmax) {
		issues = "number of Z " + nz + " > " + Zmin + " required maximum";;
	}
	if (nt < Tmin) {
		issues = "number of frames " + nt + " < " + Tmin + " required minimum";;
	}
	if (Tmax > -1 && nt > Tmax) {
		issues = "number of frames " + nt + " > " + Tmin + " required maximum";;
	}
	if (!arrayContains(nBits, bitDepth())) {
		issues = "bitDepth=" + bitDepth() + " not allowed (expected " + arraySprint(nBits) + ")";
	}
	if (isHyper == true) {
		if (!Stack.isHyperstack) {
			issues = "image must be a hyperstack";
		}
	}
	if (isSquare == true) {
		if (w != h) {
			issues = "image is shape " + w + "*" + h + " but should be square";
		}
	}
	if (issues.length > 0) {
		exit(issues);
	}
}

function arrayContains(A, val) {
	// return true if A contains val
	valFound = false;
	for (i = 0; i < A.length; i++) {
		if (A[i] == val) {
			valFound = true;
			i = A.length;  // i.e. break
		}
	}
	return valFound;
}

function arraySprint(A) {
	// convert array to string by concatenating with , separator
	if (A.length > 0) {
		str = "" + A[0];
		if (A.length > 1) {
			for (i = 1; i < A.length; i++) {
				str += "," + A[i]; 
			}
		}
		return str;
	} else {
		return "";
	}
}
