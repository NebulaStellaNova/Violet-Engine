package violet.backend.utils;

class StringUtil {

	public static function capitalizeFirst(string:String) {
		return string.substr(0, 1).toUpperCase() + string.substr(1);
	}

	public static function removeLeadingSlash(str:String) {
		var splitStr = str.split('');
		if (splitStr[0] == '/')
			splitStr.shift();
		return splitStr.join('');
	}

	public static function replaceOutsideString(string:String, what:String, with:String) {
		var finalString:String = '';
		var splitString:Array<String> = string.split('');
		var length:Int = what.length-1 > with.length-1 ? what.length-1 : with.length-1;
		var splitWhat:Array<String> = what.split('');
		var splitWith:Array<String> = with.split('');
		for (i in 0...(length+1)) {
			if (splitWhat[i] == null) {
				splitWhat.push('');
			}
			if (splitWith[i] == null) {
				splitWith.push('');
			}
		}
		var isString:Bool = false;
		for (i=>char in splitString) {
			isString = (char == '"' || char == "'") ? !isString : isString;
			if (!isString) {
				var doReplace:Bool = true;
				for (i2=>char2 in what.split('')) {
					if (splitString[i+i2] != char2) {
						doReplace = false;
					}
				}
				if (doReplace) {
					char = with;
					for (i2=>char2 in what.split('')) {
						splitString[i+i2] = '';
					}
				}
			}
			finalString += char;
		}
		return finalString;
	}

	public static function formatTime(time:Float, format:String) {
		time /= 1000;
		var hour:Float = Math.floor(time / 3600);
		var min:Int = Math.floor(time / 60);
		var sec:Int = Math.floor(time % 60);
		var milli:Int = Math.floor((time * 1000) % 1000);
		format = format.toLowerCase();
		format = format.replace('hh', ScoreUtil.stringifyScore(hour, 2));
		format = format.replace('mm', ScoreUtil.stringifyScore(min, 2));
		format = format.replace('ss', ScoreUtil.stringifyScore(sec, 2));
		format = format.replace('h', '$hour');
		format = format.replace('m', '$min');
		format = format.replace('s', '$sec');
		format = format.replace('l', '$milli');
		return format;
	}

}