// "StartupMacros"
// The macros and macro tools in this file ("StartupMacros.txt") are
// automatically installed in the Plugins>Macros submenu and
//  in the tool bar when ImageJ starts up.

//  About the drawing tools.
//
//  This is a set of drawing tools similar to the pencil, paintbrush,
//  eraser and flood fill (paint bucket) tools in NIH Image. The
//  pencil and paintbrush draw in the current foreground color
//  and the eraser draws in the current background color. The
//  flood fill tool fills the selected area using the foreground color.
//  Hold down the alt key to have the pencil and paintbrush draw
//  using the background color or to have the flood fill tool fill
//  using the background color. Set the foreground and background
//  colors by double-clicking on the flood fill tool or on the eye
//  dropper tool.  Double-click on the pencil, paintbrush or eraser
//  tool  to set the drawing width for that tool.
//
// Icons contributed by Tony Collins.

// Global variables
var pencilWidth=1,  eraserWidth=10, leftClick=16, alt=8;
var brushWidth = 10; //call("ij.Prefs.get", "startup.brush", "10");
var floodType =  "8-connected"; //call("ij.Prefs.get", "startup.flood", "8-connected");

// The macro named "AutoRunAndHide" runs when ImageJ starts
// and the file containing it is not displayed when ImageJ opens it.

// macro "AutoRunAndHide" {}

function UseHEFT {
	requires("1.38f");
	state = call("ij.io.Opener.getOpenUsingPlugins");
	if (state=="false") {
		setOption("OpenUsingPlugins", true);
		showStatus("TRUE (images opened by HandleExtraFileTypes)");
	} else {
		setOption("OpenUsingPlugins", false);
		showStatus("FALSE (images opened by ImageJ)");
	}
}

UseHEFT();

// The macro named "AutoRun" runs when ImageJ starts.

macro "AutoRun" {
	// run all the .ijm scripts provided in macros/AutoRun/
	autoRunDirectory = getDirectory("imagej") + "/macros/AutoRun/";
	if (File.isDirectory(autoRunDirectory)) {
		list = getFileList(autoRunDirectory);
		// make sure startup order is consistent
		Array.sort(list);
		for (i = 0; i < list.length; i++) {
			if (endsWith(list[i], ".ijm")) {
				runMacro(autoRunDirectory + list[i]);
			}
		}
	}
}

var pmCmds = newMenu("Popup Menu",
	newArray("Help...", "Rename...", "Duplicate...", "Original Scale",
	"Paste Control...", "-", "Record...", "Capture Screen ", "Monitor Memory...",
	"Find Commands...", "Control Panel...", "Startup Macros...", "Search..."));

macro "Popup Menu" {
	cmd = getArgument();
	if (cmd=="Help...")
		showMessage("About Popup Menu",
			"To customize this menu, edit the line that starts with\n\"var pmCmds\" in ImageJ/macros/StartupMacros.txt.");
	else
		run(cmd);
}

macro "Abort Macro or Plugin (or press Esc key) Action Tool - CbooP51b1f5fbbf5f1b15510T5c10X" {
	setKeyDown("Esc");
}

var xx = requires138b(); // check version at install
function requires138b() {requires("1.38b"); return 0; }

var dCmds = newMenu("Developer Menu Tool",
newArray("ImageJ Website","News", "Documentation", "ImageJ Wiki", "Resources", "Macro Language", "Macros",
	"Macro Functions", "Startup Macros...", "Plugins", "Source Code", "Mailing List Archives", "-", "Record...",
	"Capture Screen ", "Monitor Memory...", "List Commands...", "Control Panel...", "Search...", "Debug Mode"));

macro "Developer Menu Tool - C037T0b11DT7b09eTcb09v" {
	cmd = getArgument();
	if (cmd=="ImageJ Website")
		run("URL...", "url=http://rsbweb.nih.gov/ij/");
	else if (cmd=="News")
		run("URL...", "url=http://rsbweb.nih.gov/ij/notes.html");
	else if (cmd=="Documentation")
		run("URL...", "url=http://rsbweb.nih.gov/ij/docs/");
	else if (cmd=="ImageJ Wiki")
		run("URL...", "url=http://imagejdocu.tudor.lu/imagej-documentation-wiki/");
	else if (cmd=="Resources")
		run("URL...", "url=http://rsbweb.nih.gov/ij/developer/");
	else if (cmd=="Macro Language")
		run("URL...", "url=http://rsbweb.nih.gov/ij/developer/macro/macros.html");
	else if (cmd=="Macros")
		run("URL...", "url=http://rsbweb.nih.gov/ij/macros/");
	else if (cmd=="Macro Functions")
		run("URL...", "url=http://rsbweb.nih.gov/ij/developer/macro/functions.html");
	else if (cmd=="Plugins")
		run("URL...", "url=http://rsbweb.nih.gov/ij/plugins/");
	else if (cmd=="Source Code")
		run("URL...", "url=http://rsbweb.nih.gov/ij/developer/source/");
	else if (cmd=="Mailing List Archives")
		run("URL...", "url=https://list.nih.gov/archives/imagej.html");
	else if (cmd=="Debug Mode")
		setOption("DebugMode", true);
	else if (cmd!="-")
		run(cmd);
}

var sCmds = newMenu("Stacks Menu Tool",
	newArray("Add Slice", "Delete Slice", "Next Slice [>]", "Previous Slice [<]", "Set Slice...", "-",
		"Convert Images to Stack", "Convert Stack to Images", "Make Montage...", "Reslice [/]...", "Z Project...",
		"3D Project...", "Plot Z-axis Profile", "-", "Start Animation", "Stop Animation", "Animation Options...",
		"-", "MRI Stack (528K)"));
macro "Stacks Menu Tool - C037T0b11ST8b09tTcb09k" {
	cmd = getArgument();
	if (cmd!="-") run(cmd);
}

var luts = getLutMenu();
var lCmds = newMenu("LUT Menu Tool", luts);
macro "LUT Menu Tool - C037T0b11LT6b09UTcb09T" {
	cmd = getArgument();
	if (cmd!="-") run(cmd);
}
function getLutMenu() {
	list = getLutList();
	menu = newArray(16+list.length);
	menu[0] = "Invert LUT"; menu[1] = "Apply LUT"; menu[2] = "-";
	menu[3] = "Fire"; menu[4] = "Grays"; menu[5] = "Ice";
	menu[6] = "Spectrum"; menu[7] = "3-3-2 RGB"; menu[8] = "Red";
	menu[9] = "Green"; menu[10] = "Blue"; menu[11] = "Cyan";
	menu[12] = "Magenta"; menu[13] = "Yellow"; menu[14] = "Red/Green";
	menu[15] = "-";
	for (i=0; i<list.length; i++)
		menu[i+16] = list[i];
	return menu;
}

function getLutList() {
	lutdir = getDirectory("luts");
	list = newArray("No LUTs in /ImageJ/luts");
	if (!File.exists(lutdir))
		return list;
	rawlist = getFileList(lutdir);
	if (rawlist.length==0)
		return list;
	count = 0;
	for (i=0; i< rawlist.length; i++)
		if (endsWith(rawlist[i], ".lut")) count++;
	if (count==0)
		return list;
	list = newArray(count);
	index = 0;
	for (i=0; i< rawlist.length; i++) {
		if (endsWith(rawlist[i], ".lut"))
			list[index++] = substring(rawlist[i], 0, lengthOf(rawlist[i])-4);
	}
	return list;
}

macro "Pencil Tool - C037L494fL4990L90b0Lc1c3L82a4Lb58bL7c4fDb4L5a5dL6b6cD7b" {
	getCursorLoc(x, y, z, flags);
	if (flags&alt!=0)
		setColorToBackgound();
	draw(pencilWidth);
}

macro "Paintbrush Tool - C037La077Ld098L6859L4a2fL2f4fL3f99L5e9bL9b98L6888L5e8dL888c" {
	getCursorLoc(x, y, z, flags);
	if (flags&alt!=0)
		setColorToBackgound();
	draw(brushWidth);
}

macro "Flood Fill Tool -C037B21P085373b75d0L4d1aL3135L4050L6166D57D77D68La5adLb6bcD09D94" {
	requires("1.34j");
	setupUndo();
	getCursorLoc(x, y, z, flags);
	if (flags&alt!=0) setColorToBackgound();
	floodFill(x, y, floodType);
}

function draw(width) {
	requires("1.32g");
	setupUndo();
	getCursorLoc(x, y, z, flags);
	setLineWidth(width);
	moveTo(x,y);
	x2=-1; y2=-1;
	while (true) {
		getCursorLoc(x, y, z, flags);
		if (flags&leftClick==0) exit();
		if (x!=x2 || y!=y2)
			lineTo(x,y);
		x2=x; y2 =y;
		wait(10);
	}
}

function setColorToBackgound() {
	savep = getPixel(0, 0);
	makeRectangle(0, 0, 1, 1);
	run("Clear");
	background = getPixel(0, 0);
	run("Select None");
	setPixel(0, 0, savep);
	setColor(background);
}

// Runs when the user double-clicks on the pencil tool icon
macro 'Pencil Tool Options...' {
	pencilWidth = getNumber("Pencil Width (pixels):", pencilWidth);
}

// Runs when the user double-clicks on the paint brush tool icon
macro 'Paintbrush Tool Options...' {
	brushWidth = getNumber("Brush Width (pixels):", brushWidth);
	call("ij.Prefs.set", "startup.brush", brushWidth);
}

// Runs when the user double-clicks on the flood fill tool icon
macro 'Flood Fill Tool Options...' {
	Dialog.create("Flood Fill Tool");
	Dialog.addChoice("Flood Type:", newArray("4-connected", "8-connected"), floodType);
	Dialog.show();
	floodType = Dialog.getChoice();
	call("ij.Prefs.set", "startup.flood", floodType);
}

macro "Set Drawing Color..."{
	run("Color Picker...");
}

macro "-" {} //menu divider

macro "About Startup Macros..." {
	title = "About Startup Macros";
	text = "Macros, such as this one, contained in a file named\n"
		+ "'StartupMacros.txt', located in the 'macros' folder inside the\n"
		+ "Fiji folder, are automatically installed in the Plugins>Macros\n"
		+ "menu when Fiji starts.\n"
		+ "\n"
		+ "More information is available at:\n"
		+ "<http://imagej.nih.gov/ij/developer/macro/macros.html>";
	dummy = call("fiji.FijiTools.openEditor", title, text);
}

macro "Save As JPEG... [j]" {
	quality = call("ij.plugin.JpegWriter.getQuality");
	quality = getNumber("JPEG quality (0-100):", quality);
	run("Input/Output...", "jpeg="+quality);
	saveAs("Jpeg");
}

macro "Save Inverted FITS" {
	run("Flip Vertically");
	run("FITS...", "");
	run("Flip Vertically");
}



// ##### user-defined functions & macros below #####


// ## function definitions for macros

function hexColor(redValue, greenValue, blueValue) {
	// convert color from 0-255 triple format to hex string format "#XXYYZZ"
	rHex = toHex(redValue);
	gHex = toHex(greenValue);
	bHex = toHex(blueValue);
	if (lengthOf(rHex) < 2) {
		rHex = "0" + rHex;
	}
	if (lengthOf(gHex) < 2) {
		gHex = "0" + gHex;
	}
	if (lengthOf(bHex) < 2) {
		bHex = "0" + bHex;
	}
	colorString = "#" + rHex + gHex + bHex;
	return colorString;
}

// ## custom user macros / shortcuts

macro "Auto Display [A]" {
	// macro to auto-scale all channels and display composite if multi-channel
	getDimensions(w, h, nc, nz, nt);
	if (nc > 1) {
		Stack.setDisplayMode("composite");
		for (c = 1; c <= nc; c++) {
			Stack.setChannel(c);
			run("Enhance Contrast", "saturated=0.35");
		}
		Stack.setChannel(1);
	} else {
		run("Grays");
		run("Enhance Contrast", "saturated=0.35");
	}
	// also show B&C and Channels tools
	run("Brightness/Contrast...");
	run("Channels Tool...");
}


macro "Open Series [O]" {
	// macro to list all series in multi-series file and open one
	message = "Choose multi-series file to list contents";
	showMessage(message);
	msFile = File.openDialog(message);
	folder = File.getParent(msFile);
	
	run("Bio-Formats Macro Extensions");
	
	Ext.setId(msFile);  // initialize file
	Ext.getSeriesCount(seriesCount);
	print("### Open Series Macro ###");
	print("Multi-series file " + File.getName(msFile) + " contains " + seriesCount + " series:");
	
	for (n = 0; n < seriesCount; n++) {
		Ext.setSeries(n);
		Ext.getSeriesName(seriesName);
		Ext.getImageCount(nPlanes);
		Ext.getSizeX(nx);
		Ext.getSizeY(ny);
		Ext.getSizeZ(nz);
		Ext.getSizeC(nc);
		Ext.getSizeT(nt);
		dimensionString = "; " + nx + " x " + ny + ";";
		dimensionString += " " + nPlanes + " planes";
		dimensionString += " (" + nz + "Z/" + nc + "C/" + nt + "T)"; 
		print("  Series  " + n + ": " + seriesName + dimensionString);
	}

	if (seriesCount > 1) {
		Dialog.createNonBlocking("Open Series");
		Dialog.addNumber("Choose series number to open", 0);
		Dialog.show();
		seriesToOpen = Dialog.getNumber();
	} else {
		seriesToOpen = 0;
	}
	
	Ext.setSeries(seriesToOpen);
	Ext.openImagePlus(msFile);
}


macro "Plot Multichannel Profiles [K]" {
	// macro to plot line profiles for all channels using current line selection
	// - requires function hexColor()
	inpID = getImageID();
	st = selectionType();
	if (st == 0 || st == 5 || st == 6 || st == 7) {
		setBatchMode("hide");
		if (bitDepth() == 24) {
			// RGB - convert to hyperstack for multi-channel profile
			run("Duplicate...", " ");
			run("RGB Stack");
			run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Composite");
			run("Restore Selection");
		}
		getDimensions(w, h, nc, nz, nt);
		if (nc > 1) {
			Stack.setDisplayMode("composite");  // for color LUTs
			colors = newArray();  // array for hex color strings
			yValues = newArray();  // array for all y values for all channels
			for (channel = 1; channel <= nc; channel++) {
				Stack.setChannel(channel);
				getLut(R, G, B);
				colorString = hexColor(R[R.length-1], G[G.length-1], B[B.length-1]);
				colors = Array.concat(colors, colorString);
				run("Plot Profile");
				Plot.getValues(xvals, yvals);
				yValues = Array.concat(yValues, yvals);
				close();
			}
			nPoints = xvals.length;
			Stack.getUnits(xu, yu, zu, tu, vu);
			Plot.create("Multichannel Line Profile", "Distance (" + xu + ")", "Gray Value");
			for (c = 1; c <= nc; c++) {
				Plot.setColor(colors[c-1]);
				offset = (c-1) * nPoints;
				yvals = Array.slice(yValues, offset, offset+nPoints-1);
				Plot.add("line", xvals, yvals);
			}
			Plot.setLimitsToFit();
			selectImage(inpID);
			Stack.setChannel(1);
		} else {
			// just 1 channel so run Plot Profile command
			run("Plot Profile");
		}
		setBatchMode("exit and display");	
	} else {
		showMessage("Plot Multichannel Profiles", "Line or rectangular selection required");
	}
}

macro "Close All Windows [W]" {
    // macro to close all open windows, including non-image
    // - apart from Recorder!
    imageList = getList("image.titles");
    if (imageList.length > 0) {
        run("Close All");  // images only
    }
    windowList = getList("window.titles");
    for (i = 0; i < windowList.length; i++){
        winName = windowList[i];
        if (winName != "Recorder") {
            selectWindow(winName);
            run("Close");
        }
    }
}

macro "Recorder [R]" {
    // open macro recorder
    run("Record...");
}

macro "Script [S]" {
    // start new script in script editor
    run("Script...");
}

macro "Marshal Tool Windows [M]" {
    // arrange Channels, B&C and ROI Manager windows around active image
    marshalScript = 
    "imageTitle = IJ.getImage().getTitle();\n"+
    "iw = WindowManager.getWindow(imageTitle);\n"+
    "if (iw!=null) {\n"+
    	// make sure Channels, B&C and ROI Manager are open
    	"  if (WindowManager.getWindow('Brightness/Contrast...')==null) {\n"+
    		"  IJ.run('Brightness/Contrast...');}\n"+
    	"  if (WindowManager.getWindow('Channels Tool...')==null) {\n"+
    		"  IJ.run('Channels Tool...');}\n"+
    	"  if (WindowManager.getWindow('ROI Manager...')==null) {\n"+
    		"  IJ.run('ROI Manager...');}\n"+
    	// get sizes and initial locations
	    "  iloc = iw.getLocationOnScreen();\n"+
    	"  idim = iw.getSize();\n"+
    	"  bcw = WindowManager.getWindow('B&C');\n"+
    	"  bcWidth =  bcw.getSize().width;\n"+
    	"  bcHeight =  bcw.getSize().height;\n"+
    	"  ctw = WindowManager.getWindow('Channels');\n"+
    	"  ctWidth =  ctw.getSize().width;\n"+
    	"  rmw = WindowManager.getWindow('ROI Manager');\n"+
    	// TODO: move image window if too high / left
    	// set tool positions relative to image window
    	"  bcw.setLocation(iloc.x-bcWidth, iloc.y);\n"+
    	"  ctw.setLocation(iloc.x-ctWidth, iloc.y+bcHeight);\n"+
    	"  rmw.setLocation(iloc.x+idim.width, iloc.y);\n"+
    	// bring image window back to front
    	"  iw.toFront();\n"+
    "}\n";
    eval("script", marshalScript);
}

