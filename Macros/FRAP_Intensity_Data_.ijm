// Measure average intensities in 3 ROIs for FRAP analysis
//
// USAGE:-
// - takes a multi-frame image with 3 pre-defined ROIs:
//   1. FRAP region
//   2. whole cell
//   3. background
// - requires a .dv.log file for the .dv or .tif data file (same folder)
// - use "f" keyboard shortcut to run the macro
//
// RESULTS:-
// - in the same folder as the input image, saves:
//   - .csv file with average intensity results
//   - .roi file with the 3 ROIs
//
// Copyright Graeme Ball (2014), graemeball@gmail.com
// Creative Commons Attribution License (CC BY 3.0)

macro "FRAP Intensity Data [f]" {

    // --- adjust macro parameters below

    // number of time points to analyze
    nTimes = 110;

    // number of characters to chop off data filename before adding .dv.log
    nExtChars = 8;


    // --- real start of macro: should not need to edit below!

    imageName = getTitle();
    dir = getDirectory("image");
    getDimensions(width, height, channels, slices, frames);

    nROIs = roiManager("count");
    if (nROIs != 3) {
        exit("*** Bad Input! ***\n" +
            "ROI manager should contain 3 ROIs:\n" +
            "1) FRAP region\n2) whole cell\n3) background");
    }

    logText = findLog(imageName, dir, 8);
    times = extractTimes(logText, 110);

    ROInames = newArray("Ifrap", "Icell", "Ibackground");

    run("Clear Results");
    for (frame = 1; frame <= frames; frame++) {
        if (frame <= nTimes) {
            for (nROI = 0; nROI < nROIs; nROI++) {
                roiManager("select", nROI);
                Stack.setFrame(frame);
                getStatistics(area, mean, min, max, std, histogram);
                time = times[frame - 1];
                setResult("Time", frame - 1, time);
                setResult(ROInames[nROI], frame - 1, mean);
            }
        }
    }

    resultsFile = dir + filenameWithoutExtension(imageName) + ".csv";
    saveAs("Results", resultsFile);
    print("---\nsaved " + resultsFile);
    roiSetFile = dir + filenameWithoutExtension(imageName) + "_RoiSet.zip";
    roiManager("Deselect");
    roiManager("Save", roiSetFile);
    print("saved " + roiSetFile + "\n---");
}

// --- helper functions defined below

function filenameWithoutExtension(filename) {
    // return filename with last .ext chopped off
    lastDot = lastIndexOf(filename, ".");
    nameWithoutExtension = substring(filename, 0, lastDot);
    return nameWithoutExtension;
}

function findLog(filename, dir, N) {
    // look for .dv.log file in dir
    // matching all but last N chars of filename
    filebase = substring(filename, 0, lengthOf(filename) - N);
    logfile = dir + filebase + ".dv.log";
    return File.openAsString(logfile);;
}

function extractTimes(logText, nTimes) {
    // extract nTimes time stamps (sec) from .dv.log text
    times = newArray(nTimes);
    lines = split(logText, "\n");
    nLines = lines.length;
    nTime = 0;
    for (n = 0; n < nLines; n++) {
        line = lines[n];
        if (matches(line, " *Time Point: .* secs")) {
            numStart = indexOf(line, ":") + 1;
            numEnd = indexOf(line, "secs") - 1;
            time = parseFloat(substring(line, numStart, numEnd));
            if (nTime < nTimes) {
                times[nTime++] = time;
            }
        }
    }
    return times;
}
