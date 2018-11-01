// Macro helper functions
// Graeme Ball (graemeball@gmail.com)
// Creative Commons CC-BY

// for a sample and mask stack, return total sample intensity in masked region
function totalMaskedIntensity(sample, mask) {
    maskedSampleTotal = 0.0;
    for (s = 1; s <= slices; s++) {
        selectWindow(mask);
        setSlice(s);
        run("Duplicate...", "title=maskSlice");
        run("Select All");
        selectWindow(sample);
        setSlice(s);
        run("Duplicate...", "title=sampleSlice");
        imageCalculator("Multiply create 32-bit", "sampleSlice", "maskSlice");
        selectWindow("Result of sampleSlice");
        getRawStatistics(nPixels, mean, min, max, std, histogram);
        sampleTotal = nPixels * mean;
        maskedSampleTotal += sampleTotal / 255;
        selectWindow("maskSlice");
        close();
        selectWindow("sampleSlice");
        close();
        selectWindow("Result of sampleSlice");
        close();
    }
    return maskedSampleTotal;
}

function rejectSecondCoordPair(x1, y1, x2, y2, tol) {
	print("reject coords with tol=" + tol + "pix");
	// filter (x1, y1) coords in-place, rejecting where close to (x2, y2)
	//   => reject where (x2 - x1)^2 + (y2 - y1)^2 < tol^2
	// N.B. returns the number of rejects, which is the number of junk
	//   elements that must be trimmed from x1 and y1 after returning...
	nRejects = 0;
	for (i=0; i<x1.length; i++) {
		reject = false;
		for (j=0; j<x2.length; j++) {
			if (pow((x2[j] - x1[i]), 2) + pow((y2[j] - y1[i]), 2) < pow(tol, 2)) {
				reject = true;
				j = x2.length;  // i.e. break!
			}
		}
		if (!reject) {
			// overwrite the initial part of x1 and y1 arrays with non-rejects
			x1[i - nRejects] = x1[i];
			y1[i - nRejects] = y1[i];
		} else {
			nRejects += 1;
		}
	}
	// would like to trim the rejects here, but cannot alter array length
	return  nRejects;	
	// TODO: improve algo! since O(n*m) where n, m are lengths of (x1,y1) & (x2,y2) 
}

function measureCircularROImean(xc, yc, diam) {
  // return mean intensity in a circular ROI, all units in pixels
  x_tl = maxOf(round(xc - diam/2), 0);
  y_tl = maxOf(round(yc - diam/2), 0);
  makeOval(x_tl, y_tl, diam, diam);
  getStatistics(area, mean);
  return mean;
}

function dogFilter(imageID, scale, multiplier) {
	// return imageID of new, DoG-filtered image; scale in calibrated units
	selectImage(imageID);
	outputTitle = "DoG" + scale + "x" + multiplier + "_" + getTitle();
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

function baseName(filename) {
	// return filename string without extension
	return substring(filename, 0, lastIndexOf(filename, "."));
}

function plog(file, text) {
	// print text to *both* the ImageJ log window and a text file
	print(text);
	print(file, text);
}

// for a sample and mask stack, return total sample intensity in masked region
function totalMaskedIntensity(sample, mask) {
    maskedSampleTotal = 0.0;
    for (s = 1; s <= slices; s++) {
        selectWindow(mask);
        setSlice(s);
        run("Duplicate...", "title=maskSlice");
        run("Select All");
        selectWindow(sample);
        setSlice(s);
        run("Duplicate...", "title=sampleSlice");
        imageCalculator("Multiply create 32-bit", "sampleSlice", "maskSlice");
        selectWindow("Result of sampleSlice");
        getRawStatistics(nPixels, mean, min, max, std, histogram);
        sampleTotal = nPixels * mean;
        maskedSampleTotal += sampleTotal / 255;
        selectWindow("maskSlice");
        close();
        selectWindow("sampleSlice");
        close();
        selectWindow("Result of sampleSlice");
        close();
    }
    return maskedSampleTotal;
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

function min(a, b) {
	// return minimum of 2 numbers, a and b
	if (a < b) {
		return a;
	} else {
		return b;
	}
}

function findTiffFileSeries(firstFilePath) {
	// ask user to pick a tiff file and find similarly-named files
	firstFileName = File.getName(firstFilePath);
	fileList = newArray(0);
	directory = File.getParent(firstFilePath);
	allFiles = getFileList(directory);
	prefix = substring(firstFileName, 0, indexOf(firstFileName, "_z"));
	// file name pattern assumed to be: basename_z??_ch??.tif
	tiffFiles = filterFiles(allFiles, prefix + "_z[0-9]+_ch[0-9]+\.tif");
	return tiffFiles;
}

function filterFiles(allFiles, regex) {
	// filter to pick out only those filenames matching regular expression
	filteredFiles = newArray(0);
	for (f = 0; f < allFiles.length; f++) {
		if (matches(File.getName(allFiles[f]), regex)) {
			filteredFiles = Array.concat(filteredFiles, allFiles[f]);
		}
	}
	return filteredFiles;
}

function readTiffsIntoHyperstack(tiffFiles) {
	// make hyperstack from list of tiff files (ordered by Channel then Z)
    // requires findIntegerAfter()
	setBatchMode(true);
	open(tiffFiles[0]);
	stackID = getImageID();
	nc = 0;
	nz = 0;
	for (f = 1; f < tiffFiles.length; f++) {
		run("Add Slice");
		open(tiffFiles[f]);
		nc = maxOf(nc, findIntegerAfter("_ch", File.getName(tiffFiles[f])));
		nz = maxOf(nz, findIntegerAfter("_z", File.getName(tiffFiles[f])));
		run("Select All");
		run("Copy");
		selectImage(stackID);
		run("Paste");
	}
	nc += 1;  // since channel numbers count from zero
	nz += 1;
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" + nc + " slices=" + nz + " frames=1 display=Composite");
	setBatchMode(false);
	// no return, but now the hyperstack is the top window
}

function findIntegerAfter(pattern, string) {
	// find integer in a string after the specified pattern
	startOfNumber = indexOf(string, pattern) + lengthOf(pattern);
	startOfRest = startOfNumber;
	while (matches(substring(string, startOfRest, startOfRest+1), "[0-9]")) {
		startOfRest++;
	}
	return parseInt(substring(string, startOfNumber, startOfRest));
}

function pseudoFFcorrect() {
	// pseudo-flat-field correction of active image
	// uses gaussian blur of 1/4 image height as pseudo-flat-field
	inTitle = getTitle();
	run("32-bit");
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=" + (getHeight() / 4));
	getStatistics(area, mean);
	run("Divide...", "value=" + mean);
	ffTitle = getTitle();
	imageCalculator("Divide create 32-bit", inTitle, ffTitle);
	resultTitle = getTitle();
	selectWindow(ffTitle);
	close();
	selectWindow(resultTitle);
}

function parseIntegersIntoArray(csvString, nt) {
	// return array of integers parsed from a string of comma separated values
	zArray = newArray(nt);  // we expect 1 Z-slice specified per time
	t = 1;  // time point
	do {
		nextComma = indexOf(csvString, ",");
		if (nextComma > -1) {
			nextIntString = substring(csvString, 0, nextComma);
			csvString = substring(csvString, nextComma+1);  // pop
		} else {
			nextIntString = csvString;
			csvString = "";  // all gone
		}
		nextInt = parseInt(nextIntString);
		if (isNaN(nextInt)) {
			exit("Error, " + nextIntString + " is not an integer!");
		} else {
			if (t <= zArray.length) {
				zArray[t - 1] = nextInt;
			}  // else ... out-of-bounds, so just forget it
			t++;
		}
	} while (lengthOf(csvString) > 0);
	if (t != nt + 1) {
		exit("Error, expected " + nt + " Z slices but you entered " + (t - 1));
	}
	return zArray;
}

function thresholdIntensities(I, thresh) {
	// return trimmed array containing only above-threshold intensities in I
	// checks whether pixel intensities >= thresh
	I2 = newArray(I.length);
	count = 0;
	for (i = 0; i < I.length; i++) {
		if (I[i] >= thresh) {
			I2[count] = I[i];
			count++;
		}
	}
	return Array.trim(I2, count);
}

function printArray(A, valuesPerLine) {
	// print array to log window with n values per line
	nval = 0;
	valueString = "";
	for (i = 0; i < A.length; i++) {
		if (nval == valuesPerLine) {
			print(valueString + A[i]);
			nval = 0;
			valueString = "";
		} else {
			valueString = valueString + A[i] + ",";
			nval++;
		}
	}
	print(valueString);
}

