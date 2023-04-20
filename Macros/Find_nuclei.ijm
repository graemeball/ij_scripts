// Demo_find_nuclei_CLIJ2.ijm - ImageJ macro to demontstrate using CLIJ2 to find nuclei
// Performs resampling to isotropic voxel size prior to CLIJ2 detection.
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2023)
// License: MIT license
//

// parameters for nucleus detection
cell_size_microns = 8;  // nucleus size assumed to be 0.5x cell_size
DOG_SIGMA2_SCALE = 3;   // sigma2 = sigma1*DOG_SIGMA2_SCALE
N_STD_BLOB_THRESH = 2;  // number of stdDev above mean for DoG-filtered image threshold 

// load test image
run("First-instar brain (6.3MB)");

// convert to RGB stack 
run("RGB Stack");

// set guesstimated pixel sizes (large nuclei ~10um?)
szXY = 1.33;
szZ = 2.86;
Stack.setXUnit("micron");
run("Properties...", "pixel_width=" + szXY + " pixel_height=" + szXY + " voxel_depth=" + szZ);

// resample for isotropic 3D voxel size
resampleIsotropic(getTitle);

// duplicate DAPI channel for detection
run("Duplicate...", "duplicate channels=3");

// detect nuclei using CLIJ2
run("CLIJ2 Macro Extensions", "cl_device=");
Ext.CLIJ2_clear();
nucImage = getTitle();
sigma1 = cell_size_microns / 4;  // sigma1 ~0.5x nucleus size, nucleus ~0.5x cell size
sigma2 = sigma1*DOG_SIGMA2_SCALE;
toUnscaled(sigma1);
toUnscaled(sigma2);
Ext.CLIJ2_push(nucImage);
Ext.CLIJ2_differenceOfGaussian3D(nucImage, nucBlobs, sigma1, sigma1, sigma1, sigma2, sigma2, sigma2);
Ext.CLIJ2_statisticsOfImage(nucBlobs);
std = getResult("STANDARD_DEVIATION_INTENSITY", nResults-1);
mean = getResult("MEAN_INTENSITY", nResults-1);
Ext.CLIJ2_pull(nucBlobs);
rename("nucBlobs");
blobThreshold = mean + N_STD_BLOB_THRESH*std;
print("blobThreshold=" + blobThreshold);
run("Min...", "value=" + blobThreshold + " stack");  // clip low intensities prior to peak detection (in-place)
nucBlobsThresholded = getTitle();
Ext.CLIJ2_push(nucBlobsThresholded);
nuc_radius = cell_size_microns / 4;
print("sigma1=" + sigma1 + ", sigma2=" + sigma2);
toUnscaled(cell_radius);
Ext.CLIJ2_detectMaxima3DBox(nucBlobsThresholded, nucSpotMask, cell_radius, cell_radius, cell_radius);
Ext.CLIJ2_pull(nucSpotMask);
rename("nucSpotMask");


// --- function definitions ---

function resampleIsotropic(inputTitle) {
	// resample a (hyper)stack to give isotropic voxels and return output title
	//   assumes Z spacing >= XY pixel size; uses bilinear interpolation
	getVoxelSize(w, h, d, unit);
	if (d > w && d > h) {
		ds = 1;
		ws = w / d;
		hs = h / d;
	} else {
		exit("Expected Z spacing >= XY pixel size");
	}
	getDimensions(width, height, nc, nz, nt);
	if (nc > 1) {
		interp_opts = "Bilinear average create";
	} else {
		interp_opts = "Bilinear average process create";
	}
	run("Scale...", "x=" + ws + " y=" + hs + " z=" + ds + " interpolation=" + interp_opts);
	outputTitle = "isotropic_" + inputTitle;
	rename(outputTitle);
	return outputTitle;
}