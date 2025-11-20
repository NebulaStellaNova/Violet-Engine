package violet.backend.filesystem;
import haxe.io.Path;

class Paths {

    public static var SHARED:String = "shared";

    public static function getFileName(path:String) { // Move this later
		var splitPath = path.split("/");
		var splitName = splitPath[splitPath.length-1].split(".");
		return splitName[0];
	}

    public static function image(path:String, ?directory:String, ext:String = "png"):String {
		return 'assets/${directory != null ? Path.addTrailingSlash(directory) : ""}images/$path.$ext';
	}
}