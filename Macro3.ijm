//use this one for human-in-the-loop on every one

Table.create("Final Results");
run("Set Measurements...", "mean redirect=None decimal=0");
run("Options...", "iterations=3 count=1 pad do=Nothing");
run("Add to Manager");


//allow user to select folder
Dialog.create("Choose A Folder");
Dialog.addDirectory("Images Folder", "");
Dialog.show();
path = Dialog.getString();

setBatchMode(true);


//runs the function on all czi files in the folder
files = getFileList(path);
for (i = 0; i < files.length; i++) {
	if (endsWith(files[i], ".czi")) {
		run("Bio-Formats Importer", "open=["+path+files[i]+"] color_mode=Default rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
		name = getTitle();
		means = MeasureCell();
		size = Table.size("Final Results");
		Table.set("Name", size, name, "Final Results");
		Table.set("Yellow Int", size, means[0], "Final Results");
		Table.set("Yellow Backgnd", size, means[3], "Final Results");
		Table.set("Blue Int", size, means[2], "Final Results");
		Table.set("Blue Backgnd", size, means[5], "Final Results");
		Table.set("Ratio", size, (means[0] - means[3]) / (means[2] - means[5]), "Final Results");
		//Table.set("# ROIs", size, means[6], "Final Results");
		close("*");
	}
}



function MeasureCell() {
	// returns the mean intensities of the chosen cell and background in the image
	rename("Image");
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(3);
	run("Enhance Contrast", "saturated=0.35");
	Stack.setChannel(1);
	run("Duplicate...", " ");
	run("Despeckle");
	setThreshold(4000, 65535, "raw");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Dilate");
	run("Fill Holes");
	run("Erode");
	run("Analyze Particles...", "size=0.5-Infinity add");
	close("Image-1");
	
	setBatchMode("exit and display");
	roiManager("show all with labels");
	waitForUser("Please fix segmentation");
	setBatchMode("hide");
	
	while (roiManager("count") != 1) {
		setBatchMode("exit and display");
		roiManager("show all with labels");
		waitForUser("Please fix segmentation");
		setBatchMode("hide");
	}


	roiManager("Select", 0);
	run("Make Inverse");
	roiManager("Add");
	roiManager("Deselect");
	roiManager("Multi Measure");
	mean1 = Table.getColumn("Mean1", "Results");
	mean2 = Table.getColumn("Mean2", "Results");
	means = Array.concat(mean1,mean2);
	run("Clear Results");
	roiManager("reset");
	return means;
}





