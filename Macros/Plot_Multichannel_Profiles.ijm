// ImageJ Macro to plot line profiles for all channels using current line/rectangle selection
//
// Copyright g.ball@dundee.ac.uk (2019) Dundee Imaging Facility
// License: Creative Commons CC-BY-SA
//

macro "Plot Multichannel Profiles [K]" {
	// macro to plot line profiles for all channels using current line selection
	// - requires function hexColor()
	inpID = getImageID();
	st = selectionType();
	if (st == 0 || st == 5 || st == 6 || st == 7) {
		getDimensions(w, h, nc, nz, nt);
		setBatchMode("hide");
		if (nc > 1) {
			Stack.setDisplayMode("composite");  // for color LUTs
			colors = newArray();  // array for hex color strings
			yValues = newArray();  // array for all y values for all channels
			for (channel = 1; channel <= nc; channel++) {
				Stack.setChannel(channel);
				getLut(R, G, B);
				colorString = hexColor(R[R.length-1], G[G.length-1], B[B.length-1]);
				colors = Array.concat(colors, colorString);
				run("Plot Profile");
				Plot.getValues(xvals, yvals);
				yValues = Array.concat(yValues, yvals);
				close();
			}
			nPoints = xvals.length;
			Plot.create("Multichannel Line Profile", "Distance (pixels)", "Gray Value");
			for (c = 1; c <= nc; c++) {
				Plot.setColor(colors[c-1]);
				offset = (c-1) * nPoints;
				yvals = Array.slice(yValues, offset, offset+nPoints-1);
				Plot.add("line", xvals, yvals);
			}
			Plot.setLimitsToFit();
			selectImage(inpID);
			Stack.setChannel(1);
		} else {
			// just 1 channel so run Plot Profile command
			run("Plot Profile");
		}
		setBatchMode("exit and display");	
	} else {
		showMessage("Plot Multichannel Profiles", "Line or rectangular selection required");
	}
}

function hexColor(redValue, greenValue, blueValue) {
	// convert color from 0-255 triple format to hex string format "#XXYYZZ"
	rHex = toHex(redValue);
	gHex = toHex(greenValue);
	bHex = toHex(blueValue);
	if (lengthOf(rHex) < 2) {
		rHex = "0" + rHex;
	}
	if (lengthOf(gHex) < 2) {
		gHex = "0" + gHex;
	}
	if (lengthOf(bHex) < 2) {
		bHex = "0" + bHex;
	}
	colorString = "#" + rHex + gHex + bHex;
	return colorString;
}