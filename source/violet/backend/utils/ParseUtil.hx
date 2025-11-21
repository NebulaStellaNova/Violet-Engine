package violet.backend.utils;

import haxe.Json;

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
}