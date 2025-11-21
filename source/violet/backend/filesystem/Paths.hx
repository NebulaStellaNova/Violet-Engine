package violet.backend.filesystem;

import haxe.io.Path;
import sys.FileSystem;

class Paths {
	inline public static function getFileName(path:String, startFromRoot:Bool = false)
		return Path.withoutExtension(Path.withoutDirectory(root(path, startFromRoot)));

	public static function root(path:String, startFromRoot:Bool = false):String {
		if (startFromRoot) return path;
		var rootPaths:Array<String> = ['assets/'].concat(#if MOD_SUPPORT Modding.activeModsIds #else [] #end);
		for (root in rootPaths)
			// if (folderExists('$root/$path', true) || fileExists('$root/$path', true))
				return Path.normalize('$root/$path');
		return '';
	}

	inline public static function font(path:String, directory:String = '', ext:String = 'ttf'):String
        return file(path, [directory, 'fonts'].join('/'), ext);

	inline public static function image(path:String, directory:String = '', ext:String = 'png'):String
        return file(path, [directory, 'images'].join('/'), ext);

	inline public static function sound(path:String, directory:String = '', ext:String = 'ogg'):String
        return file(path, [directory, 'sounds'].join('/'), ext);

	inline public static function music(path:String, directory:String = '', ext:String = 'ogg'):String
        return file(path, [directory, 'music'].join('/'), ext);

	inline public static function json(path:String, directory:String = '', ext:String = 'json'):String
        return file(path, directory, ext);

	inline public static function file(path:String, directory:String = '', ext:String = 'txt'):String
		return root([Path.removeTrailingSlashes(Path.removeTrailingSlashes(directory) == 'root' ? '' : directory), '$path.$ext'].join('/'), Path.removeTrailingSlashes(directory) == 'root');


	inline public static function fileExists(path:String, startFromRoot:Bool = false):Bool
		return FileSystem.exists(root(path, startFromRoot));

	inline public static function folderExists(path:String, startFromRoot:Bool = false):Bool
		return FileSystem.isDirectory(Path.removeTrailingSlashes(root(path, startFromRoot)));

	inline public static function readFolder(path:String, startFromRoot:Bool = false):Array<String>
		return FileSystem.readDirectory(Path.removeTrailingSlashes(root(path, startFromRoot)));

}