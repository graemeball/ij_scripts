// Reduce_Images.ijm: intended for batch reduction of photo size ;-)
// Graeme Ball (2012), Public Domain (CC0)

scale = 0.67;
w = getWidth * scale; h = getHeight * scale;
run("Size...", "width=w height=h interpolation=Bicubic");
