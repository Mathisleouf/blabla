
/*
 * Macro template to process multiple images in a folder
 */

input="/Users/nicolas/OneDrive/transit/26_01_2021/test/";
output="/Users/nicolas/OneDrive/transit/Results/";
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
	run("Bio-Formats", "open=" + input + File.separator + file+" autoscale color_mode=Grayscale rois_import=[ROI manager] view=Hyperstack stack_order=XYCZT");
	
name = getTitle; 
dotIndex = indexOf(name, "."); 
title = substring(name, 0, dotIndex); 

Stack.setChannel(2);
run("Duplicate...", "duplicate channels=2");
run("8-bit");

setAutoThreshold("RenyiEntropy dark no-reset");
//setThreshold(33, 255);
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=1000-Infinity pixel circularity=0.20-1.00 exclude clear add in_situ");

ROIcount=roiManager("count");

//Select channel 1
selectWindow(name);
Stack.setChannel(1);//Measure channel 1
for (i = 0; i < ROIcount; i++) {
			roiManager("select", i);
			roi_name=Roi.getName;
			Roi.getBounds(x, y, width, height);
			max=maxOf(width, height);
			new_width=width/5;
			run("Measure");
			run("To Bounding Box");
			run("Enlarge...", "enlarge=new_width pixel");
			run("Duplicate...", "title=blabla");
			rename(title+"_"+roi_name);
			transit=getTitle();
			saveAs("PNG", output+"EdU/EdU_"+transit);
			close();
			selectWindow(name);
}

Marker="EdU";
  for (j=0; j<nResults; j++) {
    oldLabel = getResultLabel(j);
    delimiter = indexOf(oldLabel, ":");
    roiManager("select", j);
	roi_name=Roi.getName;
    newLabel = Marker+"_"+title+"_"+roi_name;
    setResult("Label_"+Marker, j, newLabel);
    setResult("Nucleus_ROI", j, title+"_"+roi_name);
  }
	Table.renameColumn("Mean", "Mean_"+Marker);
    Table.renameColumn("IntDen", "IntDen_"+Marker);
    Table.renameColumn("Median", "Median_"+Marker);
    Table.renameColumn("RawIntDen", "RawIntDen_"+Marker);
	Table.deleteColumn("Area");
    Table.deleteColumn("Min");
    Table.deleteColumn("Max");
    Table.deleteColumn("X");
    Table.deleteColumn("Y");
    Table.deleteColumn("Perim.");
	Table.rename("Results", "EdU");
	saveAs("Results", output+"Tables/E_"+title+".csv");
	close("E"+title+".csv");


//Select channnel 2
selectWindow(name);
Stack.setChannel(2);//Measure channel 2
for (i = 0; i < ROIcount; i++) {
			roiManager("select", i);
			roi_name=Roi.getName;
			Roi.getBounds(x, y, width, height);
			max=maxOf(width, height);
			new_width=width/5;
			run("Measure");
			run("To Bounding Box");
			run("Enlarge...", "enlarge=new_width pixel");
			run("Duplicate...", "title=blabla");
			rename(title+"_"+roi_name);
			transit=getTitle();
			saveAs("PNG", output+"Hoechst/Hoechst_"+transit);
			close();
			selectWindow(name);
}

Marker="Hoechst";
  for (j=0; j<nResults; j++) {
    oldLabel = getResultLabel(j);
    delimiter = indexOf(oldLabel, ":");
    roiManager("select", j);
	roi_name=Roi.getName;
    newLabel = Marker+"_"+title+"_"+roi_name;
    setResult("Label_"+Marker, j, newLabel);
    setResult("Nucleus_ROI", j, title+"_"+roi_name);
  }
	Table.renameColumn("Mean", "Mean_"+Marker);
    Table.renameColumn("IntDen", "IntDen_"+Marker);
    Table.renameColumn("Median", "Median_"+Marker);
    Table.renameColumn("RawIntDen", "RawIntDen_"+Marker);
    Table.deleteColumn("Min");
    Table.deleteColumn("Max");
    Table.deleteColumn("X");
    Table.deleteColumn("Y");
    Table.rename("Results", "Hoechst");
	saveAs("Results", output+"Tables/H_"+title+".csv");
	close("Hoechst_"+title+".csv");


close(name);
close(title+"-1.dv");

if (isOpen("ROI Manager")) {
       selectWindow("ROI Manager"); 
       run("Close" );
}
	
one=output+"Tables/E_"+title+".csv";
two=output+"Tables/H_"+title+".csv";

     lineseparator = "\n";
     cellseparator = ",\t";

     // copies the whole RT to an array of lines
     lines=split(File.openAsString(one), lineseparator);

     // recreates the columns headers
     labels=split(lines[0], cellseparator);
     if (labels[0]==" ")
        k=1; // it is an ImageJ Results table, skip first column
     else
        k=0; // it is not a Results table, load all columns
     for (j=k; j<labels.length; j++)
        setResult(labels[j],0,0);

     // dispatches the data into the new RT
     //run("Clear Results");
     for (i=1; i<lines.length; i++) {
        items=split(lines[i], cellseparator);
        for (j=k; j<items.length; j++)
           setResult(labels[j],i-1,items[j]);
     }
     updateResults();

     lines=split(File.openAsString(two), lineseparator);

     // recreates the columns headers
     labels=split(lines[0], cellseparator);
     if (labels[0]==" ")
        k=1; // it is an ImageJ Results table, skip first column
     else
        k=0; // it is not a Results table, load all columns
     for (j=k; j<labels.length; j++)
        setResult(labels[j],0,0);

     // dispatches the data into the new RT
     //run("Clear Results");
     for (i=1; i<lines.length; i++) {
        items=split(lines[i], cellseparator);
        for (j=k; j<items.length; j++)
           setResult(labels[j],i-1,items[j]);
     }
     updateResults();

	saveAs("Results", output+"Final/"+title+".csv");
	run("Clear Results");

if (isOpen("E_"+title+".csv")) {
         selectWindow("H_"+title+".csv"); 
         run("Close" );
}

if (isOpen("E_"+title+".csv")) {
         selectWindow("E_"+title+".csv"); 
         run("Close" );
}

if (isOpen("ROI Manager")) {
       selectWindow("ROI Manager"); 
       run("Close" );
}
		
     
}

    