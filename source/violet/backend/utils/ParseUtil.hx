package violet.backend.utils;

import haxe.Json;
import yaml.Parser;
import yaml.Yaml;

class ParseUtil {
	public static function json(path:String, directory:String = ''):Dynamic {
		try {
			return Json.parse(removeJsonComments(FileUtil.getFileContent(Paths.json(path, directory))));
		} catch(error:haxe.Exception)
			try {
				return Json.parse(removeJsonComments(FileUtil.getFileContent(Paths.json(path, directory, 'jsonc'))));
			} catch(error:haxe.Exception)
				return null;
	}

	public static function yaml(path:String, directory:String = ''):Dynamic {
		final options = new ParserOptions(); options.maps = false;
		try {
			return Yaml.parse(FileUtil.getFileContent(Paths.yaml(path, directory)), options);
		} catch(error:haxe.Exception) {
			return null;
		}
	}

	public static function jsonOrYaml(path:String, ?directory:String):Dynamic {
		if (Paths.yaml(path, directory) != "") {
			return yaml(path, directory);
		} else if (Paths.json(path, directory) != "") {
			return json(path, directory);
		}
		return {};
	}

	public static function stringifyYaml(data:Dynamic):String {
		//               We've lost ALL the plot <3
		var regex:EReg = ~/:[ \t]*\r?\n[ \t]*-[ \t]*(-?\d+(?:\.\d+)?)[ \t]*\r?\n[ \t]*-[ \t]*(-?\d+(?:\.\d+)?)/g;
		var rawYaml:String = Yaml.render(data, null);
		return regex.replace(rawYaml, ": [$1, $2]");
	}

	public static function stringifyJson(data:Dynamic) {

	}

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
/* 	public static function stringifyJson(jsonObject:Dynamic) {
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
	} */
}

/**
 * Used for parsing colors from json files.
 */
abstract ParseColor(String) {
	public var red(get, set):Int;
	inline function get_red():Int
		return toFlxColor().red;
	inline function set_red(value:Int):Int {
		var color:FlxColor = toFlxColor();
		color.red = value;
		this = fromFlxColor(color);
		return color.red;
	}
	public var green(get, set):Int;
	inline function get_green():Int
		return toFlxColor().green;
	inline function set_green(value:Int):Int {
		var color:FlxColor = toFlxColor();
		color.green = value;
		this = fromFlxColor(color);
		return color.green;
	}
	public var blue(get, set):Int;
	inline function get_blue():Int
		return toFlxColor().blue;
	inline function set_blue(value:Int):Int {
		var color:FlxColor = toFlxColor();
		color.blue = value;
		this = fromFlxColor(color);
		return color.blue;
	}

	@:from inline public static function fromString(from:String):ParseColor
		return cast FlxColor.fromString(from ?? 'white').toWebString();
	@:to inline public function toString():String
		return this ?? '#FFFFFF';

	@:from inline public static function fromInt(from:Int):ParseColor
		return FlxColor.fromInt(from ?? FlxColor.WHITE).toWebString();
	@:to inline public function toInt():Int
		return FlxColor.fromString(this ?? 'white');

	@:from inline public static function fromFlxColor(from:FlxColor):ParseColor
		return FlxColor.fromInt(from ?? FlxColor.WHITE).toWebString();
	@:to inline public function toFlxColor():FlxColor
		return FlxColor.fromString(this ?? 'white');

	@:from inline public static function fromArray(from:Array<Int>):ParseColor
		return fromInt(FlxColor.fromRGB(from[0] ?? 255, from[1] ?? 255, from[2] ?? 255));
	@:to inline public function toArray():Array<Int> {
		var color:FlxColor = toFlxColor();
		return [color.red ?? 255, color.green ?? 255, color.blue ?? 255];
	}
}