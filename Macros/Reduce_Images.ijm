// Reduce_Images.ijm: intended for batch reduction of photo size ;-)
// Usage: paste into window of Process>Batch>Macro
// Author: Graeme Ball (2012)
// License: Public Domain (CC0)

scale = 0.67;
w = getWidth * scale; h = getHeight * scale;
run("Size...", "width=w height=h interpolation=Bicubic");
