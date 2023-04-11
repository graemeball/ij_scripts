// ImageJ macro to demonstrate adding channel name/info to slice labels
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2023)
// License: MIT license
//


run("Mitosis (5D stack)");
channel1info = "mCherry";
channel2info = "GFP";
imageID = getImageID();
appendChannelInfoToSliceLabels(imageID, 1, channel1info);
appendChannelInfoToSliceLabels(imageID, 2, channel2info);
Stack.setPosition(1, 3, 1);


// --- function definitions ---

function appendChannelInfoToSliceLabels(imageID, channel, channelInfo) {
	// for given hyperstack channel, append info to end of each slice label
	selectImage(imageID);
	getDimensions(w, h, nc, nz, nt);
	setBatchMode("hide");
	for (z = 1; z <= nz; z++) {
		for (t = 1; t <= nt; t++) {
			Stack.setPosition(channel, z, t);
			sliceLabel = Property.getSliceLabel();
			Property.setSliceLabel(sliceLabel + channelInfo);
		}
	}
	setBatchMode("exit and display");
}
