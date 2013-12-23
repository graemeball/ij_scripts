// gbLarvalTracker_.ijm: build stack and display latest frame as files appear 
//   in the directory specified.
//
// Author: graemeball@googlemail.com (Micron Oxford)
// but this is based on a macro written by Johannes Schindelin:-
//   http://imagej.1557.n6.nabble.com/Open-new-file-automatically-as-it-is-created-in-a-folder-td3682549.html

macro "Larval Tracker Action Tool - C000D00C000D10C000D20C000D30C000D40C000D50C000D60C000D70C000D80C000D90C000Da0C111Db0C444Dc0C444Dd0C111De0C000Df0C000D01C000D11C000D21C000D31C000D41C000D51C000D61C000D71C000D81C000D91C111Da1C777Db1C999Dc1C888Dd1C333De1C000Df1C000D02C000D12C000D22C000D32C000D42C000D52C000D62C000D72C000D82C111D92C666Da2C888Db2C777Dc2C888Dd2C555De2C000Df2C000D03C000D13C000D23C000D33C000D43C000D53C000D63C000D73C000D83C444D93C888Da3C555Db3C444Dc3C777Dd3C444De3C000Df3C000D04C000D14C000D24C000D34C000D44C000D54C000D64C000D74C333D84C888D94C666Da4C444Db4C555Dc4C888Dd4C333De4C000Df4C000D05C000D15C000D25C000D35C000D45C000D55C000D65C222D75C888D85C888D95C555Da5C333Db5C777Dc5C777Dd5C111De5C000Df5C000D06C000D16C000D26C000D36C000D46C000D56C222D66C666D76C777D86C666D96C555Da6C666Db6C888Dc6C222Dd6C000De6C000Df6C000D07C000D17C000D27C000D37C000D47C111D57C666D67C666D77C444D87C444D97C666Da7C888Db7C444Dc7C000Dd7C000De7C000Df7C000D08C000D18C000D28C000D38C000D48C444D58C777D68C555D78C333D88C555D98C888Da8C555Db8C000Dc8C000Dd8C000De8C000Df8C000D09C000D19C000D29C000D39C333D49C777D59C777D69C555D79C333D89C666D99C666Da9C111Db9C000Dc9C000Dd9C000De9C000Df9C000D0aC000D1aC000D2aC111D3aC777D4aC888D5aC666D6aC333D7aC444D8aC666D9aC222DaaC000DbaC000DcaC000DdaC000DeaC000DfaC000D0bC000D1bC000D2bC333D3bC999D4bC777D5bC333D6bC444D7bC777D8bC333D9bC000DabC000DbbC000DcbC000DdbC000DebC000DfbC000D0cC000D1cC000D2cC777D3cC777D4cC222D5cC444D6cC888D7cC555D8cC000D9cC000DacC000DbcC000DccC000DdcC000DecC000DfcC000D0dC000D1dC444D2dCaaaD3dC666D4dC555D5dC888D6dC666D7dC000D8dC000D9dC000DadC000DbdC000DcdC000DddC000DedC000DfdC000D0eC000D1eC777D2eCaaaD3eC888D4eC999D5eC666D6eC000D7eC000D8eC000D9eC000DaeC000DbeC000DceC000DdeC000DeeC000DfeC000D0fC111D1fC777D2fCaaaD3fC888D4fC333D5fC000D6fC000D7fC000D8fC000D9fC000DafC000DbfC000DcfC000DdfC000DefC000DffC0f0L1131L1311Lc1e1Le1e3L1e1cL3e1eLeceeLeece" { 

	// 1. ask the user for a directory to monitor
	directory = getDirectory("Select the directory"); 
	
	// 2. get the initial list (without opening the files) 
	list = getFileList(directory); 
	Array.sort(list); 
	
	// 3. keep checking the directory for new files; append and update display
	for (;;) { 
	        previousList = list; 
	        list = getFileList(directory); 
	        if (previousList.length != list.length) { 
	                Array.sort(list); 
	
	                // walk both lists 
	                j = 0; 
	                for (i = 0; i < list.length; i++) { 
	                        stopJ = previousList.length; 
	                        while (j < stopJ) 
	                                if (previousList[j] < list[i]) 
	                                        j++; 
	                                else 
	                                        stopJ = j; 
	                        if (j >= previousList.length) {
	                                updateSequence(directory, list);
	                        }
	                        else if (list[i] != previousList[j]) {
	                                updateSequence(directory, list);
	                        }
	                } 
	        } 
	        // TODO: try to clean up on exit, renaming to Seq_ + timeStamp

	        wait(500); // wait half a second before checking again
	} 
	
	
	
	///// Function definitions /////////////////////////////////////////////
	
	/// Perform sequence (& tracking?) update, adding to existing sequence
	function updateSequence(directory, list) {
	        open(directory + list[i]);
	        if (nImages==1){
	            // 1st image: set the name of the sequence
	            rename( "Seq_active_.tif" );
	            preprocess();
	        }else{
	            newImg = getTitle();
	            preprocess();  // cropping, conversion etc.
	            concatString = "  title=Seq_active_.tif image1=Seq_active_.tif";
	            concatString = concatString + " image2=" + newImg;
	            run("Concatenate...", concatString);
	        }
	        // TODO: segmentation and tracking
	        // display the most recently acquired image
	        setSlice(nSlices);
	}
	
	/// Pre-process the image to reduce its size and background
	function preprocess(){
		// TODO: set cropping box from 1st image
		makeRectangle(152, 0, 615, 611);
		run("Crop");
		run("8-bit");
		run("Subtract Background...", "rolling=50 slice");
		run("Enhance Contrast...", "saturated=0.4");
	}
	
	/// Return a date & time string (day_month_year-time), e.g. 9_11_2001-08-46
	function timeStamp() {
	     MonthNames = newArray("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec");
	     DayNames = newArray("Sun", "Mon","Tue","Wed","Thu","Fri","Sat");
	     getDateAndTime(year, month, dayOfWeek, dayOfMonth, hour, minute, second, msec);
	     TimeString = "_";
	     if (dayOfMonth<10) {TimeString = TimeString+"0";}
	     TimeString = TimeString+dayOfMonth+"_"+dayOfMonth+"_"+year+"-";
	     if (hour<10) {TimeString = TimeString+"0";}
	     TimeString = TimeString + hour+"-";
	     if (minute<10) {TimeString = TimeString+"0";}
	     TimeString = TimeString+minute;
	     return TimeString;
	}
}
