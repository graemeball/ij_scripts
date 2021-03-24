// View_OTF.js: unscramble API OMX OTF files for viewing
// Copyright: Graeme Ball, Micron Oxford, November 2013
// License: GPL V3 license
//
// NB. bioformats treats 64bit complex as 32bit float
//   => file header must be edited to double y size before import
//   (halved back to the true value upon splitting aplitude / phase)
//
// also serves as an example of using a java array in js

// get input image stack / parameters and create empty output stack
var imp = IJ.getImage();
var nx = imp.getWidth();
var ny = imp.getHeight();
var ns = imp.getNSlices();
var stack = imp.getStack();
var stack2 = new ImageStack(nx, ny / 2);

// for each slice in stack, split into amplitude and phase slices
for (var s = 0; s < ns; s++) {
    var pix = stack.getProcessor(s + 1).getPixels();
    var pix2amp = new java.lang.reflect.Array.newInstance(
            java.lang.Float.TYPE, pix.length / 2);
    var pix2ph = new java.lang.reflect.Array.newInstance(
            java.lang.Float.TYPE, pix.length / 2);
    var i = 0;
    var iPh = 0;
    var iAmp = 0;
    for (var y = 0; y < ny; y++) {
    	for (var x = 0; x < nx; x++) {
            if ((y % 2 === 0 && x % 2 === 0) ||
                (y % 2 !== 0 && x % 2 !== 0)) {
       	        //IJ.log("pixph[" + iPh + "]");
                pix2ph[iPh] = pix[i];
                iPh++;
            } else {
       	        //IJ.log("pixamp[" + iAmp + "]");
            	pix2amp[iAmp] = pix[i];
            	iAmp++;
            }
            i++;
    	}
    }
    pix2amp = swapCenterEdge(pix2amp, nx, ny / 2);
    pix2ph = swapCenterEdge(pix2ph, nx, ny / 2);
    var fpAmp = new FloatProcessor(nx, ny / 2, pix2amp);
    stack2.addSlice("m" + s + "_amp", fpAmp);
    var fpPh = new FloatProcessor(nx, ny / 2, pix2ph);
    stack2.addSlice("m" + s + "_ph", fpPh);
}

// create & show ImagePlus result (height halved, NSlices doubled)
var imp2 = new ImagePlus("AMP_PH_" + imp.getTitle(), stack2);
imp2.show();

// -- helper function definitions

/** takes 1D array containing 2D pixel data and swaps center/edges */
function swapCenterEdge(pix, nx, ny) {
    var pix2 = new java.lang.reflect.Array.newInstance(
            java.lang.Float.TYPE, pix.length);
    var nxHalf = Math.floor(nx / 2);
    for (var y = 0; y < ny; y++) {
    	for (var x = 0; x < nx; x++) {
            var i = x + y * nx;
            var i2 = i;
            if (x < nxHalf) {
            	i2 += nxHalf + 1;
            } else {
            	i2 -= nxHalf;
            }
            pix2[i2] = pix[i];
    	}
    }
    return pix2;
}
