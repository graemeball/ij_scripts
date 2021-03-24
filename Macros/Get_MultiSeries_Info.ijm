// ImageJ Macro to get series info from a multi-series image file
//
// Copyright: Graeme Ball (g.ball@dundee.ac.uk), Dundee Imaging Facility (2018)
// License: GNU GPL
//


multiSeriesFile = File.openDialog("Choose file containing multiple image series");
folder = File.getParent(multiSeriesFile);

run("Bio-Formats Macro Extensions");

Ext.setId(multiSeriesFile);  // initialize file
Ext.getSeriesCount(seriesCount);
Ext.getFormat(multiSeriesFile, format);

print("### Get_MultiSeries_Info.ijm ###");
print("Image: " + multiSeriesFile);
print("Format: " + format + " (" + seriesCount + " image series)");

for (i = 0; i < seriesCount; i++) {
	Ext.setSeries(i);
	Ext.getSeriesName(seriesName);
	Ext.getImageCount(sliceCount);
	Ext.getSizeX(nx);
	Ext.getSizeY(ny);
	Ext.getSizeZ(nz);
	Ext.getSizeC(nc);
	Ext.getSizeT(nt);
	Ext.getPixelType(pixelType);
	Ext.getDimensionOrder(dimOrder);
	Ext.getPlanePositionX(stageX0, 0);
	Ext.getPlanePositionY(stageY0, 0);
	Ext.getPlanePositionZ(stageZ0, 0);
	Ext.getPlaneTimingDeltaT(deltaT0, 0);
	nXYZCT = "" + nx + "/" + ny + "/" + nz + "/" + nc + "/" + nt;
	dimInfo = ", size X/Y/Z/C/T=" + nXYZCT + "(" + dimOrder + ")";
	posXYZT = "" + stageX0 + "," + stageY0 + "," + stageZ0 + "," + deltaT0;
	positionInfo = ", position X,Y,Z,T=" + posXYZT;
	print("" + i + ": " + seriesName + dimInfo + positionInfo);
}

