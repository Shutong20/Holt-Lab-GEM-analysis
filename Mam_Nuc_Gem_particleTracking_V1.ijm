
// beter tracking script was lost - need to figure out again how to get robust particle detection.
mainDir = getDirectory("Choose a main directory "); 
mainList = getFileList(mainDir); 


for (i=0; i<mainList.length; i++) {  // for loop to parse through names in main folder

     if(endsWith(mainList[i], "/")){  

          subDir = mainDir + mainList[i]; 
          processFiles(subDir);
  
          } 
     } 


// value passed as subDir is known as 'dir' in the downstream analysis


function processFiles(subDir) {
	Classify_nuclei(subDir);
	Create_segmented_GEMs(subDir);
	Track_nuclear_Gems(subDir);
}

function Classify_nuclei(dir){

		//===============================
		
		run("Bio-Formats Macro Extensions");
		
		//Looping function through the files in a directory to open and track them
		
		list = getFileList(dir);
		  for (i=0; i<list.length; i++) {
		    if (endsWith(list[i], "A.nd2")) { 
		    Ext.openImagePlus(dir+list[i]);
		Masktitle = getTitle();
		      saveTitle = replace(Masktitle, ".nd2", "");
		
		// Script to segment nuclei from images - then track mam nuclear GEMs
		run("Subtract Background...", "rolling=5 sliding");
		//run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		run("Convolve...", "text1=[-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 24 -1 -1\n-1 -1 -1 -1 -1\n-1 -1 -1 -1 -1\n] normalize");
		run("Enhance Contrast", "saturated=0.35");
		
		classifierDir  = File.openDialog("Choose a the classifier model");  
		
		run("Trainable Weka Segmentation");
		wait(3000);
		//selectWindow("Trainable Weka Segmentation v3.2.28");
		call("trainableSegmentation.Weka_Segmentation.loadClassifier", classifierDir);
		call("trainableSegmentation.Weka_Segmentation.getResult");
		//call("trainableSegmentation.Weka_Segmentation.applyClassifier", dir, Masktitle, "showResults=true", "storeResults=false", "probabilityMaps=false", "");
		
	selectWindow("Classified image");
		
		setAutoThreshold("MaxEntropy");
		//setThreshold(1, 255);
		setOption("BlackBackground", false);
		run("Convert to Mask");
		
		
		run("Fill Holes");
		run("Fill Holes");
		run("Open");
		
		//run("Watershed");
		run("Analyze Particles...", "size=40-Infinity circularity=0.20-1.00 show=Masks display include in_situ");
		
		saveAs("Tiff", dir + list[i] + "_Classification_");
		//waitForUser
		run("Close All");
		//call("java.lang.System.gc");
		
		    }
		  }
		}
function Create_segmented_GEMs(dir){
			//dir = getDirectory("Choose Source Directory ");
		//dir2 = getDirectory("Choose Destination Directory Results ");
		//===============================
		// ok going to need to go to the folders one at a time and load dapi then GEMs file
		
		
		run("Bio-Formats Macro Extensions");
		list = getFileList(dir);
		  for (i=0; i<list.length; i++) {
		    if (endsWith(list[i], "_Classification_.tif")) { 
		    Ext.openImagePlus(dir+list[i]);
		// nowloop though
		
		run("Watershed");
		run("Analyze Particles...", "size=40-Infinity circularity=0.20-1.00 show=Masks display include in_situ");
		
		setAutoThreshold("Default dark");
		//run("Threshold...");
		run("Create Mask");
		run("Create Selection");
		    }
		  }
		
		//run("Close All");
		
		//dir2 = getDirectory("Choose Destination Directory Results ");
		//===============================
		// ok going to need to go to the folders one at a time and load dapi then GEMs file
		
		//dir1 = getDirectory("Choose Source Directory ");
		run("Bio-Formats Macro Extensions");
		
		list = getFileList(dir);
		  for (i=0; i<list.length; i++) {
		    if (endsWith(list[i], "B.nd2")) { 
		    Ext.openImagePlus(dir+list[i]);
		    Masktitle = getTitle();
		    saveTitle = replace(Masktitle, ".tif", "");
		wait(1000);
		run("Restore Selection");
		
		
		run("Enhance Contrast", "saturated=0.35");
		setBackgroundColor(0, 0, 0);
		run("Clear", "slice");
		
		setBackgroundColor(0,0,0);
		run("Clear", "stack");
		run("Select None");
		
		saveAs("Tiff", dir + list[i] + "GEM_Nuclei_Seg");
		//waitForUser
		run("Close All"); // this segments out the nuclei and saves the new nuclei movies
		    }
		  }
			}

function Track_nuclear_Gems(dir){
			run("Bio-Formats Macro Extensions");
		list = getFileList(dir);
		  for (i=0; i<list.length; i++) {
		    if (endsWith(list[i], "GEM_Nuclei_Seg.tif")) { 
		    Ext.openImagePlus(dir+list[i]);
		// nowloop though
		
		
		run("Smooth", "stack");
		run("Gaussian Blur...", "sigma=2 stack");
		run("Enhance Contrast", "saturated=0.35");
		run("Find Edges", "stack");
		setMinAndMax(2, 343);
		setMinAndMax(2, 343);
		setAutoThreshold("Otsu dark no-reset");
		setOption("BlackBackground", false);
		run("Convert to Mask", "method=Otsu background=Dark calculate");
		run("Dilate", "stack");
		run("Dilate", "stack");
		setAutoThreshold("Otsu dark");
		//run("Threshold...");
		run("Create Mask");
		run("Create Selection");
		
		    }
		  }
		// So up to here you get a outline of the poorly segmented areas around the nuclei, then you load the nuclear GEM movie with just the nuclei again and subtract this then threshold for GEMs
		//dir = getDirectory("Choose Source Directory ");
		//dir2 = getDirectory("Choose Destination Directory Results ");
		//===============================
		// ok going to need to go to the folders one at a time and load dapi then GEMs file
		
		
		run("Bio-Formats Macro Extensions");
		list = getFileList(dir);
		  for (i=0; i<list.length; i++) {
		    if (endsWith(list[i], "GEM_Nuclei_Seg.tif")) { 
		    Ext.openImagePlus(dir+list[i]);
		
		run("Enhance Contrast...", "saturated=0.001 normalize equalize process_all use");
		run("Subtract Background...", "rolling=4 stack");
		run("Restore Selection");
		run("Clear Outside", "stack");
		
		run("Smooth", "stack");
		setAutoThreshold("MaxEntropy dark no-reset");
		run("Convert to Mask", "method=MaxEntropy background=Dark calculate");
		// 
		run("Enhance Contrast", "saturated=0.35");
		
		setAutoThreshold("MaxEntropy no-reset");
		run("Convert to Mask", "method=MaxEntropy background=Light");
		doCommand("Start Animation [\\]");
		run("Invert", "stack");
		run("Smooth", "stack");
		
		// then track or use analyze particles to get list and load into mosaic
		SingleParticleTracking(dir);
		
		function SingleParticleTracking(destination) {
		run("Particle Tracker 2D/3D", "radius=4 cutoff=0 per/abs=0.08 link=1 displacement=5 dynamics=Brownian");
		run("Close All");
		}
		    }
		  }
			}
	