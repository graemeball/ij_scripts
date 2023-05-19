// MRE_no_ROI_labels_in_Results.ijm
// Analyze particles does not show ROI label in Results (Fiji/ImageJ 1.53t)
//  with "display" label option in Analyze>Set Measurements
//  and "UseNames" in roiManager

run("Fresh Start");
run("Set Measurements...", "area mean centroid display redirect=None decimal=3");  // "display" to add Label to Results
roiManager("UseNames", "true");  // use ROI name as Label
// => expecting to see ROI name in "Label" column in Results!

run("Blobs (25K)");
setOption("BlackBackground", true);
setAutoThreshold("Default");
run("Convert to Mask");
run("Analyze Particles...", "size=100-Infinity show=Overlay display add");

showMessage("Here we see 'blobs.gif' image name in 'Label' column :-(");

showMessage("Instead I was expecting / hoping to see ROI label in 'Label' column like this...");
updateLabelValuesWithROInames();
updateResults();

showMessage("Also note that Analyze>Measure shows ImageName:RoiName which is better than 'Analyze Particles'");
roiManager("select", 42);
run("Measure");


// --- function definitions ---
function updateLabelValuesWithROInames() {
	// update 'Label' column in Results with ROI labels from manager
	// N.B. this function assumes all ROI indices match all Results row numbers!
	for (i = 0; i < nResults; i++) {
		roiManager("select", i);
		setResult("Label", i, Roi.getName());
	}
}
