// ImageJ1 macro to automatically segment cytoplasm and count spots
// Graeme Ball (November 2013), Micron Oxford

// get the image title and set parameters
imageName = getTitle();
particleDiameterMin = 4;   // minimum particle diameter in pixels
particleDiameterMax = 20;  // maximum particle diameter in pixels
cellSizeMin = 20000;       // minimum cell area in pixels^2
cellSizeMax = 300000;      // maximum cell area in pixels^2
thresholdStdevs = 0.75;     // threshold for particle detection, using threshold = 
                           //   background_average + (background_standard_deviation * thresholdStdevs)
smoothRadius = 8;          // dilate then erode by this number of pixels to smooth outline


// auto-threshold and create one ROI per. cell, adding to roiManager
run("Duplicate...", "title=mask");
bandpassMin = particleDiameterMax;
bandpassMax = sqrt(cellSizeMin);
run("Bandpass Filter...", "filter_large=" + bandpassMax + " filter_small=" + bandpassMin +
    " suppress=None tolerance=5 autoscale saturate");
setAutoThreshold("Triangle dark");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Options...", "iterations=" + smoothRadius + " count=1 black edm=Overwrite do=Nothing");
run("Dilate");
run("Erode");
//run("Fill Holes");
if (roiManager("count") > 0) {
    roiManager("reset");
}
setThreshold(1, 255);
run("Analyze Particles...", "size=" + cellSizeMin + "-" + cellSizeMax +
    " pixel circularity=0.00-1.00 show=Nothing display clear include add");
close();

// filter the raw data for particle detection (based on expected size)
filteredImageName = "FLT_" + imageName;
selectWindow(imageName);
run("Duplicate...", "title=" + filteredImageName);
//run("Enhance Local Contrast (CLAHE)", "blocksize=127 histogram=256 maximum=3 mask=*None* fast_(less_accurate)");
run("Bandpass Filter...", "filter_large=" + particleDiameterMax + " filter_small=" +
    particleDiameterMin + " suppress=None tolerance=5 autoscale saturate");

// count particles in each cell
selectWindow(filteredImageName);
nCells = roiManager("count");
roiManager("deselect");
partiCounts = newArray(nCells);
for (i = 0; i < nCells; i++) {
    roiManager("select", i);
    roiManager("rename", "cell" + i);
    getStatistics(area, std);
    particleThresh = std * thresholdStdevs;
    run("Find Maxima...", "noise=" + particleThresh + " output=[Point Selection]");
    getSelectionCoordinates(xCoords, yCoords);
    nParticles = xCoords.length;
    //print("Roi" + i + ", nParticles=" + nParticles + "(thresh=" + particleThresh + ")");
    partiCounts[i] = nParticles;
    roiManager("add");
    roiManager("select", roiManager("count") - 1);
    roiManager("rename", "particles" + i);
}
//close();
//selectWindow(imageName);

// report particle counts in Results table window
run("Clear Results"); 
for(i=0; i< partiCounts.length; i++) { 
    setResult("Cell", i, i); 
    setResult("nParticles", i, partiCounts[i]); 
}
