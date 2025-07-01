package utils;

class StringUtil {
    public static function removeLeadingSlash(str:String) {
        var splitStr = str.split("");
        if (splitStr[0] == "/")
            splitStr.shift();
        return splitStr.join("");
    }

    public static function replaceOutsideString(string:String, what:String, with:String) {
        var finalString:String = "";
        var splitString:Array<String> = string.split("");
        var length:Int = what.length-1 > with.length-1 ? what.length-1 : with.length-1;
        var splitWhat:Array<String> = what.split("");
        var splitWith:Array<String> = with.split("");
        for (i in 0...(length+1)) {
            if (splitWhat[i] == null) {
                splitWhat.push("");
            }
            if (splitWith[i] == null) {
                splitWith.push("");
            }
        }
        var isString:Bool = false;
        for (i=>char in splitString) {
            isString = (char == '"' || char == "'") ? !isString : isString;
            if (!isString) {
                var doReplace:Bool = true;
                for (i2=>char2 in what.split("")) {
                    if (splitString[i+i2] != char2) {
                        doReplace = false;
                    }
                }
                if (doReplace) {
                    char = with;
                    for (i2=>char2 in what.split("")) {
                        splitString[i+i2] = "";
                    }
                }
            }
            finalString += char;
        }
        return finalString;
    }

}