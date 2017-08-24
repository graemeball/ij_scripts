// Make_Blind_Folder.ijm: for blind analysis of image data sets
// Usage: - select an input folder of images
//        - select a new name for an output folder of obfuscated image files 
//        - a key.txt file is written to output folder
//        - a filelist.txt file is written to output folder
//          (i.e. list of obfusated file names in same order as key)
//        - supports up to ~1000 input files
// Author: graemeball@googlemail.com, Dundee Imaging Facility (2017)
// License: Public Domain (CC0)


// get input folder and list of image files
inFolder = getDirectory("Choose a folder of files to obfuscate");
parentFolder = File.getParent(inFolder);
inName = File.getName(inFolder);
files = getFileList(inFolder);

// get output folder name & create output folder
outName = getString("Choose a name for the output folder", inName + "_blind");
outFolder = parentFolder + File.separator + outName
if (File.exists(outFolder)) {
	exit("Output folder already exists!");
}
File.makeDirectory(outFolder);

// create key.txt & get handle
keyPath = outFolder + File.separator + "key.txt";
fkey = File.open(keyPath);
print(fkey, "# created by Make_Blind_Folder.ijm " + genTimeStamp());
print(fkey, "# files from input folder: " + inFolder);


// loop through files in input folder, copying to random name in output folder
obfsNames = newArray(files.length);
keyLines = newArray(files.length);
for (i = 0; i < files.length; i++) {
	needNewName = true; 
	// keep generating random numbers until we have a unique new name
	while (needNewName) {
		origName = files[i];
		ext = substring(origName, lastIndexOf(origName, "."), lengthOf(origName));
		randNo = d2s(random() * 10000, 0);
		obfsName = randNo + ext;
		// NB. after 1st image, check if we've already used this number string!
        if (i == 0 || !namePresent(obfsName, obfsNames, i - 1)){
        	needNewName = false;
        	obfsNames[i] = obfsName;
        	// save list of new names and key to decode later
        	keyLine = obfsName + "," + origName;
        	keyLines[i] = keyLine;
        	obfsPath = outFolder + File.separator + obfsName;
        	File.copy(inFolder + File.separator + origName, obfsPath);
        }
	}
}

// finally, sort new names to scramble then write key & new filename list
Array.sort(keyLines);
for (i = 0; i < keyLines.length; i++) {
	print(fkey, keyLines[i]);
}
File.close(fkey);
Array.sort(obfsNames);
listPath = outFolder + File.separator + "filelist.txt";
flist = File.open(listPath);
for (i = 0; i < obfsNames.length; i++) {
	print(flist, obfsNames[i]);
}
File.close(flist);


// --- Helper Function Definitions ---

function namePresent(name, nameArray,imax) {
    // check whether a given name is already in the nameKey array
	// searching for "name" in "nameArray" up to index "imax"
	for (ii = 0; ii <= imax; ii++){
	 	if (name == nameArray[ii]) {
	        return true;
		}
	}
	return false;
}

// define function to generate time stamp -- seems harder than it should be
function genTimeStamp(){
	MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
	getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	TimeString = DayNames[dayOfWeek]+" ";
	if (dayOfMonth<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+dayOfMonth+"-"+MonthNames[month]+"-"+year+" ";
	if (hour<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+hour+":";
	if (minute<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+minute+":";
	if (second<10) {TimeString = TimeString+"0";}
	TimeString = TimeString+second;
	return TimeString;
}
