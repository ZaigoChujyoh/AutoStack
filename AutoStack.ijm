//作業ディレクトリの選択
showMessage("Select Open Folder");
dir = getDirectory("Choose a Directory");
list = getFileList(dir); //作業ディレクトリの中にあるファイルのリスト

//データ保存用のディレクトリを作成
savedir = dir + "stack\\"
if(!File.exists(savedir)){
	File.makeDirectory(savedir)
};

col = newArray("Green", "Magenta", "Cyan"); //お好きな色でどうぞ

//main
for(j=0; j<list.length; j++){
	name = list[j];
	//open(dir+name);
	path = dir+name;
	run("Bio-Formats Importer", "open=path");
	extention = indexOf(name, ".");
	namewithoutextension = substring(name, 0, extention); //元データは"namewithoutextension.extension"
	
	run("Z Project...", "projection=[Max Intensity]"); //Stack
	close(name); //元ファイルを閉じる
	
	Stack.getDimensions(width, height, channels, slices, frames); //チャンネル数を取得
	
	//各チャンネルの色を変更・コントラストの調整
	for(k=0; k<channels; k++){
		Stack.setChannel(k+1);
		run(col[k]);
		run("Enhance Contrast", "saturated=0.35");
	}
	
	//Merge channels
	Property.set("CompositeProjection", "Sum");
	Stack.setDisplayMode("composite");
	
	//Save
	saveAs("png", savedir + namewithoutextension + "_stack.png");
	close("MAX_"+name);
	close();
	
	//表示モードを元に戻す
	Property.set("CompositeProjection", "null");
	Stack.setDisplayMode("color");
}
