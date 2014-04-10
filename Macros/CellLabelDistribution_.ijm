// Quantify label intensity in different cell regions
// - takes a multi-channel image (hyperstack)
// - specify channels for nucleus, membrane, and label of interest
//
// Copyright Graeme Ball (2013), graemeball@gmail.com
// Creative Commons Attribution License (CC BY 3.0)
//
// Details:
// - calculates proportion of total intensity in:-
//   - nucleus
//   - membrane
//   - cytoplasm (i.e. neither nucleus nor membrane)
// - uses autothresholding (Otsu) to define nucleus & membrane regions
// - assumes all above-background signal is nucleus, membrane or cytoplasm
// - reports signal in each region after background subtraction
// - converts original image into hyperstack of mask images used for inspection

batch = true;          // for batch true, report to Result table only
cNucleus = 1;          // channel marking nucleus
cMembrane = 2;         // channel marking membrane
cLabel = 3;            // label / signal of interest to be quantified
background = 15;       // background in label channel (non-specific stain, autofluoresc.)

// --- do not edit below! ---

hyperstackName = getTitle();
getDimensions(width, height, channels, slices, frames); // used globally!

if (batch) {
    setBatchMode(true);     // avoid window updates for speed
    outputRow = nResults;
    setResult("filename", outputRow, hyperstackName);
} else {
    Dialog.create("Cell Label Distribution");
    Dialog.addNumber("Nucleus channel no", cNucleus);
    Dialog.addNumber("Membrane channel no", cMembrane);
    Dialog.addNumber("Label channel no", cLabel);
    Dialog.addNumber("Label background estimate", background);
    Dialog.show();
    cNucleus = Dialog.getNumber();
    cMembrane = Dialog.getNumber();
    cLabel = Dialog.getNumber();
    background = Dialog.getNumber();
}

singleChannelStacks = splitChannels(hyperstackName);
for (c = 1; c <= channels; c++) {
	if (c != cNucleus && c != cMembrane && c != cLabel) {
		selectWindow(singleChannelStacks[c - 1]);
		close();  // close unused channels
	}
}

run("Options...", "iterations=1 count=1 black edm=Overwrite");
selectWindow(singleChannelStacks[cNucleus - 1]);
setAutoThreshold("Otsu dark stack");
run("Convert to Mask", "black");
rename("nucleusMask");

selectWindow(singleChannelStacks[cMembrane - 1]);
setAutoThreshold("Otsu dark stack");
run("Convert to Mask", "black");
rename("membraneMask");

stackCopy(singleChannelStacks[cLabel - 1]);
setAutoThreshold("Otsu dark stack");
getThreshold(labelLower, labelUpper);
setThreshold(background, labelUpper);
run("Convert to Mask", "black");
rename("labelMask");

imageCalculator("Subtract create stack", "labelMask", "nucleusMask");
cytoplasmAndMembrane = getTitle();
imageCalculator("Subtract create stack", cytoplasmAndMembrane, "membraneMask");
rename("cytoplasmMask");

selectWindow(cytoplasmAndMembrane);
close();

//waitForUser;

labelStack = singleChannelStacks[cLabel - 1];
rawNuclearSignal = totalMaskedIntensity(labelStack, "nucleusMask");
nNuclearPixels = totalMaskedIntensity("nucleusMask", "nucleusMask") / 255;
nuclearSignal = rawNuclearSignal - background * nNuclearPixels;

rawMembraneSignal = totalMaskedIntensity(labelStack, "membraneMask");
nMembranePixels = totalMaskedIntensity("membraneMask", "membraneMask") / 255;
membraneSignal = rawMembraneSignal - background * nMembranePixels;

rawCytoplasmSignal = totalMaskedIntensity(labelStack, "cytoplasmMask");
nCytoplasmPixels = totalMaskedIntensity("cytoplasmMask", "cytoplasmMask") / 255;
cytoplasmSignal = rawCytoplasmSignal - background * nCytoplasmPixels;

selectWindow(labelStack);
close();

// create a hyperstack of mask images for examination
run("Merge Channels...", "c1=nucleusMask c2=membraneMask c3=cytoplasmMask c4=labelMask create");
outputStack = "C1nucleus_C2membrane_C3cytoplasm_C4label";
rename(outputStack);
Stack.setDisplayMode("grayscale");

if (batch) {
    setResult("Nuclear signal", outputRow, nuclearSignal);
    setResult("Nuclear vol (pix)", outputRow, nNuclearPixels);
    setResult("Membrane signal", outputRow, membraneSignal);
    setResult("Membrane vol (pix)", outputRow, nMembranePixels);
    setResult("Cytoplasm signal", outputRow, cytoplasmSignal);
    setResult("Cytoplasm vol (pix)", outputRow, nCytoplasmPixels);
} else {
    print("raw nuclear signal = " + rawNuclearSignal);
    print("nuclear volume (pix) = " + nNuclearPixels);
    print("background-corrected nuclear signal = " + nuclearSignal);    
    print("total membrane signal = " + rawMembraneSignal);
    print("nuclear membrane (pix) = " + nMembranePixels);
    print("background-corrected membrane signal = " + membraneSignal);
    print("total cytoplasm signal = " + rawCytoplasmSignal);
    print("cytoplasm volume (pix) = " + nCytoplasmPixels);
    print("background-corrected cytoplasm signal = " + cytoplasmSignal);
}

// --- helper function definitions --

// split hyperstack into 1 stack per channel
// return array of new image titles
function splitChannels(hyperstackName) {
    selectWindow(hyperstackName);
    //getDimensions(width, height, channels, slices, frames);
    run("Split Channels");
    titles = newArray(channels);
    for (c = 1; c <= channels; c++) {
         titles[c - 1] = "C" + c + "-" + hyperstackName;
    }
    return titles;
}

// duplicate a stack (assumes XYZ only)
function stackCopy(inStackName) {
    selectWindow(inStackName);
    run("Duplicate...", "title=" + inStackName + " duplicate range=1-" + slices);
}

// for a sample and mask stack, return total sample intensity in masked region
function totalMaskedIntensity(sample, mask) {
    maskedSampleTotal = 0.0;
    for (s = 1; s <= slices; s++) {
        selectWindow(mask);
        setSlice(s);
        run("Duplicate...", "title=maskSlice");
        run("Select All");
        selectWindow(sample);
        setSlice(s);
        run("Duplicate...", "title=sampleSlice");
        imageCalculator("Multiply create 32-bit", "sampleSlice", "maskSlice");
        selectWindow("Result of sampleSlice");
        getRawStatistics(nPixels, mean, min, max, std, histogram);
        sampleTotal = nPixels * mean;
        maskedSampleTotal += sampleTotal / 255;
        selectWindow("maskSlice");
        close();
        selectWindow("sampleSlice");
        close();
        selectWindow("Result of sampleSlice");
        close();
    }
    return maskedSampleTotal;
}
