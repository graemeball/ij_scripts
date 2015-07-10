// Load_Leica_Tiffs.ijm: read folder of Leica Tiffs into a hyperstack
// Usage: 
//   user must choose first file in Leica Tiff series
//   (assumes file name pattern is "basename_z??_ch??.tif") 
// Author: graemeball@googlemail.com, Dundee Imaging Facility (2015)
// License: Public Domain (CC0)
// 

firstFilePath = File.openDialog("Choose first Tiff file in Leica series");
tiffFiles = findTiffFileSeries(firstFilePath);
readTiffsIntoHyperstack(tiffFiles);

// -- helper functions --

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
