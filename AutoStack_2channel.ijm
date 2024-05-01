//作業ディレクトリの選択
showMessage("Select Open Folder");
dir = getDirectory("Choose a Directory");
list = getFileList(dir); //作業ディレクトリの中にあるファイルのリスト

//データ保存用のディレクトリを作成
savedir = dir + "stack\\"
if(!File.exists(savedir)){
	File.makeDirectory(savedir)
};

//main
for(j=0; j<list.length; j++){
	name = list[j];
	open(dir+name);
	extention = indexOf(name, ".");
	sub = substring(name, 0, extention); //元データは"sub.extension"
	
	run("Z Project...", "projection=[Max Intensity]"); //Stack
	close(name);
	
	//Channel1
	Stack.setChannel(1);
	run("Green");
	run("Enhance Contrast", "saturated=0.35");
	
	//Channel2
	Stack.setChannel(2);
	run("Magenta");
	run("Enhance Contrast", "saturated=0.35");
	
	//Merge channels
	run("Channels Tool...");
	Property.set("CompositeProjection", "Sum");
	Stack.setDisplayMode("composite");
	
	//Save
	saveAs("png", savedir + sub + "_stack.png");
	close("MAX_"+name);
	close();
}
