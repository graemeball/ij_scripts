// Spot_Noise_Demo.ijm: macro to demo sub-res spot at descending SNR
// Usage: just run it
// Author: graemeball@googlemail.com, Dundee Imaging Facility (2015)
// License: Public Domain (CC0)
// 

SIZE = 256;
setForegroundColor(255, 255, 255);
PEAK = 0.04;  // peak signal after gaussian blur (!?)
STEPS = 7;
ATTENUATION = 1.5;
D = 11;  // oval ROI diameter
snr = 10;
hw = SIZE / 2;

for (s = 1; s <= STEPS; s++) {
	title = "spotSNR" + snr;
	newImage(title, "32-bit black", 256, 256, 1);
	// create gaussian spot at fairly random position
	x = hw * (1 + random() - random());
	y = hw * (1 + random() - random());
	run("Specify...", "width=1 height=1 x=" + x + " y=" + y);
	run("Fill", "slice");
	run("Select None");
	run("Gaussian Blur...", "sigma=2");
	noise = PEAK / snr;
	run("Add Specified Noise...", "standard=" + noise);
	// save oval ROI surrounding spot position
	ox = x - D/2;
	oy = y - D/2;
	run("Specify...", "width=" + D + " height=" + D + " x=" + ox + " y=" + oy + " oval");
	roiManager("Add");
	roiManager("Select", s - 1);
	roiManager("Rename", title);
	snr = snr / ATTENUATION;
}
run("Images to Stack", "name=Stack title=[] use");
run("16-bit");
