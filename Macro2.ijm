//use this one for human-in-the-loop segmenting only for problematic ones

Table.create("Final Results");
run("Set Measurements...", "mean redirect=None decimal=0");
run("Options...", "iterations=3 count=1 pad do=Nothing");

//allow user to select folder
Dialog.create("Choose A Folder and Background levels");
Dialog.addDirectory("Images Folder", "");
Dialog.addNumber("Yellow Background", 0);
Dialog.addNumber("Blue Background", 0);
Dialog.show();
path = Dialog.getString();
yback = Dialog.getNumber();
bback = Dialog.getNumber();

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
		Table.set("Yellow Backgnd", size, yback, "Final Results");
		Table.set("Blue Int", size, means[2], "Final Results");
		Table.set("Blue Backgnd", size, bback, "Final Results");
		Table.set("Ratio", size, (means[0] - yback) / (means[2] - bback), "Final Results");
		close("*");
	}
}



function MeasureCell() {
	// returns the mean intensities of the chosen cell and background in the image
	rename("Image");
	run("Duplicate...", " ");
	run("Despeckle");
	setThreshold(4000, 65535, "raw");
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Dilate");
	run("Fill Holes");
	run("Erode");
	
	setBatchMode("exit and display");
	waitForUser("Please fix segmentation");
	setBatchMode("hide");
	
	run("Analyze Particles...", "size=0.5-Infinity add");
	close("Image-1");
	roiManager("Multi Measure");
	means = Table.getColumn("Mean1", "Results");
	run("Clear Results");
	roiManager("reset");
	return means;
}





