package violet.backend.utils;

import haxe.Json;

using StringTools;

class ParseUtil {
	public static function json(path:String, directory:String = ''):Dynamic
		return Json.parse(removeJsonComments(FileUtil.getFileContent(Paths.json(path, directory))));

	public static function removeJsonComments(str:String) {
		var split = str.split('');
		var string = "";
		var isComment = false;
		var i = 0;
		var isString = false;
		for (char in split) {
			if (char == '"') {
				isString = !isString;
			} else if (!isString) {
				if (char == "/" && split[i+1] == "/") {
					isComment = true;
				}
			}
			if (!isComment) {
				string += char;
			} else if (char == "\n") {
				isComment = false;
				string += char;
			}
			i++;
		}
		return string;
	}

	/**
	 * Correctly formats JSON files for export :D
	 */
	public static function stringifyJson(jsonObject:Dynamic) {
		var string = jsonObject is String ? jsonObject : Json.stringify(jsonObject, null, "\t");
		string = string.trim();
		string = string.replace("    ", "\t");
		var finalStr = "";
		var inArray = false;
		var taber = "";
		for (i=>char in string.split("")) {
			var split = finalStr.split("");
			var realI = finalStr.length;

			inArray = i != 0 ? (char == "[" ? true : (char == "]" ? false : inArray)) : inArray;
			inArray = i != 0 ? (char == "{" ? false : (char == "}" ? true : inArray)) : inArray;

			if (char == "\t") taber += "\t";

			var combined = split[realI-2] + split[realI-1] + char;

			if (combined == "[ {" || combined == ", {") {
				char = "\n" + taber + char;
			}

			if (combined == "} ]") {
				char = "\n" + taber.substr(taber.length - 1) + char;
			}

			if (char == "\n") taber = "";

			if (inArray && char == "\n") char = " ";
			if (inArray && char == "\t") char = "";

			finalStr += char;
		}
		finalStr = finalStr.replace("[ {", "[\n{");
		finalStr = finalStr.replace("}, {", "},\n{");
		return finalStr;
	}
}