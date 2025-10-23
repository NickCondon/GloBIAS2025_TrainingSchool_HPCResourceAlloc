//Modified by Nicholas Condon (n.condon@uq.edu.au)

/*
 * Script: Image Destacker
 * 
 * Description: TTakes a folder of images and runs a user specified filter on them.
 * 
 * Input Requirements:
 *    input (string to file location) - AUTOPOPULATED
 *    output (string to file location) - AUTOPOPULATED
 *    suffix (string of file extension) - E.G .tif / .czi / .lif
 *    frames (boolean for frame dimension) - E.G. 1-on, 0-off
 *    slices (boolean for slices dimension) - E.G. 1-on, 0-off
 *    channels (boolean for channels dimension) - E.G. 1-on, 0-off
 */


//Written to run on the Institute for Molecular Bioscience & Research Computing Centre's Image Processing Portal
//see ipp.rcc.uq.edu.au for more info



// Original ImageJ Macro Script that loops through files in a directory written by Adam Dimech
// https://code.adonline.id.au/imagej-batch-process-headless/


startime = getTime();
// If headless, getArgument() will contain the command-line parameters
// If running interactively, getArgument() is empty


// Specify global variables

#@ String input
#@ String output
#@ String suffix
#@ String frames
#@ String slices
#@ String channels
#@ Boolean(label="Kill Fiji on Finish?") exitFiji

framesArg=frames;
slicesArg=slices;
channelsArg=channels;




fs = File.separator;
run("Bio-Formats Macro Extensions");


// Add trailing slashes
input=input+fs;
//output = input+fs+"Output"+fs;
outputDir =output;

File.makeDirectory(outputDir);

choiceFrames = frames;
choiceSlices = slices;
choiceChannels = channels;

print("\\Clear");
print("");print("");print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");
print("Image Splitter");
print("");
print("* * * * * * * * * * * * * * * * * * * * * * *");
print("");print("");print("");


processFolder(input);

// Scan folders/subfolders/files to locate files with the correct suffix

function processFolder(input) {
	list = getFileList(input);
	for (i = 0; i < list.length; i++) {
	//	if(File.isDirectory(input + list[i]))
	//		processFolder("" + input + list[i]);
		if(endsWith(list[i], suffix))
			processFile(input, output, list[i]);
	}
}

// Loop through each file

function processFile(input, output, file) {

// Define all variables

Months = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"); // Generate month names
DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat"); // Generate day names
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
timestamp ="";
if (dayOfMonth<10) {timestamp = timestamp+"0";}
timestamp = ""+DayNames[dayOfWeek]+" "+Months[month]+" "+dayOfMonth+" "+year+", "+timestamp;
if (hour<10) {timestamp = timestamp+"0";}
timestamp = timestamp+""+hour;
if (minute<10) {timestamp = timestamp+"0";}
timestamp = timestamp+":"+minute+"";
if (second<10) {timestamp = timestamp+"";}
timestamp = timestamp+":"+msec;

// Do something to each file
Ext.openImagePlus(input+file)
print (timestamp + ": Processing " + input + file); 

windowtitle = getTitle();
windowtitlenoext = replace(windowtitle, suffix, "");

resultsDir = output+fs+windowtitlenoext+"_Destacked"+fs;
File.makeDirectory(resultsDir);
d = Stack.getDimensions(width, height, channels, slices, frames); 

//Loops through each frame of the stack until total frames are saved out individually
		if (choiceFrames==1 && choiceSlices==0 && choiceChannels==0){
			for (i=0; i<frames; i++){
				fr=i+1;
				Stack.setFrame(i); 
				run("Reduce Dimensionality...", "slices channels keep"); 
				rename(windowtitlenoext+"_t"+fr);
			 	finalname = getTitle();
				print("Saving Frame # "+fr+" of "+frames);
				saveAs("Tiff", resultsDir+ finalname+".tif"); 
				close();}}

		//Loops through each frame and slice until all are saved		
		if (choiceFrames==1 && choiceSlices==1 && choiceChannels==0){
				for (i=0; i<frames; i++){
				fr=i+1;
				Stack.setFrame(i); 
				run("Reduce Dimensionality...", "slices channels keep"); 
				rename(windowtitlenoext+"_t"+fr);
				for (s=0; s<slices; s++){
					sl=s+1;
					Stack.setSlice(s); 
					run("Reduce Dimensionality...", "channels keep"); 
					rename(windowtitlenoext+"_t"+fr+"_z"+sl);
					finalname = getTitle();
					print("Saving Frame # "+fr+" of "+frames+" Slice # "+sl);
					saveAs("Tiff", resultsDir+ finalname+".tif"); 
					close();}
					close();
					}}

		//Loops through each frame, slice, and channel, until all are saved
		if (choiceFrames==1 && choiceSlices==1 && choiceChannels==1){
				//i=1;s=1;c=1;
				for (i=0; i<frames; i++){ 
					Stack.setFrame(i); 
					run("Reduce Dimensionality...", "slices channels keep"); 
					rename(windowtitlenoext+"_t"+i);
					fr=i+1;
				 	for (s=0; s<slices; s++){ 
				 		Stack.setSlice(s);
						run("Reduce Dimensionality...", "channels keep"); 
						rename(windowtitlenoext+"_t"+fr+"_z"+s);
						sl=s+1;
						for (c=0; c<channels; c++){
							ch=c+1;
							run("Duplicate...", "duplicate channels="+ch);
							rename(windowtitlenoext+"_t"+fr+"_z"+sl+"_c"+ch);
							finalname = getTitle();
							print("Saving Frame # "+fr+" of "+frames+" Slice # "+sl+" of "+slices+" Channel # "+ch+" of "+channels);
							saveAs("Tiff", resultsDir+ finalname+".tif"); 
							close();
							}
						close();
						}
					close(); 
						}
						}

		//saves out only channels
		if (choiceFrames==0 && choiceSlices==0 && choiceChannels==1){
				for (c=0; c<channels; c++){
					ch=c+1;
					run("Duplicate...", "duplicate channels="+ch);
					rename(windowtitlenoext+"_c"+ch);
					finalname = getTitle();
					print("Saving Channel # "+ch+" of "+channels);
							saveAs("Tiff", resultsDir+ finalname+".tif"); 
							close();
							}
		}

		//saves out slices and channels
		if (choiceFrames==0 && choiceSlices==1 && choiceChannels==0){
				for (s=0; s<slices; s++){
					sl=s+1;
					Stack.setSlice(s); 
					run("Reduce Dimensionality...", "frames channels keep"); 
					rename(windowtitlenoext+"_z"+sl);
					finalname = getTitle();
					print("Saving Slice # "+sl+" of "+slices);
					saveAs("Tiff", resultsDir+ finalname+".tif"); 
					close();}
					}

		//saves out frames and channels
		if (choiceFrames==1 && choiceSlices==0 && choiceChannels==1){
				//i=1;s=1;c=1;
				for (i=0; i<frames; i++){ 
					Stack.setFrame(i); 
					run("Reduce Dimensionality...", "slices channels keep"); 
					rename(windowtitlenoext+"_t"+i);
					fr=i+1; 	
					for (c=0; c<channels; c++){
							ch=c+1;
							run("Duplicate...", "duplicate channels="+ch);
							rename(windowtitlenoext+"_t"+fr+"_c"+ch);
							finalname = getTitle();
							print("Saving Frame # "+fr+" of "+frames+" Channel # "+ch+" of "+channels);
							saveAs("Tiff", resultsDir+ finalname+".tif"); 
							close();
							}
						close();
						}
					 close(); close();
						}
						while(nImages>0){selectImage(nImages);close();}
	}
getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	
	// --- File paths ---
	originalPath = "/home/GloBIAS_2025/BARD_Fiji/Spliter_interactive.ijm";
	homeDir = getDirectory("home");
	newMacroPath = homeDir+"Desktop/Spliter_headless_" + year + "-" + (month+1) + "-" + dayOfMonth + "_" + hour + "-" + minute + ".ijm";
	
	// --- Read the original script ---
	originalScript = File.openAsString(originalPath);
	lines = split(originalScript, "\n");
	
	// --- Check if original script is already auto-generated ---
	if (startsWith(lines[0], "// Auto-generated headless version of Spliter_.ijm")) {
	    print("Headless version already exists or was generated earlier — skipping file generation.");
	} else {
	    print("Generating new headless version...");
	    
	    // Start with a header
	    File.append("// Auto-generated headless version of Spliter_.ijm\n", newMacroPath);
	    File.append("// Created on: " + year + "-" + (month+1) + "-" + dayOfMonth + "\n\n", newMacroPath);
	    
	    // Write hardcoded variable assignments
	    File.append("input = \"" + input + "\";\n", newMacroPath);
	    File.append("output = \"" + output + "\";\n", newMacroPath);
	    File.append("suffix = \"" + suffix + "\";\n", newMacroPath);
	    File.append("frames = \"" + framesArg + "\";\n", newMacroPath);
	    File.append("slices = \"" + slicesArg + "\";\n", newMacroPath);
	    File.append("channels = \"" + channelsArg + "\";\n", newMacroPath);
	    File.append("exitFiji = " + exitFiji + ";\n\n", newMacroPath);
	    
	    // Append the rest of the macro, skipping the #@ lines
	    for (i = 0; i < lines.length; i++) {
	        line = lines[i];
	        if (startsWith(line, "#@")) continue;
	        if (startsWith(line, "args = ")) continue;
	        File.append(line + "\n", newMacroPath);
	    }
	    
	    // --- Print the suggested headless command ---
	    headlessCmd = "fiji --headless --console " + newMacroPath;
	    print("----- Suggested headless command -----");
	    print(headlessCmd);
	    print("-------------------------------------");
	}


// A final statement to confirm the task is complete...

print("Task complete.");
print("Runtime = "+(startime-getTime())/1000+"s");
if (exitFiji) {
    eval("script", "System.exit(0);")
}
