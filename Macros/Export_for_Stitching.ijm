// ImageJ macro to arrange data for Grid/Collection Stitching plugin:
//   split tiled image hyperstack (tile=frame) into 1 multi-channel 
//   stack per tile & save resulting stacks as .tif files in a folder.
// Graeme Ball, Micron Oxford 2013


// assuming 1 empty folder exists for stitching input (& 1 for output)
dir = getDirectory("Choose an empty folder to save .tifs for stitching input");

title = getTitle();
getDimensions(width, height, channels, slices, frames);
nTifs = slices * frames;

// split hyperstack into multi-channel tif stacks, one per tile
setBatchMode(true);
run("Stack Splitter", "number=" + nTifs);
for (i = 0; i < nTifs; i++) {
	substackName = "stk_" + sliceString(i + 1, 4) + "_" + title;
	selectWindow(substackName);
	run("Stack to Hyperstack...", "order=xyczt(default) channels=" + channels + " slices=1 frames=1");
	saveAs("Tiff", dir + substackName + ".tif");
	close();
}
setBatchMode(false);


// ** function definitions **

// convert integer to string padded with zeros, total length nChar
function sliceString(num, nChar) {
	if (num > 9999) {
		exit("sliceString(): Number " + num + " too large for " + nChar + " characters"); 
	}
	numString = toString(num);
	if (num < 10) {
		numString = "000" + numString;
	} else if (num < 100) {
		numString = "00" + numString;
	} else if (num < 1000) {
		numString = "0" + numString;
	} else {
		numString = numString;
	}
	return numString;
}
