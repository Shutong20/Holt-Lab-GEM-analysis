//Select Directories
dir1 = getDirectory("Choose Source Directory ");

//===============================


run("Bio-Formats Macro Extensions");

//Looping function through the files in a directory

list = getFileList(dir1);
  for (i=0; i<list.length; i++) {
    if (endsWith(list[i], ".nd2")) { 
    Ext.openImagePlus(dir1+list[i]);
Masktitle = getTitle();
      saveTitle = replace(Masktitle, ".jpg", "");


saveAs("jpg", dir1 + saveTitle); 
close(); 

}
}

