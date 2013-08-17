// IJ macro for blind analysis of image data sets
//  Usage: - make sure all the images of interest are open and not stacked
//         - just run the macro and your obfuscated image files + key.txt 
//            will appear in your directory of choice
//  questions or comments to: graeme.ball@bioch.ox.ac.uk


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
for (i=0; i<nImages; i++){
	// select an image to generate a new name for
	selectImage(i+1);  // NB. image IDs always count from 1 to nImages. simples
	needNewName = 1;  // 1 means we still need to generate a new name (state)
	// keep generating random numbers until we have a unique new name
	while (needNewName){
		randNo = d2s(random()*10000,0);  // generate random number string 
		obfsName = "image"+randNo+".tif";
		// after 1st image, check if we've already used this number string!
        	if ( i==0 || !namePresent(obfsName,obfsNames,i-1) ){
          		needNewName = 0;  // if name is not present, we're done
          		origName = getInfo("image.filename");  // get the original name
          		// store the obfuscated name in obfsNames array
          		obfsNames[i] = obfsName;
          		// save key in key.txt file for later interpretation of blind analysis results
          		outStr = origName+" = "+obfsName+"; original file from:"+getInfo("image.directory");
          		print(fkey,outStr);
          		// write out this image under the obfuscated filename
          		obfsName = obfsPath+obfsName;
          		saveAs("tiff",obfsName);
        	}
	}
        
}


// finally
setBatchMode(false);  // come back out of batch mode
File.close(fkey);  // close text file

// define function to check whether a given name is already in the nameKey array
function namePresent(name,nameArray,imax) {
	// searching for "name" in "nameArray" up to index "imax"
	for (ii=0; ii<=imax; ii++){
	 	if (name==nameArray[ii]) {
	      		return 1;  // return once we find it
		}
	}
	return 0;  // return 0 if we didn't find it
}

// define function to generate time stamp (FFS, WHY is this so hard?)
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
