package utils;

class StringUtil {
    public static function removeLeadingSlash(str:String) {
        var splitStr = str.split("");
        if (splitStr[0] == "/")
            splitStr.shift();
        return splitStr.join("");
    }
}