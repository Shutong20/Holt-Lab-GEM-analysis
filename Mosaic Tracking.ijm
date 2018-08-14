//Select Directories
dir1 = getDirectory("Choose Source Directory ");
dir2 = getDirectory("Choose Destination Directory Results ");
//===============================


run("Bio-Formats Macro Extensions");

//Looping function through the files in a directory

list = getFileList(dir1);
  for (i=0; i<list.length; i++) {
    if (endsWith(list[i], ".nd2")) { 
    Ext.openImagePlus(dir1+list[i]);
Masktitle = getTitle();
      saveTitle = replace(Masktitle, ".nd2", "");
SingleParticleTracking(dir2);

}
}

function SingleParticleTracking(destination) {
run("Particle Tracker 2D/3D", "radius=3 cutoff=0 per/abs=0.1 link=1 displacement=6 dynamics=Brownian");
run("Close All");
}
