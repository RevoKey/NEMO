//###########################################################################
//# Purpose: Translate Korean strings to user specified strings both loaded #
//#          from TranslateClient.txt . Also fixes Taekwon branch Job names #
//###########################################################################

function TranslateClient() {

  //Step 1 - Open the text file for reading
  var f = new TextFile();
  if (!f.open(APP_PATH + "/patches/TranslateClient.txt") )
    return "Failed in Step 1 - Unable to open file";
  
  var offset = -1;
  var msg = ""; 
  var failmsgs = [];//Array to store all Failure messages
  
  //Step 2 - Loop through the text file, get the respective strings & do findString + replace
  
  while (!f.eof()) {
    var str = f.readline().trim();
    
    if (str.charAt(0) === "M") {// M: = Failure message string
      msg = str.substring(2).trim();
    }
    else if (str.charAt(0) === "F") {// F: = Find string
      str = str.substring(2).trim();
      
      if (str.charAt(0) === "'")  //ASCII
        str = str.substring(1,str.length-1);
      else  //HEX 
        str = str.toAscii();
      
      offset = exe.findString(str, RAW);
      if (offset === -1)
        failmsgs.push(msg);//No Match = Collect Failure message
    }
    else if (str.charAt(0) === "R" && offset !== -1) {// R: = Replace string. At this point we have both location and string to replace with
      str = str.substring(2).trim();
      
      if (str.charAt(0) === "'")//ASCII
        exe.replace(offset, str.substring(1, str.length-1) + "\x00", PTYPE_STRING);
      else //HEX
        exe.replace(offset, str + " 00", PTYPE_HEX);
      
      offset = -1;
    }
  }
  f.close();
  
  //Step 3 - Dump all the Failure messages collected to FailedTranslations.txt
  if (failmsgs.length != 0) {
    var outfile = new TextFile();
    
    if (outfile.open(APP_PATH + "/FailedTranslations.txt", "w")) {
      for (var i=0; i< failmsgs.length; i++) {
        outfile.writeline(failmsgs[i]);
      }
    }
    
    outfile.close();
  }
  
  return true;
}