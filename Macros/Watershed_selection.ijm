macro "Watershed selection [w]" {
    // watershed inside a rectangular selection (for binary image)
	if (selectionType() == 0) {
		run("Duplicate...", " ");
		run("Watershed");
		run("Select All");
		run("Copy");
		close();
		run("Paste");
	}
}