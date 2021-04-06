input="/Users/Alex.H/Desktop/projet bin/Premier_set_results/";
output="/Users/Alex.H/Desktop/projet bin/output_1er_set/";
suffix=".tif";

processFolder(input);

// function to scan folders/subfolders/files to find files with correct suffix
function processFolder(input) {
	list = getFileList(input);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(input + File.separator + list[i]))
			processFolder(input + File.separator + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

function processFile(input, output, file) {
	// Do the processing here by adding your own code.
	open(input + File.separator + file);
	
name = getTitle; 
dotIndex = indexOf(name, "."); 
title = substring(name, 0, dotIndex);

run("Reverse");
//run("Brightness/Contrast...");
resetMinAndMax();
saveAs("TIFF", output+title);
close();
}