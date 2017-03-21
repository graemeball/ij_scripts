// Extract_ROI_props.ijm
// - from each ROI's name property, extract value after final comma
//
// graemeball@gmail.com, Creative Commons CC0

run("Clear Results");
roiManager("reset");
run("To ROI Manager");
nRois = roiManager("count");
for (i = 0; i < nRois; i++) {
	roiManager("select", i);
	rawName = Roi.getName();
	commaIndex = lastIndexOf(rawName, ",");
	if (commaIndex > -1) {
		roiName = substring(rawName, 0, commaIndex);
		roiValue = substring(rawName, (commaIndex + 1));
	} else {
		roiName = rawName;
		roiValue = "";
	}
	row = nResults;
	setResult("roiName", row, roiName);	
	Roi.getBounds(x, y, w, h);	
	setResult("x", row, x);
	setResult("y", row, y);
	setResult("width", row, w);
	setResult("height", row, h);
	// N.B. alternative: pos = eval("js","IJ.getImage().getRoi().getPosition()");
	Stack.getPosition(c, z, t);
	setResult("time", row, t);
	setResult("roiValue", row, roiValue);
}
