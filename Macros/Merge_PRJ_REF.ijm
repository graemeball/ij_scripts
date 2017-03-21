// Macro to merge pairs of .dv images, a multi-channel PRJ and a REF image
// Saves a single ImageJ _merge.tif file for each merged pair
//
// Graeme Ball (g.ball@dundee.ac.uk), 2017
// Creative Commons CC-BY
//

dir = getDirectory("Choose folder containing pairs of PRJ and REF images");
files = getFileList(dir)

prjFiles = newArray();
refFiles = newArray();


run("Bio-Formats Macro Extensions");
// -- start macro (batch mode) ---
setBatchMode(true);
// create arrays of PRJ and  REF filenames
for (f = 0; f < files.length; f++) {
	thisFile = files[f];
	if (matches(thisFile, ".*PRJ.dv")) {
		prjFiles = Array.concat(prjFiles, thisFile);	
	} else if (matches(thisFile, ".*REF.dv")) {
		refFiles = Array.concat(refFiles, thisFile);	
	}
}

// search for pairs of PRJ and matching REF images and do merge
for (i = 0; i < prjFiles.length; i++) {
	prj = prjFiles[i];
	base = substring(prj, 0, lastIndexOf(prj, "_D3D_PRJ.dv"));
	for (j = 0; j < refFiles.length; j++) {
		ref = refFiles[j];
		base2 = substring(ref, 0, lastIndexOf(ref, "_REF.dv"));
		if (base == base2) {
			print("merging " + prj + " and " + ref);
			mergePrjRef(prj, ref);
		}
	}
}
setBatchMode(false);
// --- end macro ---


function mergePrjRef(prj, ref) {
	// merge a pair of PRJ and REF .dv images
	// assumes PRJ is 2-channel, C1=green, C2=red; REF is gray
	// this function uses global "dir" variable
	run("Bio-Formats Windowless Importer", "open=" + dir + File.separator + prj);
	//open(dir + File.separator + prj);
	run("Split Channels");
	run("Bio-Formats Windowless Importer", "open=" + dir + File.separator + ref);
	//open(dir + File.separator + ref);	
	run("32-bit");  // convert REF image to 32-bit to match PRJ (sum projn!)
	c1title = "C2-" + prj;
	c2title = "C1-" + prj;
	run("Merge Channels...", "c1=" + c1title + " c2=" + c2title + " c4=" + ref + " create");
	base = substring(ref, 0, lastIndexOf(ref, "_REF.dv"));
	save(dir + File.separator + base + "_merge.tif");
	close();
}
