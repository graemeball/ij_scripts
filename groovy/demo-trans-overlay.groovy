// http://stackoverflow.com/questions/24791122/making-both-bufferedimages-overlap-and-transparent
// Jan Eglinger

import ij.IJ;
import ij.gui.ImageRoi;
import ij.gui.Overlay;

//imp = IJ.openImage("http://imagej.nih.gov/ij/images/leaf.jpg");
imp = IJ.openImage("http://imagej.nih.gov/ij/images/boats.gif");
imp2 = IJ.openImage("http://imagej.nih.gov/ij/images/clown.jpg");
//imp = IJ.getImage();
//IJ.selectWindow("STICS");
//imp2 = IJ.getImage();

roi = new ImageRoi(50, 50, imp2.getProcessor());
roi.setZeroTransparent(false);
roi.setOpacity(0.5);
ovl = new Overlay(roi);

imp.setOverlay(ovl);
imp.show();