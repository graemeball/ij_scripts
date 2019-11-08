// ImageJ Macro to list all series in multi-series file and open one
//
// Copyright g.ball@dundee.ac.uk (2019) Dundee Imaging Facility
// License: Creative Commons CC-BY-SA
//

message = "Choose multi-series file to list contents";
showMessage(message);
msFile = File.openDialog(message);
folder = File.getParent(msFile);

run("Bio-Formats Macro Extensions");

Ext.setId(msFile);  // initialize file
Ext.getSeriesCount(seriesCount);
print("Multi-series file " + File.getName(msFile) + " contains " + seriesCount + " series:");

for (n = 0; n < seriesCount; n++) {
	Ext.setSeries(n);
	Ext.getSeriesName(seriesName);
	print("  " + n + ": " + seriesName);
}

Dialog.createNonBlocking("Open Series");
Dialog.addNumber("Choose series to open", 0);
Dialog.show();
seriesToOpen = Dialog.getNumber();

Ext.setSeries(seriesToOpen);
Ext.openImagePlus(msFile);
