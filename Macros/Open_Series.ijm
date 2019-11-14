// ImageJ Macro to list all series in multi-series file and open one
//
// Copyright g.ball@dundee.ac.uk (2019) Dundee Imaging Facility
// License: Creative Commons CC-BY-SA
//

macro "Open Series [O]" {
	// macro to list all series in multi-series file and open one
	message = "Choose multi-series file to list contents";
	showMessage(message);
	msFile = File.openDialog(message);
	folder = File.getParent(msFile);
	
	run("Bio-Formats Macro Extensions");
	
	Ext.setId(msFile);  // initialize file
	Ext.getSeriesCount(seriesCount);
	print("### Open Series Macro ###");
	print("Multi-series file " + File.getName(msFile) + " contains " + seriesCount + " series:");
	
	for (n = 0; n < seriesCount; n++) {
		Ext.setSeries(n);
		Ext.getSeriesName(seriesName);
		Ext.getImageCount(nPlanes);
		Ext.getSizeX(nx);
		Ext.getSizeY(ny);
		Ext.getSizeZ(nz);
		Ext.getSizeC(nc);
		Ext.getSizeT(nt);
		dimensionString = "; " + nx + " x " + ny + ";";
		dimensionString += " " + nPlanes + " planes";
		dimensionString += " (" + nz + "Z/" + nc + "C/" + nt + "T)"; 
		print("  Series  " + n + ": " + seriesName + dimensionString);
	}

	if (seriesCount > 1) {
		Dialog.createNonBlocking("Open Series");
		Dialog.addNumber("Choose series number to open", 0);
		Dialog.show();
		seriesToOpen = Dialog.getNumber();
	} else {
		seriesToOpen = 0;
	}
	
	Ext.setSeries(seriesToOpen);
	Ext.openImagePlus(msFile);
}
