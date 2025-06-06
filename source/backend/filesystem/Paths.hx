package backend.filesystem;

import haxe.Json;
import sys.FileSystem;
import haxe.io.Path;

using StringTools;
class Paths {

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

    public static function fileExists(path:String) {
        return FileSystem.exists(path);
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

    public static function parseJson(path:String, ?directory:String) {
        return Json.parse(readStringFromPath(json(path, directory)));
    }
}