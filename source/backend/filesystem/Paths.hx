package backend.filesystem;

import haxe.display.Display.Package;
import haxe.Json;
import sys.FileSystem;
import haxe.io.Path;

using StringTools;

class Paths {

    public static function music(path:String, ?directory:String):String { 
        return 'assets/music/${directory != null ? Path.addTrailingSlash(directory) : ""}$path';
    }

    public static function sound(path:String, ?directory:String):String { 
        return 'assets/sounds/${directory != null ? Path.addTrailingSlash(directory) : ""}$path.ogg';
    }

    public static function image(path:String, ?directory:String):String { 
        return 'assets/images/${directory != null ? Path.addTrailingSlash(directory) : ""}$path.png';
    }

    public static function font(path:String, ?directory:String):String { 
        return 'assets/fonts/${directory != null ? Path.addTrailingSlash(directory) : ""}$path';
    }
    public static function json(path:String, ?directory:String):String { 
        return 'assets/${directory != null ? Path.addTrailingSlash(directory) : ""}$path.json';
    }

    public static function vocal(song:String, suffix:String = '', varient:String = '') {
        return 'assets/songs/$song/song/${varient != '' ? '$varient/' : ''}Voices${suffix != '' ? '-$suffix' : ''}.ogg';
    }

    public static function inst(song:String, varient:String = "") {
        return 'assets/songs/$song/song/${varient != '' ? '$varient/' : ''}Inst.ogg';
    }
    public static function instExists(song:String, varient:String = "") {
        return fileExists(inst(song, varient));
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
		for (char in split) {
			if (char == "/" && split[i+1] == "/") {
				isComment = true;
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
            jsonString = readStringFromPath(json(path, directory));
        }
        return Json.parse(removeJsonComments(jsonString));
    }

    public static function getSongList():Array<String> {
        return parseJson("data/songList");
    }
}