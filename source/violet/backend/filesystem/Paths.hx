package violet.backend.filesystem;

import haxe.io.Path;
import sys.FileSystem;
import moonchart.backend.Util as MoonUtil;
import violet.backend.utils.FileUtil;
#if ANIMATE_SUPPORT
import animate.FlxAnimateFrames;
#end

class Paths {
	public static var ASSETS_FOLDER:String = "resources";

	public static function init():Void {
		#if ANIMATE_SUPPORT
		@:privateAccess {
			FlxAnimateFrames.getTextFromPath = (path:String) -> return root(path, true).replace(String.fromCharCode(0xFEFF), '');
			FlxAnimateFrames.existsFile = (path:String, type:openfl.utils.AssetType) -> return Paths.fileExists(path, true);
			FlxAnimateFrames.listWithFilter = (path:String, filter:String->Bool) -> return [for (file in Paths.readFolder(path, true)) file].filter(filter);
			// FlxAnimateFrames.getGraphic = (path:String) -> return Cache.image(path);
		}
		#end
		MoonUtil.readFolder = (folder:String) -> [for (file in Paths.readFolder(folder, true)) file];
		MoonUtil.isFolder = (folder:String) -> Paths.folderExists(folder, true);
		MoonUtil.getText = (path:String) -> FileUtil.getFileContent(path);
	}

	inline public static function getFileName(path:String, startFromRoot:Bool = false)
		return Path.withoutExtension(Path.withoutDirectory(root(path, startFromRoot)));

	public static function root(path:String, startFromRoot:Bool = false):String {
		if (startFromRoot) return path;
		var rootPaths:Array<String> = [ASSETS_FOLDER].concat(#if MOD_SUPPORT [for (meta in ModdingAPI.getActiveMods()) 'mods/${meta.folder}'] #else [] #end);
		for (root in rootPaths)
			if (folderExists('$root/$path', true) || fileExists('$root/$path', true))
				return Path.normalize('$root/$path');
		return '';
	}
	public static function multiRoot(path:String):Array<String> {
		var rootPaths:Array<String> = [ASSETS_FOLDER].concat(#if MOD_SUPPORT [for (meta in ModdingAPI.getActiveMods()) 'mods/${meta.folder}'] #else [] #end);
		var results:Array<String> = [];
		for (root in rootPaths)
			if (folderExists('$root/$path', true) || fileExists('$root/$path', true))
				results.push(Path.normalize('$root/$path'));
		return results;
	}

	inline public static function font(path:String, directory:String = '', ?ext:String = 'ttf'):String
		return file(path, [directory, 'fonts'].join('/'), ext);

	inline public static function image(path:String, directory:String = '', ?ext:String = 'png'):String
		return file(path, [directory, 'images'].join('/'), ext);

	inline public static function sound(path:String, directory:String = '', ?ext:String = 'ogg'):String
		return file(path, [directory, 'sounds'].join('/'), ext);

	inline public static function music(path:String, directory:String = '', ?ext:String = 'ogg'):String
		return file(path, [directory, 'music'].join('/'), ext);

	inline public static function json(path:String, directory:String = '', ?ext:String = 'json'):String
		return file(path, directory, ext) != '' ? file(path, directory, ext) : (ext == 'json' ? file(path, directory, ext + 'c') : '');

	inline public static function file(path:String, directory:String = '', ?ext:String):String
		return root((directory == 'root' ? ['$path${ext == null || path.endsWith('.$ext') ? '' : '.$ext'}'] : [Path.removeTrailingSlashes(directory), '$path${ext == null || path.endsWith('.$ext') ? '' : '.$ext'}']).join('/'), directory == 'root');


	inline public static function fileExists(path:String, startFromRoot:Bool = false):Bool
		return FileSystem.exists(root(path, startFromRoot));

	inline public static function folderExists(path:String, startFromRoot:Bool = false):Bool
		return FileSystem.isDirectory(Path.removeTrailingSlashes(root(path, startFromRoot)));

	public static function readFolder(path:String, startFromRoot:Bool = false):Array<String> {
		if (startFromRoot) return FileSystem.readDirectory(Path.removeTrailingSlashes(root(path, true)));
		var files:Array<String> = [];
		for (folder in multiRoot(path))
			for (file in FileSystem.readDirectory(Path.removeTrailingSlashes(folder)))
				files.push(file);
		return files;
	}
}