// TH data batch analysis ImageJ1 Macro
//   (for Simon Plummer, MicroMatrices)
//
// Usage: run macro and follow instructions:
//   - you will be asked to choose an input folder containing .tif images to analyze
//   - you can accept or adjust nucelus size (in microns)
//   - *if* the first image has Unit=pixel you will be asked for XY pixel size in microns
//     (assume all images in the folder have a micron calibration *or* the same pixel size)
//
// Output:
//   Produces a Results_THba_<timestamp>/ folder in the input folder containing
//   - a summary Results.csv
//   - a info.txt file containing parameters used
//   as well as, for each input image "imageN.tif":
//     - imageN_RNA.tif, with ROI for segmented RNA in situ area
//     - imageN_nuceli.tif, with multi-point selection showing nuclei counted
//   N.B. the output images are scaled 0.25 times in XY to save space
//
// Copyright: graemeball@gmail.com (2015)
// License: Creative Commons CC-BY


// --- parameters / setup ---
// radius of smallest nucleus (microns)
smallNuclearRadius = 1.6;
largeDOGmultiple = 3;  // multiple of smallNuclearRadius for large filter (Difference of Gaussian)
// default pixel size (microns)
um_per_pix = 0.220;
// make sure we measure area, mean and stdDev
run("Set Measurements...", "area mean standard redirect=None decimal=3");
// configure Results saving: choose .csv
run("Input/Output...", "jpeg=85 gif=-1 file=.csv copy_row save_column save_row");
// scaling factor for color-deconvolved "channels" showing RNA area / nucleus spots
scaleFactor = 0.25;
// rolling ball radius for background subtraction
backgroundRadius = 100;
// stains for color deconvolution
stains = "H DAB";
// auto-thresholding method used to identify DAB stain
DABautoThreshMethod = "Otsu";

// --- main body of the macro ---

// 1. get input folder, build list of files, and make output folder
inputFolder = getDirectory("Choose a folder containing cropped TIFF images to analyze");
files = getFileList(inputFolder);
tiffs = filterTiffs(files);
outputFolder = inputFolder + "Results_THba_" + timeStamp();
print("Saving results in: " + outputFolder);
File.makeDirectory(outputFolder);
smallNuclearRadius = getNumber("Diameter of smallest nucleus in microns", smallNuclearRadius*2) / 2;

// 2. iterate through each input tiff file,
//    - saving results in arrays rnaAreas and nucleusCounts
//    - also write out separated RNA and nucelus channels with ROI/spot overlays
nInput = tiffs.length;
rnaAreas = newArray(nInput);
nucleusCounts = newArray(nInput);
setBatchMode(true);
for (i = 0; i < nInput; i++) {
	open(inputFolder + File.separator + tiffs[i]);
	// for 1st image, check if we need to set calibration
	if (i == 0) {
		getPixelSize(unit, pixelWidth, pixelHeight);
		if (!(unit == "micron")) {
			um_per_pix = getNumber("Enter pixel width/height in microns", um_per_pix);
		}
	}
	// 2a. split image into 3 "channels" (Haeomotoxylin, DAB, background)
	run("Subtract Background...", "rolling=" + backgroundRadius + " light create");  // ensure a neutral background for color decon!
	// see: http://www.mecourse.com/landinig/software/cdeconv/cdeconv.html
    run("Colour Deconvolution", "vectors=[" + stains + "] hide");
	selectWindow(tiffs[i]);
	close();
	selectWindow(tiffs[i] + "-(Colour_3)");
	close();  // close background "channel"
	// 2b. measure RNA in situ area (DAB)
	selectWindow(tiffs[i] + "-(Colour_2)");
	setVoxelSize(um_per_pix, um_per_pix, 1, "micron");
	setAutoThreshold(DABautoThreshMethod);
	run("Create Selection");
	run("Measure");
	downsampleCurrentImageWithSelection(scaleFactor);
	if (selectionType() > -1) {
		run("Add Selection...");  // add to overlay
	}
	saveAs("Tiff", outputFolder + File.separator + stripExt(tiffs[i]) + "_RNA.tif");
	rnaAreas[i] = getResult("Area", nResults - 1);
	close();
	// 2c. count nuclei (Haemototoxylin)
	selectWindow(tiffs[i] + "-(Colour_1)");
	setVoxelSize(um_per_pix, um_per_pix, 1, "micron");
	rename("nuclei");
	run("Duplicate...", " ");
	run("Grays");
	run("Invert");
	run("16-bit");
	rename("gaussSmall");
	run("Duplicate...", " ");
	rename("gaussLarge");
	largeRadius = smallNuclearRadius * largeDOGmultiple;
	run("Gaussian Blur...", "sigma=" + largeRadius + " scaled");
	selectWindow("gaussSmall");
	run("Gaussian Blur...", "sigma=" + smallNuclearRadius + " scaled");
	imageCalculator("Subtract create", "gaussSmall", "gaussLarge");
	rename("DOG");
	run("Select All");
	run("Measure");
	getStatistics(area, mean, min, max, std, histogram);
	run("Find Maxima...", "noise=" + std + " output=Count");
	nucleusCounts[i] = getResult("Count", nResults - 1);
	selectWindow("DOG");
	run("Find Maxima...", "noise=2 output=[Point Selection]");
	selectWindow("nuclei");
	run("Restore Selection");
	downsampleCurrentImageWithSelection(scaleFactor);
	if (selectionType() > -1) {
		run("Add Selection...");  // add to overlay
	}
	saveAs("Tiff", outputFolder + File.separator + stripExt(tiffs[i]) + "_nuclei.tif");
	close();
	close("gaussSmall");
	close("gaussLarge");
	close("DOG");
	
}
setBatchMode(false);

// 3. finally write summary Results.csv and log.txt files to Results folder
run("Clear Results");
for (i = 0; i < nInput; i++) {
	setResult("File", i, tiffs[i]);
	setResult("RNA Area (um^2)", i, rnaAreas[i]);
	setResult("Nucleus Count", i, nucleusCounts[i]);
}
saveAs("Results", outputFolder + File.separator + "Results.csv");
f = File.open(outputFolder + File.separator + "log.txt");
print(f, "- Background subtraction using rolling ball, radius=" + backgroundRadius + "\n");
print(f, "- color deconvolution of stains: " + stains + "\n");
print(f, "- RNA (DAB) autothresholding method: " + DABautoThreshMethod + "\n");
print(f, "- DOG filter, smallest nuclear radius (um) =" + smallNuclearRadius + "\n");
print(f, "- DOG filter, largest nuclear radius (um) =" + (smallNuclearRadius * largeDOGmultiple) + "\n");


// --- helper function definitions ---
function filterTiffs(files) {
	// for an array of file names, return a new array of those that are tiffs
	tiffs = newArray(0);
	for (i=0; i < files.length; i++) {
		file = files[i];
		if (endsWith(file, ".tif") || endsWith(file, ".tiff")) {
			f = newArray(1);
			f[0] = file;
			tiffs = Array.concat(tiffs, f);
		}
	}
	return tiffs;
}

function timeStamp(){
	// generate a time stamp string
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	timeString = toString(year) + "-" + twoDigit(month) + "-" + twoDigit(dayOfMonth);
	DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
	timeString = timeString + "_" + DayNames[dayOfWeek];
	timeString = timeString + twoDigit(hour) + "-" + twoDigit(minute) + "-" + twoDigit(second);
	return timeString;
}

function twoDigit(num) {
	// pad a number from 0-99 with a single leading 0 if <10
	if (num < 10) {
		return "0" + num;
	} else {
		return toString(num);
	}
}

function stripExt(filename) {
	// return filename string without extension
	s = substring(filename, 0, lastIndexOf(filename, "."));
	return s;
}

function downsampleCurrentImageWithSelection(scaleFactor) {
	// downsample image by scaling factor, preserving current selection
	f = scaleFactor;
	inputT = getTitle();
	if (selectionType() == 10) {
		getSelectionCoordinates(x, y);
		xScaled = newArray(x.length);
		yScaled = newArray(y.length);
		for (i=0; i<x.length; i++) {
			xScaled[i] = x[i] * 0.25;
			yScaled[i] = y[i] * 0.25;
		}
		selectWindow(inputT);
		arg2 = "x=" + f + " y=" + f + " interpolation=Bilinear average create title=[inputSmall]";
		run("Select All");
		run("Scale...", arg2);
		selectWindow("inputSmall");
		makeSelection("point", xScaled, yScaled);
		selectWindow(inputT);
		close();
		selectWindow("inputSmall");
		rename(inputT);
	} else {
		run("Create Mask");
		maskT = getTitle();
		arg2 = "x=" + f + " y=" + f + " interpolation=Bilinear average create title=[maskSmall]";
		run("Select All");
		run("Scale...", arg2);
		selectWindow(inputT);
		arg2 = "x=" + f + " y=" + f + " interpolation=Bilinear average create title=[inputSmall]";
		run("Select All");
		run("Scale...", arg2);
		selectWindow("maskSmall");
		setThreshold(1, 255);
		run("Create Selection");
		selectWindow("inputSmall");
		run("Restore Selection");
		selectWindow(maskT);
		close();
		selectWindow("maskSmall");
		close();
		selectWindow(inputT);
		close();
		selectWindow("inputSmall");
		rename(inputT);
	}
}
