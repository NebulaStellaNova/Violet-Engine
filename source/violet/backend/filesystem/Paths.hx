package violet.backend.filesystem;

import haxe.io.Path;
import sys.FileSystem;

class Paths {

	public static var SHARED:String = "shared";

	inline public static function getFileName(path:String, startFromRoot:Bool = false)
		return Path.withoutExtension(Path.withoutDirectory(startFromRoot ? path : root(path)));

	public static function root(path:String):String
		return Path.normalize('assets/$path'); // will also handle mods at a later date

	inline public static function image(path:String, directory:String = '', ext:String = 'png'):String {
		return root([Path.removeTrailingSlashes(directory), 'images', '$path.$ext'].join('/'));
	}

	inline public static function sound(path:String, directory:String = '', ext:String = 'ogg'):String {
		return root([Path.removeTrailingSlashes(directory), 'sounds', '$path.$ext'].join('/'));
	}

	inline public static function music(path:String, directory:String = '', ext:String = 'ogg'):String {
		return root([Path.removeTrailingSlashes(directory), 'music', '$path.$ext'].join('/'));
	}

	inline public static function fileExists(path:String, startFromRoot:Bool = false):Bool
		return FileSystem.exists(startFromRoot ? path : root(path));

	inline public static function folderExists(path:String, startFromRoot:Bool = false):Bool {
		return FileSystem.isDirectory(Path.removeTrailingSlashes(startFromRoot ? path : root(path)));
	}

	public static function readFolder(path:String, startFromRoot:Bool = false):Array<String>
		return FileSystem.readDirectory(Path.removeTrailingSlashes(startFromRoot ? path : root(path)));
}