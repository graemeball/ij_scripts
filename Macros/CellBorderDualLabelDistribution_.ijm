// CellBorderDualLabelDistribution_ ImageJ Macro
// 
// Instructions
// ------------
// Requires 2-channel image stack (assumes Channel 1 is Green),
// - pre-cropped to cell of interest in XYZ
// - pre-rotated so that,
//   - both label poles are in the same XY plane (top & bottom)
//   - consistent orientation, i.e. green label pole always top
// - central slice containing label poles selected
// - with an oval selection corresponding to the cell boundary
//
// Output
// ------
// Plots profiles (7-pixel thick) normalized to circumference 100 pixels,
// and uses half-max criterion to define inter-domain distance
//
// Author: graemeball@googlemail.com, Dundee Central Imaging Facility (2014)
// License: Public Domain (CC0)
//

// -- parameter definitions (globals) --
// FIXME, ensure parameters used / no magic numbers!
CELL_CIRCUMF = 100     // normalize to this circumference, in pixels
PROFILE_THICKNESS = 7  // consider this line thickness, in pixels
DOMAIN_THRESH = 0.5    // fraction of max intensity for domain thresholding

// -- macro main body --
inputImageID = getImageID();
Stack.getPosition(c, z, t);
centralSlice = z;
run("Line Width...", "line=" + PROFILE_THICKNESS);
convertOvalToSegmentedLineRoi();
Stack.setPosition(1, centralSlice, 1);
run("Straighten...", "title=" + "Profile_C1" + " line=" + PROFILE_THICKNESS);
run("Scale...", "x=- y=- width=100 height=7 interpolation=Bilinear average create title=Profile_C1_Norm");
run("Gaussian Blur...", "sigma=1");
profileC1N = getTitle();
run("Select All");
run("Plot Profile");
Plot.getValues(plotX, avIntensC1);
selectImage(inputImageID);
Stack.setPosition(2, centralSlice, 1);
run("Straighten...", "title=" + "Profile_C2" + " line=" + PROFILE_THICKNESS);
run("Scale...", "x=- y=- width=100 height=7 interpolation=Bilinear average create title=Profile_C2_Norm");
run("Gaussian Blur...", "sigma=1");
profileC2N = getTitle();
run("Select All");
run("Plot Profile");
Plot.getValues(plotX, avIntensC2);
// NB. merge channels below c1=red, c2=green; but assuming data have green C1
run("Merge Channels...", "c1=" + profileC2N + " c2=" + profileC1N + " create");
run("Stack to RGB");
rename("ProfileRedGreen");
dist = interDomainDistance(avIntensC1, avIntensC2);
print("inter-domain distance = " + dist + " % cell circumference");

// -- helper functions --

function convertOvalToSegmentedLineRoi() {
	// oval broken at xMax, segmented line CW starting at yMax end
	Roi.getCoordinates(xpoints, ypoints);
	makeSelection("polyline", xpoints, ypoints);
}

function channelProfile(c) {
	// return 'normalized' (x=100pix) line profile image title for channel 'c' 
	// TODO
}

function interDomainDistance(iC1, iC2) {
	// Distance using half-max intensity to define domain boundaries
	// - assumes C1 domain is at profile RHS, C2 at LHS
	// - negative inter-domain distance for missing boundary / muddled channels
	// - prints thresholds (FIXME, remove?)
	Array.getStatistics(iC1, min1, max1, mean1, stdDev1);
	Array.getStatistics(iC2, min2, max2, mean2, stdDev2);
	threshC1 = min1 + (max1 - min1) / 2;
	threshC2 = min2 + (max2 - min2) / 2;
	print("threshC1 = " + threshC1 + ", threshC2 = " + threshC2);
	// search right from middle for Channel 1 (green) domain boundary
	boundaryC1 = -1;  // default indicates no boundary
	ix = 50;
	while (ix < 100) {
		if (iC1[ix] >= threshC1) {
			boundaryC1 = ix;
			ix = 100;  // break!
		}
		ix++;
	}
	// search left from middle for Channel 2 (red) domain boundary
	boundaryC2 = 100; // default indicates no boundary
	ix = 49;
	while (ix >= 0) {
		if (iC2[ix] >= threshC2) {
			boundaryC2 = ix;
			ix = -1;  // break!
		}
		ix--;
	}
	return boundaryC1 - boundaryC2;
}
