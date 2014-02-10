// Quantify label intensity in different cell regions
// - takes a multi-channel image (hyperstack)
// - specify channels for nucleus, membrane, and label of interest
//
// Details:
// - calculates proportion of total intensity in:-
//   - nucleus
//   - membrane
//   - cytoplasm (i.e. neither nucleus nor membrane)
// - uses autothresholding (Otsu)
// - for the label, subtracts background in non-marker ROI after dilate 30
// - destructive: splits the input stack and closes these windows when done 

cleanup = false;  // close all image windows created when done
setBatchMode(false);  // avoid window updates for speed

hyperstackName = getTitle();
getDimensions(width, height, channels, slices, frames); // used globally!
if (channels < 3) {
    exit("Cell Label Distribution Macro requires 3+ channels");
}

Dialog.create("Cell Label Distribution");
Dialog.addNumber("Nucleus channel no", 1);
Dialog.addNumber("Membrane channel no", 2);
Dialog.addNumber("Label channel no", 3);
Dialog.show();
cNucleus = Dialog.getNumber();
cMembrane = Dialog.getNumber();
cLabel = Dialog.getNumber();

singleChannelStacks = splitChannels(hyperstackName);
for (c = 1; c <= channels; c++) {
	if (c != cNucleus && c != cMembrane && c != cLabel) {
		selectWindow(singleChannelStacks[c - 1]);
		close();  // close unused channels
	}
}

run("Options...", "iterations=1 count=1 black edm=Overwrite");
selectWindow(singleChannelStacks[cNucleus - 1]);
run("Convert to Mask", "method=Otsu background=Dark black");
rename("nucleusMask");
selectWindow(singleChannelStacks[cMembrane - 1]);
run("Convert to Mask", "method=Otsu background=Dark black");
rename("membraneMask");
stackCopy(singleChannelStacks[cLabel - 1]);
run("Convert to Mask", "method=Otsu background=Dark black");
rename("labelMask");
imageCalculator("Subtract create stack", "labelMask", "nucleusMask");
cytoplasmAndMembrane = getTitle();
imageCalculator("Subtract create stack", cytoplasmAndMembrane, "membraneMask");
rename("cytoplasmMask");
selectWindow(cytoplasmAndMembrane);
close();
background = estimateBackground(singleChannelStacks[cLabel - 1], 30);
print("average background level = " +  background);
labelStack = singleChannelStacks[cLabel - 1];
rawNuclearSignal = totalMaskedIntensity(labelStack, "nucleusMask");
nNuclearPixels = totalMaskedIntensity("nucleusMask", "nucleusMask") / 255;
nuclearSignal = rawNuclearSignal - background * nNuclearPixels;
print("raw nuclear signal = " + rawNuclearSignal);
print("background-corrected nuclear signal = " + nuclearSignal);
rawMembraneSignal = totalMaskedIntensity(labelStack, "membraneMask");
nMembranePixels = totalMaskedIntensity("membraneMask", "membraneMask") / 255;
membraneSignal = rawMembraneSignal - background * nMembranePixels;
print("total membrane signal = " + rawMembraneSignal);
print("background-corrected membrane signal = " + membraneSignal);
rawCytoplasmSignal = totalMaskedIntensity(labelStack, "cytoplasmMask");
nCytoplasmPixels = totalMaskedIntensity("cytoplasmMask", "cytoplasmMask") / 255;
cytoplasmSignal = rawCytoplasmSignal - background * nCytoplasmPixels;
print("total cytoplasm signal = " + rawCytoplasmSignal);
print("background-corrected cytoplasm signal = " + cytoplasmSignal);

if (cleanup) {
	selectWindow("nucleusMask");
	close();
	selectWindow("membraneMask");
	close();
	selectWindow("labelMask");
	close();
	selectWindow("cytoplasmMask");
	close();
	selectWindow(labelStack);
	close();
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

// estimate average background intensity in a stack, excluding
// foreground by auto-thresholding (Otsu) & dilation by nDilate
function estimateBackground(stackTitle, nDilate) {
    stackCopy(stackTitle);
    run("Convert to Mask", "method=Otsu background=Dark black");
    run("Options...", "iterations=" + nDilate + " count=1 black edm=Overwrite");
    run("Dilate", "stack");
    run("Options...", "iterations=1 count=1 black edm=Overwrite");
    run("Invert", "stack");
    rename("backgroundMask");
    maskTotal = totalMaskedIntensity("backgroundMask", "backgroundMask");
    maskedBackgroundTotal = totalMaskedIntensity(stackTitle, "backgroundMask");
    backgroundMean = maskedBackgroundTotal / (maskTotal / 255);
    selectWindow("backgroundMask");
    close();
    return backgroundMean;
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
