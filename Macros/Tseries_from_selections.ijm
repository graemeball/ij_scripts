// Tseries_from_selections.ijm ImageJ macro
//
// Prompt user to define selection for each timepoint of interest
//  - uses active image
//  - requires identically sized rectangular selection for each T of interest
//  - generates a cropped (i.e. position-stabilized) time series
//
// Author: Graeme Ball (g.ball@dundee.ac.uk)
// Copyright: Dundee Imaging Facility (2022)
// License: MIT license
//

inputID = getImageID();
inputTitle = getTitle();
working = true;
firstTimepoint = true;

while (working) {
	if (firstTimepoint) {
		xywhczt1 = getCropBoxCoords1();
		xywhczt = xywhczt1;
		print("first crop box at xywhczt:");
		Array.print(xywhczt);
		box = Array.slice(xywhczt, 0, 4);  // crop box size to use in subsequent frames
		firstTimepoint = false;
		// generate new crop image as starting point for crop series/stack
		run("Duplicate...", " ");
		cropStackID = getImageID();
		rename("cropStack");
		Property.setSliceLabel("crop" + roiInfoString(xywhczt), 1);
		selectImage(inputID);	
	} else {
		Stack.getPosition(channel, slice, frame);
		// ask user if this is the last timepoint of interest
		Dialog.createNonBlocking("Create series from selection");
		Dialog.addMessage("Adjust ROI, frame " + frame);
		FrameIsFinal = newArray("No", "Yes");
		Dialog.addRadioButtonGroup("Final timepoint?", FrameIsFinal, 1, 2, "No");
		Dialog.show();
		frameFinal = Dialog.getRadioButton();
		// ensure selection is correct size at correct T
		WHrequired = newArray(box[2], box[3]);
		xywhczt = getCropBoxCoords2toN(WHrequired, Trequired);
		print("crop box at xywhczt:");
		Array.print(xywhczt);
		cropSliceName = "crop" + roiInfoString(xywhczt);
		cropStackID = concatenateROItoStack(cropSliceName, cropStackID);
		selectImage(inputID);
		if (frameFinal == "Yes") {
			working = false;
		}
	}
	if (working) {
		// try to step to next T unless finished
		Trequired = xywhczt[6] + 1;
		Stack.getDimensions(width, height, channels, slices, frames);
		if (Trequired > frames) {
			showMessage("No more timepoints - stopping");
			working = false;
		} else {
			// draw ROI at same position as last frame 
			Stack.setPosition(xywhczt[4], xywhczt[5], Trequired);
			makeRectangle(box[0], box[1], box[2], box[3]);
		}
	}	
}
selectImage(cropStackID);
rename(makeCropTitle(inputTitle, xywhczt1));


// --- define functions ---
function getCropBoxCoords1() {
	// return array of x,w,w,h,C,Z,T position for cropping (1st timepoint with ROI check)
	//   requires getCropBoxCoords()
	while (selectionType() != 0) {
		waitForUser("Make a rectangular selection at first T/position for crop series");
	}
	xywhczt = getCropBoxCoords();
	return xywhczt;
}

function getCropBoxCoords() {
	// return array of x,w,w,h,C,Z,T position for cropping
	getBoundingRect(x, y, width, height);		
	Stack.getPosition(channel, slice, frame);
	return newArray(x, y, width, height, channel, slice, frame);
}

function getCropBoxCoords2toN(wh, T) {
	// return array of x,w,w,h,C,Z,T position for cropping (2..n timepoint with ROI check)
	//   requires getCropBoxCoords(), array_all()
	Stack.getPosition(channel, slice, frame);
	xywhczt = getCropBoxCoords();
	while (selectionType() != 0 || xywhczt[6] != T || !array_all(Array.slice(xywhczt,2,4), wh)) {
		message = "";
		if (selectionType() != 0) {
			message = message + "Make a rectangular selection ";
		}
		if (!array_all(Array.slice(xywhczt,2,4), wh)) {
			message = message + "ROI size sould be w=" + wh[0] + ",h=" + wh[1] + " ";
		}
		if (frame != T) {
			message = message + "T=" + T + " is next";
		}
		waitForUser(message);
		xywhczt = getCropBoxCoords();
	}
	return xywhczt;
}

function makeCropTitle(inputTitle, xywhczt) {
	// generate title for crop image series/stack using crop box info at first T
	//   requires baseName(), roiInfoString()
	return "" + baseName(inputTitle) + "_CropSeriesAt" + roiInfoString(xywhczt);
}

function baseName(filename) {
    // return filename string without extension
    if (lastIndexOf(filename, ".") > 0) {
    	return substring(filename, 0, lastIndexOf(filename, "."));
    } else {
		return filename;  // no .extension!
    }
}

function array_all(arr1, arr2) {
	// return true if all contents of two arrays are equal (N.B. false if length unequal!)
	if (arr1.length != arr2.length) {
		return false;
	} else {
		allEqual = true;
		for (i = 0; i < arr1.length; i++) {
			if (arr1[i] != arr2[i]) {
				allEqual = false;
				i = arr1.length;  // BREAK (short circuit to save time)
			}
		}
		return allEqual;
	}
}

function concatenateROItoStack(cropSliceName, cropStackID) {
	// duplicate active selection and concatenate onto stack with given ID
	//  name slice according to cropSliceName
	run("Duplicate...", " ");
	rename("cropSlice");
	run("Concatenate...", "open image1=cropStack image2=cropSlice image3=[-- None --]");
	rename("cropStack");
	Property.setSliceLabel(cropSliceName, nSlices());
	cropStackID = getImageID();
	return cropStackID;
}

function roiInfoString(xywhczt) {
	// return string showing roi position+size info
	x = xywhczt[0];
	y = xywhczt[1];
	w = xywhczt[2];
	h = xywhczt[3];
	c = xywhczt[4];
	z = xywhczt[5];
	t = xywhczt[6];
	return "X" + x + "Y" + y + "W" + w + "H" + h + "C" + c + "Z" + z + "T" + t;
}
