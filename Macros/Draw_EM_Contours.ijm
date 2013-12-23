// Draw_EM_Contours.ijm: automatic segmentation and contour drawing      
// * takes EM scan with manually drawn black boundary lines        
// * identifies the black boundary, and fills to make ROI          
// * progressively erodes the ROI producing concentric ROIs        
// * measures area of each ROI, and displays all on original image 
// Author: Graeme Ball, Micron Oxford (2012)
// License: Public Domain (CC0)
// TODO: calculate cencentric ring ROIs from the full circular ROIs    

imageID = getImageID();
run("Duplicate...", "title=temp.tif");
run("Colors...", "foreground=white background=black selection=magenta");
run("Clear Results");
if(roiManager("count")>0){ 
  roiManager("Delete");
}
roiManager("Show All");
roiManager("Set Color", "magenta");
run("8-bit");
midx = getWidth()/2;
midy = getHeight()/2;
setAutoThreshold("Triangle");
run("Convert to Mask");
run("Options...", "iterations=4 count=1 edm=Overwrite do=Nothing");
run("Dilate");
run("Invert"); 
floodFill(midx, midy); 
run("Invert"); 
run("Fill Holes");
run("Erode");
run("Invert");
run("Set Measurements...", "area limit redirect=None decimal=4");
centralValue = getPixel(midx, midy);
while(centralValue==0){
  setAutoThreshold("Triangle dark");
  doWand(midx, midy, 0.0, "4-connected");
  roiManager("Add");
  run("Options...", "iterations=5 count=1 edm=Overwrite do=Nothing");
  setThreshold(255, 255);
  run("Convert to Mask");
  run("Dilate");
  centralValue = getPixel(midx, midy);
}
roiManager("Measure");
selectImage(imageID);
run("RGB Color");
roiManager("Show All");
