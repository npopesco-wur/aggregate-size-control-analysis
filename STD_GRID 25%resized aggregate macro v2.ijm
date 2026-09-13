// 1. Prompt the user to select the master BATCH folder
batchDir = getDirectory("Choose your main BATCH directory");
outputDir = getDirectory("Choose the output directory for the CSV results");

// 2. Clear any existing results and ROI manager
run("Clear Results");
if (isOpen("ROI Manager")) {
    roiManager("reset");
}

// 3. Set Measurements once
run("Set Measurements...", "area standard perimeter shape display redirect=None decimal=1");

// 4. Start the recursive processing
processFolder(batchDir);

// 5. After ALL folders are processed, save the single consolidated CSV
batchName = File.getName(batchDir);
saveAs("Results", outputDir + batchName + "_Master_Combined_Results.csv");

// 6. Clean up workspace and notify user
if (isOpen("ROI Manager")) {
    selectWindow("ROI Manager");
    run("Close");
}
print("Batch processing complete! Master dataframe saved as: " + batchName + "_Master_Combined_Results.csv");

// --- This is the recursive function that handles the subfolders ---
function processFolder(currentDir) {
    list = getFileList(currentDir);
    
    for (i = 0; i < list.length; i++) {
        // If it's a subfolder, dig deeper
        if (endsWith(list[i], "/")) {
            processFolder(currentDir + list[i]);
        } 
        // If it's an image file, process it
        else if (endsWith(list[i], ".tif") || endsWith(list[i], ".jpg") || endsWith(list[i], ".png")) {
            
            open(currentDir + list[i]);
            
            // --- YOUR MACRO START ---
            run("Set Scale...", "distance=91 known=400 unit=µm");        
            
            // 1. Get the minimum and maximum pixel values of the original image
            getMinAndMax(min, max);
            
            // 2. Set the threshold dynamically from 1 to the image's actual maximum
            setThreshold(1, max, "raw");
            
            // 3. Convert directly to a mask (ImageJ handles the bit conversion automatically here)
            setOption("BlackBackground", true);
            run("Convert to Mask");
            
            run("Watershed");
            run("Analyze Particles...", "display exclude"); 
            // --- YOUR MACRO END ---
            
            close(); 
        }
    }
}