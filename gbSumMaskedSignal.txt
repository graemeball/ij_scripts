/*** Step 1 - set up Marker and Signal stacks ***/
markerChannel = getNumber("Which channel is the Marker (1..n)?", 1);
run("Stack Splitter", "number=2");  // split into 2 substacks - NB. assumes Z then C
if (markerChannel == 1){
    rename("Signal");
    run("Put Behind [tab]");
    rename("Marker");
}else{
    rename("Marker");
    run("Put Behind [tab]");
    rename("Signal");
}


/*** Step 2 - generate Mask, InvMask (for background), maskedSignal & Background ***/
// select marker channel; generate & filter mask
selectWindow("Marker");
// normalize according to mean and otsu threshold
run("Normalize Values", "normalize=Mean");
setAutoThreshold("Otsu dark stack");
run("Convert to Mask", "black");
run("Median (3D)");
rename("Mask");
run("Duplicate...", "title=InvMask duplicate range=all");
run("Invert", "stack");

// make InvMask first since we have it selected & count Background pixels
run("Divide...", "value=255 stack");
run("16-bit");
num_slices = nSlices();
setSlice(1);
// find total pixels in 3D Background region (i.e. where InvMask=1);
total_pixels_in_BG = 0;
run("Set Measurements...", "area mean integrated stack limit redirect=None decimal=0");
run("Clear Results");
for (i=0; i<num_slices; i++){
    run("Measure");
    pixels_in_slice = getResult("RawIntDen", i);
    total_pixels_in_BG = total_pixels_in_BG + pixels_in_slice;
    run("Next Slice [>]");
}
run("Clear Results");

// now finish making Mask for maskedSignal & count maskedSignal pixels
selectWindow("Mask");
run("Divide...", "value=255 stack");
run("16-bit");
num_slices = nSlices();
setSlice(1);
// find total pixels in 3D ROI (i.e. where mask=1);
total_pixels_in_ROI = 0;
run("Set Measurements...", "area mean integrated stack limit redirect=None decimal=0");
run("Clear Results");
for (i=0; i<num_slices; i++){
    run("Measure");
    pixels_in_slice = getResult("RawIntDen", i);
    total_pixels_in_ROI = total_pixels_in_ROI + pixels_in_slice;
    run("Next Slice [>]");
}
run("Clear Results");

// multiply Signal and Mask images; also multiply Signal and InvMask images
imageCalculator("Multiply create 32-bit stack", "Signal","InvMask");
rename("Background");
imageCalculator("Multiply create 32-bit stack", "Signal","Mask");
rename("maskedSignal");


/*** Step 3 - measure masked Signal & Background intensity in each slice, and summarize ***/
// select Background and loop through slices summing masked intensity
selectWindow("Background");
num_slices = nSlices();
setSlice(1);
total_BG_intensity = 0;
for (i=0; i<num_slices; i++){
    run("Measure");
    intensity_in_sliceBG = getResult("RawIntDen", i);
    total_BG_intensity = total_BG_intensity + intensity_in_sliceBG;
    run("Next Slice [>]");
}
run("Clear Results");

// loop through maskedSignal  slices summing masked intensity
selectWindow("maskedSignal");
num_slices = nSlices();
setSlice(1);
total_intensity_in_ROI = 0;
for (i=0; i<num_slices; i++){
    run("Measure");
    intensity_in_sliceROI = getResult("RawIntDen", i);
    total_intensity_in_ROI = total_intensity_in_ROI + intensity_in_sliceROI;
    run("Next Slice [>]");
}
// NB. results for maskedSignal not cleared

// return results
SignalAvPerPixel=total_intensity_in_ROI/total_pixels_in_ROI;
BgAvPerPixel=total_BG_intensity/total_pixels_in_BG;
showMessage("Results", "total Signal pixels = "+total_pixels_in_ROI+"\naverage ROI intensity = "+SignalAvPerPixel+"\ntotal Background pixels = "+total_pixels_in_BG+"\naverage BG intensity = "+BgAvPerPixel);
