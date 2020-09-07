// Blind.ijm: ImageJ macro for blind analysis of image data sets
// Usage: - specify input and output folders when prompted
//        - obfuscated image files + key.txt appear in output folder
// Requires: ImageJ 1.52o
// Author: graemeball@googlemail.com, Dundee Central Imaging Facility (2020)
// License: MIT license

// get input & output folder paths
message = "Choose a folder of input files to copy";
showMessage(message);  // since getDirectory does not show message on Mac!
inPath = getDirectory(message);
if (lengthOf(inPath) < 1){
	exit("Macro cancelled.");
}
message = "Choose an empty folder for output";
showMessage(message);
obfsPath = getDirectory(message);
if (lengthOf(obfsPath) < 1){
	exit("Macro cancelled.");
}
obfsFilesInitial = getFileList(obfsPath);
nObfsFilesInitial = obfsFilesInitial.length;
if (nObfsFilesInitial > 0) {
	exit("Output folder not empty - aborting.");
}

// find input images, begin key.txt file
inputFiles = getFileList(inPath);
inputFiles = expandFolders(inputFiles, inPath);  // handle folders in input folder
nFiles = inputFiles.length;
obfsNames = newArray(nFiles);  // array to hold obfuscated image names
fkey = File.open(obfsPath + File.separator + "key.txt");  // open text file & get handle
print(fkey, "Created by Blind.ijm " + genTimeStamp());
print(fkey, " (obfuscated image files from: " + inPath + ")\n---\n");
print(fkey, "InputFilename,ObfuscatedFilename\n");

// loop through the open images, generate a random name and re-save 
setBatchMode(true);  // set batch mode for speed (windows not updated)
for (i = 0; i < nFiles; i++){
	realName = inputFiles[i];
	needNewName = true; 
	// keep generating random numbers until we have a unique new name
	while (needNewName) {
		randNo = d2s(random() * 10000, 0);
		obfsName = "image" + randNo + fileExt(realName);
		// NB. after 1st image, check if we've already used this number string!
        if (i == 0 || !namePresent(obfsName, obfsNames, i - 1)){
        	needNewName = false;
        	obfsNames[i] = obfsName;
        	// save key in key.txt file to decode later
        	outStr = realName + "," + obfsName;
        	print(fkey, outStr);
        	fromPath = inPath + File.separator + realName;
        	toPath = obfsPath + File.separator + obfsName;
        	File.copy(fromPath, toPath);
        }
	}
}

// finally
setBatchMode(false);
File.close(fkey);


// --- Function Definitions ---

function fileExt(filename) {
	// return the file extension of an input filename string
	dotIndex = lastIndexOf(filename, ".");
    if (dotIndex >= 0) {
	    return substring(filename, dotIndex);
    } else {
        return "";
    }
}

function namePresent(name, nameArray, imax) {
    // check whether a given name is already in the nameArray
	// searching for "name" in "nameArray" up to index "imax"
	for (ii = 0; ii <= imax; ii++){
	 	if (name == nameArray[ii]) {
	        return true;
		}
	}
	return false;
}

function genTimeStamp(){
	// define function to generate time stamp (seems harder than it should be!)
	MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	TimeString = DayNames[dayOfWeek] + " ";
	if (dayOfMonth < 10) {TimeString = TimeString + "0";}
	TimeString = TimeString + dayOfMonth + "-" + MonthNames[month] + "-" + year + " ";
	if (hour < 10) {TimeString = TimeString + "0";}
	TimeString = TimeString + hour + ":";
	if (minute < 10) {TimeString = TimeString + "0";}
	TimeString = TimeString + minute + ":";
	if (second < 10) {TimeString = TimeString + "0";}
	TimeString = TimeString + second;
	return TimeString;
}

function expandFolders(fileList, folder) {
	// return a fileList where entries that are folders have been expanded
	// - expand only 1 level, discarding any sub-sub-folders to prevent errors
	for (i = fileList.length - 1; i >=0 ; i--) {
		filePath1 = folder + File.separator + fileList[i];
		if (File.isDirectory(filePath1)) {
			subfolderName = fileList[i];
			// first remove subfolder from fileList
			fileList = Array.deleteIndex(fileList, i);
			// expand contents of subfolder to add to fileList
			moreFiles = getFileList(filePath1);
			for (j = moreFiles.length - 1; j >=0 ; j--) {
				filePath2 = filePath1 + File.separator + moreFiles[j];
				if (File.isDirectory(filePath2)) {
					// remove sub-sub-folders from "moreFiles" list
					moreFiles = Array.deleteIndex(moreFiles, j);
				} else {
					// add subfolder to front of filename
					moreFiles[j] = subfolderName + moreFiles[j];
				}
			}
			// now concatenate filtered "moreFiles" from subfolder onto fileList
			fileList = Array.concat(fileList, moreFiles);
		}
	}
	return fileList;
}
