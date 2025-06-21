package backend.filesystem;

import backend.modding.ModMeta;
import sys.io.File;
import openfl.utils.AssetType;
import utils.NovaUtil;
import haxe.display.Display.Package;
import haxe.Json;
import sys.FileSystem;
import haxe.io.Path;

using StringTools;

class Paths {

	public static var resourceFolder = "assets";

	public static function checkModEnabled(modID:String):Bool {
		if (fileExists('mods/$modID/novamod_meta.json') || fileExists('mods/$modID/novamod_meta.jsonc')) {
			var metaData:ModMeta = parseJsonEXT('mods/$modID/novamod_meta');
			return metaData.mod_enabled ?? true;
		} else if (folderExists('mods/$modID')) {
			log('Invalid or missing "novamod_meta.json(c)" for mod "$modID"', ErrorMessage);
		}
		return false;
	}

	public static function modPath(path:String, isFolder:Bool = false) {
		for (i in FileSystem.readDirectory("mods")) {
			if (checkModEnabled(i)) {
				if (isFolder ? folderExists('mods/$i/$path') : fileExists('mods/$i/$path')) {
					return 'mods/$i/$path';
				}
			}
		}
		return '$resourceFolder/$path';
	}

	public static function modPaths(path:String, isFolder:Bool = false) {
		var pathArray:Array<String> = [];
		for (i in FileSystem.readDirectory("mods")) {
			if (checkModEnabled(i)) {
				if (isFolder ? folderExists('mods/$i/$path') : fileExists('mods/$i/$path')) {
					pathArray.push('mods/$i/$path');
				}
			}
		}
		pathArray.push('$resourceFolder/$path');
		return pathArray;
	}

	public static function music(path:String, ?directory:String):String {
		return modPath('music/${directory != null ? Path.addTrailingSlash(directory) : ""}$path', true);
	}

	public static function sound(path:String, ?directory:String):String {
		return modPath('sounds/${directory != null ? Path.addTrailingSlash(directory) : ""}$path.ogg');
	}

	public static function image(path:String, ?directory:String, ext:String = "png"):String {
		return modPath('images/${directory != null ? Path.addTrailingSlash(directory) : ""}$path.$ext');
	}

	public static function font(path:String, ?directory:String, ext:String = ""):String {
		return modPath('fonts/${directory != null ? Path.addTrailingSlash(directory) : ""}${path != "" ? '.$ext' : ""}');
	}

	public static function xml(path:String, ?directory:String):String {
		return modPath('${directory != null ? Path.addTrailingSlash(directory) : ""}$path.xml');
	}

	public static function json(path:String, ?directory:String):String {
		return modPath('${directory != null ? Path.addTrailingSlash(directory) : ""}$path.json');
	}

	public static function vocal(song:String, suffix:String = '', varient:String = '') {
		return modPath('songs/$song/song/${varient != '' ? '$varient/' : ''}Voices${suffix != '' ? '-$suffix' : ''}.ogg');
	}

	public static function inst(song:String, varient:String = "") {
		return modPath('songs/$song/song/${varient != '' ? '$varient/' : ''}Inst.ogg');
	}
	public static function instExists(song:String, varient:String = "") {
		return fileExists(inst(song, varient));
	}

	public static function getFileName(path:String) {
		var splitPath = path.split("/");
		var splitName = splitPath[splitPath.length-1].split(".");
		return splitName[0];
	}

	public static function fileExists(path:String) {
		return FileSystem.exists(path);
	}

	public static function folderExists(path:String):Bool
		return FileSystem.isDirectory(Path.removeTrailingSlashes(path));

	public static function readFolder(folderPath:String, ?setExt:String, folderCheck:Bool = false):Array<String> {
		var folder = FileSystem.readDirectory(folderPath);
		var finalList = [];
		for (i in folder) {
			if (folderCheck) {
				if (folderExists('$folderPath/$i'))
					finalList.push(i);
			} else if (setExt != null) {
				if (i.endsWith('.$setExt'))
					finalList.push(i);
			} else {
				finalList.push(i);
			}
		}
		return finalList;
	}

	/**
	* Read string file contents directly from a given path.
	* Only works on desktop.
	*
	* @param path The path to the file.
	* @return The file contents.
	*/
	public static function readStringFromPath(path:String):String
	{
		return sys.io.File.getContent(path);
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

	public static function parseJson(path:String, ?directory:String):Dynamic {
		var jsonString:String = "{\n\t\"warning\": \"File Not Found\"\n}";
		if (fileExists(json(path, directory)+"c")) {
			jsonString = readStringFromPath(json(path, directory)+"c");
		} else {
			var string = readStringFromPath(json(path, directory));
			if (string != "")
				jsonString = string;
		}
		return Json.parse(removeJsonComments(jsonString));
	}

	public static function parseJsonEXT(path:String, ?directory:String):Dynamic {
		var jsonString:String = "{\n\t\"warning\": \"File Not Found\"\n}";
		if (fileExists(path +".jsonc")) {
			jsonString = readStringFromPath(path +".jsonc");
		} else {
			var string = readStringFromPath(path +".json");
			if (string != "")
				jsonString = string;
		}
		return Json.parse(removeJsonComments(jsonString));
	}

	public static function parseJsonMap(path:String, ?directory:String) {
		return NovaUtil.objectToMap(parseJson(path, directory));
	}

	public static function getSongList():Array<String> {
		var songList:Array<String> = parseJson("data/songList");
		for (i in FileSystem.readDirectory("mods")) {
			if (checkModEnabled(i)) {
				if (fileExists('mods/$i/data/songList.json') || fileExists('mods/$i/data/songList.jsonc')) {
					songList = songList.concat(parseJsonEXT('mods/$i/data/songList'));
				}
			}
		}
		return songList;
	}
}