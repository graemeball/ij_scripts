// Make_Blind.ijm: for blind analysis of image data sets
// Usage: - make sure all the images of interest are open and not stacked
//        - just run the macro and your obfuscated image files + key.txt 
//            will appear in your directory of choice
// Author: graemeball@googlemail.com, Micron Oxford (2013)
// License: Public Domain (CC0)

// check we have some images open, and get path to save obfuscated image files
if (nImages<1){
	exit("Error: no images are open.");
}
obfsPath = getDirectory("Choose a directory for output");
if (lengthOf(obfsPath)<1){
	exit("Macro cancelled.");
}

// initialize variables, open file handles etc.
obfsNames = newArray(nImages);  // array to hold obfuscated image names
fkey = File.open(obfsPath+"key.txt");  // open text file & get handle
setBatchMode(true);  // set batch mode for speed (windows not updated)

// write some info to the "key" file
info1 = "created by makeBlind.ijm "+genTimeStamp();
info2 = " obfuscated image files written to: "+obfsPath+"\n\n";
print(fkey,info1);
print(fkey,info2);

// loop through the open images, generate a random name and re-save 
for (i=0; i < nImages; i++){
	selectImage(i+1); // count from 1
	needNewName = true; 
	// keep generating random numbers until we have a unique new name
	while (needNewName){
		randNo = d2s(random()*10000,0);
		obfsName = "image"+randNo+".tif";
		// NB. after 1st image, check if we've already used this number string!
        if (i == 0 || !namePresent(obfsName, obfsNames, i - 1)){
        	needNewName = false;
        	origName = getInfo("image.filename");
        	obfsNames[i] = obfsName;
        	// save key in key.txt file to decode later
        	outStr = origName+" = "+obfsName+"; original file from:"+getInfo("image.directory");
        	print(fkey, outStr);
        	obfsName = obfsPath+obfsName;
        	saveAs("tiff", obfsName);
        }
	}
}

// finally
setBatchMode(false);
File.close(fkey);


// Function Definitions

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
