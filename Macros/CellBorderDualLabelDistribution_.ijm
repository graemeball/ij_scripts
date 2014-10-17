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
CELL_CIRCUMF = 100           // normalize to this circumference, in pixels
PROFILE_THICKNESS = 7        // consider this line thickness, in pixels
DOMAIN_THRESH_STDDEV = 3.0;  // standard deviations above background
DOMAIN_THRESH_SIMPLE = 0.5   // fraction of max intensity for domain thresholding


// -- macro main body --
inputImageID = getImageID();
Stack.getPosition(c, z, t);
centralSlice = z;
run("Line Width...", "line=" + PROFILE_THICKNESS);
convertOvalToSegmentedLineRoi();
Stack.setPosition(1, centralSlice, 1);
run("Straighten...", "title=" + "Profile_C1" + " line=" + PROFILE_THICKNESS);
run("Scale...", "x=- y=- width=100 height=" + PROFILE_THICKNESS + " interpolation=Bilinear average create title=Profile_C1_Norm");
//run("Gaussian Blur...", "sigma=1");
profileC1N = getTitle();
run("Select All");
run("Plot Profile");
Plot.getValues(plotX, avIntensC1);
selectImage(inputImageID);
Stack.setPosition(2, centralSlice, 1);
run("Straighten...", "title=" + "Profile_C2" + " line=" + PROFILE_THICKNESS);
run("Scale...", "x=- y=- width=100 height=" + PROFILE_THICKNESS + " interpolation=Bilinear average create title=Profile_C2_Norm");
//run("Gaussian Blur...", "sigma=1");
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
	// correct large 1st-last gap at break by averaging these coords
	iLast = xpoints.length - 1;
	xEnds = (xpoints[0] + xpoints[iLast]) / 2;
	yEnds = (ypoints[0] + ypoints[iLast]) / 2;
	xpoints[0] = xEnds;
	xpoints[iLast] = xEnds;
	ypoints[0] = yEnds;
	ypoints[iLast] = yEnds;
	makeSelection("polyline", xpoints, ypoints);
}

function channelProfile(c) {
	// return 'normalized' (x=100pix) line profile image title for channel 'c' 
	// TODO
}

function interDomainDistance(iC1, iC2) {
	// Distance using intensity threshold to define domain boundaries
	// - assumes C1 domain is at profile RHS, C2 at LHS
	// - negative inter-domain distance for missing boundary / muddled channels
	iC1bg = Array.slice(iC1, 0, 50);
	iC2bg = Array.slice(iC2, 50, 100);
	threshC1 = domainThresh3stdDev(iC1, iC1bg);
	threshC2 = domainThresh3stdDev(iC2, iC2bg);
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

function domainThresh3stdDev(iAll, iBackground) {
	// return intensity threshold identifying label domain
	// using background + 3*stdDev of background region
	Array.getStatistics(iAll, minAll, maxAll, meanAll, stdDevAll);
	Array.getStatistics(iBackground, minBg, maxBg, meanBg, stdDevBg);
	thresh = meanBg + 3 * stdDevBg;
	return thresh;
}

function domainThreshSimple(iArr) {
	// return intensity threshold identifying label domain
	// using 1/2 max signal above background
	Array.getStatistics(iArr, min, max, mean, stdDev);
	thresh = min + 0.5 * (max - min); 
	return thresh;
}