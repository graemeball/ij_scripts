// Measure average intensities in 3 ROIs for FRAP analysis
// - tracks first ROI for FRAP spot
// - delay based on preBleachDelay to allow partial recovery before tracking
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
//   - .zip file with the 3 ROIs
//
// Copyright Graeme Ball (2014), graemeball@gmail.com
// Creative Commons Attribution License (CC BY 3.0)

macro "FRAP Intensity Data [f]" {

    // --- adjust macro parameters below

    // number of time points to analyze
    nTimes = 200;

    // number of characters to chop off data filename before adding .dv.log
    nExtChars = 8;

    // dilate peak ROI by searchRadius times to make a window to track it
    searchRadius = 1;

    // delay tracking until partial recovery
    preBleachDelay = 5;


    // --- real start of macro: should not need to edit below!

    imageName = getTitle();
    imageID = getImageID();
    dir = getDirectory("image");
    getDimensions(width, height, channels, slices, frames);

    nROIs = roiManager("count");
    if (nROIs != 3) {
        exit("*** Bad Input! ***\n" +
            "ROI manager should contain 3 ROIs:\n" +
            "1) FRAP region\n2) whole cell\n3) background");
    }

    logText = findLog(imageName, dir, nExtChars);
    times = extractTimes(logText, nTimes);

    ROInames = newArray("Ifrap", "Icell", "Ibackground");
    for (nROI = 0; nROI < nROIs; nROI++) {
        roiManager("select", nROI);
        roiManager("rename", ROInames[nROI]);
    }

    run("Clear Results");
    setBatchMode(true);
    for (frame = 1; frame <= frames; frame++) {
        if (frame <= nTimes) {
            for (nROI = 0; nROI < nROIs; nROI++) {
                roiManager("select", nROI);
                Stack.setFrame(frame);
                // logic for adding a new Ifrap ROI for each frame
                if (nROI == 0) {
                    if (frame < preBleachDelay * 3) {
                        Roi.getBounds(x, y, w, h);
                        makeOval(x, y, w, h);
                        roiManager("Add");
                        roiManager("select", roiManager("count") - 1);
                        roiManager("Rename", "Ifrap[frame=" + frame + "]");
                        // after 1st frame, final ROI is frap ROI for previous frame
                    } else {
                        roiManager("select", roiManager("count") - 1);
                        addRoiForNearestPeak(imageID, frame, searchRadius);
                    }
                }
                getStatistics(area, mean, min, max, std, histogram);
                time = times[frame - 1];
                setResult("Time", frame - 1, time);
                setResult(ROInames[nROI], frame - 1, mean);
            }
        }
    }
    setBatchMode(false);
    updateResults();
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
    return File.openAsString(logfile);
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

function addRoiForNearestPeak(imageID, frame, searchRadius) {
    // add new ROI for nearest peak within current ROI dilated by searchRadius
    currentRoi = roiManager("index");
    Roi.getBounds(x, y, w, h);
    makeRectangle(
        x - searchRadius * w,
        y - searchRadius * h,
        (2 * searchRadius + 1) * w,
        (2 * searchRadius + 1) * h);
    run("Duplicate...", "title=searchWindow");
    run("Select All");
    getStatistics(area, mean, min, max, std, histogram);
    run("Find Maxima...", "noise=" + std + " output=[Point Selection] exclude");
    Roi.getCoordinates(xpoints, ypoints);
    nPoints = xpoints.length;
    xPrevious = ((2 * searchRadius + 1) * w / 2);
    yPrevious = ((2 * searchRadius + 1) * h / 2);
    pNearest = 0;
    if (nPoints > 1) {
        // find the nearest to the previous point
        minSqDist = pow(xPrevious, 2) + pow(yPrevious, 2);  // edge value to start
        for (p = 0; p < nPoints; p++) {
            sqDist = pow((xpoints[p] - xPrevious), 2) +
                     pow((ypoints[p] - yPrevious), 2);
            if (sqDist < minSqDist) {
                minSqDist = sqDist;
                pNearest = p;
            }
        }
    }
    xOffset = xpoints[pNearest] - xPrevious;
    yOffset = ypoints[pNearest] - yPrevious;
    close();
    selectImage(imageID);
    Stack.setFrame(frame);
    makeOval(x + xOffset, y + yOffset, w, h);
    roiManager("Add");
    roiManager("select", currentRoi + 1);
    roiManager("Rename", "Ifrap[frame=" + frame + "]");
}
