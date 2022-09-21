// Label_mask.ijm: ImageJ macro to convert a binary mask into a label image
// Usage: runs on active image
// - assumes input single slice 8-bit binary image (=> max 255 objects)
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2022)
// License: MIT license


run("Select None");
roiManager("reset");

minSize = 0;
circ = "0.10-1.00";
size = "" + minSize + "-Infinity";

setBatchMode("hide");
setThreshold(1, 255, "raw");
run("Analyze Particles...", "size=" + size + "  circularity=" + circ + " show=Nothing clear include add");

nObjects = roiManager("count");
for (i = 0; i < nObjects; i++) {
	roiManager("deselect");
	roiManager("select", i);
	labelValue = i+1;
	run("Set...", "value=" + labelValue);
	run("Select None");
}
run("Remove Overlay");
run("glasbey on dark");
setBatchMode("exit and display");

