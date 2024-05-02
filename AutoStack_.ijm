//作業ディレクトリの選択
showMessage("Select Open Folder");
dir = getDirectory("Choose Directory");
list = getFileList(dir); //作業ディレクトリの中にあるファイルのリスト

list_oib = Array.filter(list, ".oib");
list_oir = Array.filter(list, ".oir");
list_read = Array.concat(list_oib, list_oir); //.oirと.oibのみのリスト

//データ保存用のディレクトリを作成
savedir = dir + "stack\\"
if(!File.exists(savedir)){
	File.makeDirectory(savedir)
};

col_magenta = newArray("Green", "Magenta", "Cyan");
col_red = newArray("Green", "Red", "Blue");

//モード選択
Dialog.create("Choose stack & color mode");
items_mode = newArray("All channels", "All channels + Single channels", "Single channels");
items_color = newArray("Green / Magenta / Cyan", "Green / Red / Blue");
items_saveextension = newArray("png", "jpeg", "tiff");
Dialog.addRadioButtonGroup("Stack mode", items_mode, 3, 1,"All channels");
Dialog.addRadioButtonGroup("Color mode", items_color, 2, 1,"Green / Magenta / Cyan");
Dialog.addRadioButtonGroup("Save file format", items_saveextension, 3, 1, "png");
Dialog.show;
stackmode = Dialog.getRadioButton();
colormode = Dialog.getRadioButton();
saveextension = Dialog.getRadioButton();

if(colormode == "Green / Magenta / Cyan"){
	col = col_magenta;
}else{
	col = col_red;
}

if(stackmode != "All channels"){
	Dialog.create("Choose single channel color mode");
	items_singlecolormode = newArray("Gray", "Color");
	Dialog.addRadioButtonGroup("Single channel color mode", items_singlecolormode, 2, 1, "Gray");
	Dialog.addMessage("Enter the name of the channel to be \nused when saving the single-channel \nstacked image (if you want).")
	Dialog.addString("Channel 1", "channel-1");
	Dialog.addString("Channel 2", "channel-2");
	Dialog.addString("Channel 3", "channel-3");	
	Dialog.show;
	colormode = Dialog.getRadioButton();
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

//main
for(j=0; j<list_read.length; ++j){
	name = list_read[j];
	extension = indexOf(name, "."); //拡張子(.を含む)
	namewithoutextension = substring(name, 0, extension); //元データは"namewithoutextension + extension"
	path = dir+name;
	
	run("Bio-Formats Importer", "open=path");	
	run("Z Project...", "projection=[Max Intensity]"); //Stack
	close(name); //元ファイルを閉じる
	
	Stack.getDimensions(width, height, channels, slices, frames); //チャンネル数を取得
	
	//各チャンネルの色を変更・コントラストの調整
	for(k=0; k<channels; k++){
		Stack.setChannel(k+1);
		run("Enhance Contrast", "saturated=0.35");
		
		if(stackmode != "All channels"){
			run(col_singlechannel[k]);
			saveAs(saveextension, savedir + namewithoutextension + "_stack_" + channelname[k] + "." + saveextension);
		}
		
		run(col[k]);
	}
	
	if(stackmode != "Single channels"){
		//Merge channels
		Property.set("CompositeProjection", "Sum");
		Stack.setDisplayMode("composite");
		
		//Save
		saveAs(saveextension, savedir + namewithoutextension + "_stack." + saveextension);
	}

	//表示モードを元に戻す
	Property.set("CompositeProjection", "null");
	Stack.setDisplayMode("color");
		
	close("MAX_"+name);
	close();
}

Dialog.create("Finished");
Dialog.addMessage("All files have been successfully stacked!");
Dialog.show;
