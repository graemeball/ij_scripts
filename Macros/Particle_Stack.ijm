/*
 * Macro to produce a "particle image stack" from a field of particles
 * Graeme Ball, 2013 (for Kok-Lung Chan)
 */

box_radius = 8;
title = getTitle();
titleStack = "Particles";

width = 2 * box_radius + 1;
height = 2 * box_radius + 1;

run("Find Maxima...", "noise=50 output=[Point Selection] exclude");
getSelectionCoordinates(xCoords, yCoords);
nParticles = xCoords.length;
newImage(titleStack, "16-bit grayscale-mode", 17, 17, 1, nParticles, 1);

setBatchMode(true);
for (i = 1; i <= nParticles; i++) {
	selectWindow(title);
	x = xCoords[i - 1] - box_radius;
	y = yCoords[i - 1] - box_radius;
	makeRectangle(x, y, width, height);
	run("Copy");
	selectWindow(titleStack);
	setSlice(i);
	run("Paste");
}
