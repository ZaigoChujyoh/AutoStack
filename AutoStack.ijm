//作業ディレクトリの選択
showMessage("Select Open Folder");
dir = getDirectory("Choose a Directory");
list = getFileList(dir); //作業ディレクトリの中にあるファイルのリスト

//データ保存用のディレクトリを作成
savedir = dir + "stack\\"
if(!File.exists(savedir)){
	File.makeDirectory(savedir)
};

//モード選択
Dialog.create("Choose stack mode");
items1 = newArray("All channels", "All channels + Single channels", "Single channels");
Dialog.addRadioButtonGroup("Stack mode", items1, 3, 1,"All channels");
Dialog.show;
stackmode = Dialog.getRadioButton();

if(stackmode != "All channels"){
	Dialog.create("Choose single channel color mode");
	items2 = newArray("Gray", "Color");
	Dialog.addRadioButtonGroup("Single channel color mode", items2, 2, 1, "Gray");
	Dialog.show;
	colormode = Dialog.getRadioButton();
	
	Dialog.create("Enter the channel names");
	Dialog.addMessage("Enter the name of the channel to be \nused when storing the single-channel \nstacked image (if you want).")
	Dialog.addString("Channel 1", "channel-1");
	Dialog.addString("Channel 2", "channel-2");
	Dialog.addString("Channel 3", "channel-3");
	Dialog.show;
	channel1 = Dialog.getString();
	channel2 = Dialog.getString();
	channel3 = Dialog.getString();
	
	//single channelモードで使う色の設定
	if(colormode == "Gray"){
	col_singlechannel = newArray("Grays", "Grays", "Grays");
	}else{
	col_singlechannel = col;
	}
	
	//single channelモードで保存するときのチャネルの名前
	channelname = newArray(channel1, channel2, channel3);
}

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
		run("Enhance Contrast", "saturated=0.35");
		
		if(stackmode != "All channels"){
			run(col_singlechannel[k]);
			saveAs("png", savedir + namewithoutextension + "_stack_" + channelname[k] + ".png");
		}
		
		run(col[k]);
	}
	
	if(stackmode != "Single channels"){
		//Merge channels
		Property.set("CompositeProjection", "Sum");
		Stack.setDisplayMode("composite");
		
		//Save
		saveAs("png", savedir + namewithoutextension + "_stack.png");
	}
	
	close("MAX_"+name);
	close();
	
	//表示モードを元に戻す
	Property.set("CompositeProjection", "null");
	Stack.setDisplayMode("color");
}
