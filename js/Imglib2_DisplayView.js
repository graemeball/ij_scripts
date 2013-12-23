// Imglib2_DisplayView.js: ImgLib2 js example -- open image, rotate, show
// based on http://fiji.sc/ImgLib2_Examples Example 1d 
// Author: graemeball@googlemail.com
// License: Public Domain (CC0)

importClass(Packages.net.imglib2.RandomAccessibleInterval);
importClass(Packages.net.imglib2.img.Img);
importClass(Packages.io.scif.img.ImgOpener);
importClass(Packages.net.imglib2.img.display.imagej.ImageJFunctions);
importClass(Packages.net.imglib2.view.Views);

// Open & show Lena image
var img = new ImgOpener().openImg("/Users/graemeb/Documents/testData/Lena.tif");
ImageJFunctions.show(img, "Lena");

// Show a rotated view of the image
ImageJFunctions.show(Views.rotate(img, 0, 1), "rotated Lena");

// Create a View containing part of the image and display it
var view = Views.interval(img, [80, 80], [180, 180]);
ImageJFunctions.show(view, "Lena cropped");
