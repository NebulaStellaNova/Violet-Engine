package violet.backend.filesystem;

import haxe.io.Path;
import sys.FileSystem;
import moonchart.backend.Util as MoonUtil;
import violet.backend.utils.FileUtil;
#if ANIMATE_SUPPORT
import animate.FlxAnimateAssets;

typedef AssetType = #if (flixel >= "5.9.0") flixel.system.frontEnds.AssetFrontEnd.FlxAssetType #else openfl.utils.AssetType #end;
#end

class Paths {
	public static var ASSETS_FOLDER:String = "resources";

	public static function init():Void {
		MoonUtil.readFolder = (folder:String) -> Paths.readFolder(folder, true);
		MoonUtil.isFolder = (folder:String) -> Paths.folderExists(folder, true);
		// MoonUtil.saveBytes;
		// MoonUtil.saveText = (path:String, text:String) -> return FileUtil.setFileContent(path, text);
		// MoonUtil.getBytes;
		MoonUtil.getText = FileUtil.getFileContent;
		#if ANIMATE_SUPPORT
		FlxAnimateAssets.exists = (path:String, type:AssetType) -> return fileExists(path, true);
		FlxAnimateAssets.getText = MoonUtil.getText;
		// FlxAnimateAssets.getBytes = MoonUtil.getBytes;
		FlxAnimateAssets.getBitmapData = (path:String) -> return Cache.image(path, 'root').bitmap;
		function newLister(path:String, ?type:AssetType, ?library:String, includeSubDirectories:Bool = false):Array<String> {
			var list:Array<String> = readFolder(path, true);
			if (includeSubDirectories)
				for (item in list)
					if (folderExists('$path/$item', true))
						list.concat(newLister('$path/$item', true));
			return list;
		}
		FlxAnimateAssets.list = newLister;
		#end
	}

	inline public static function getFileName(path:String, startFromRoot:Bool = false)
		return Path.withoutExtension(Path.withoutDirectory(root(path, startFromRoot)));

	public static function root(path:String, startFromRoot:Bool = false):String {
		if (startFromRoot)
			return path;
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
		return file(path, directory == 'root' ? 'root' : [directory, 'fonts'].join('/'), ext);

	inline public static function image(path:String, directory:String = '', ?ext:String = 'png'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'images'].join('/'), ext);

	inline public static function sound(path:String, directory:String = '', ?ext:String = 'ogg'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'sounds'].join('/'), ext);

	inline public static function frag(path:String, directory:String = '', ?ext:String = 'frag'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'shaders'].join('/'), ext);

	inline public static function music(path:String, directory:String = '', ?ext:String = 'ogg'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'music'].join('/'), ext);

	inline public static function json(path:String, directory:String = '', ?ext:String = 'json'):String
		return file(path, directory, ext) != '' ? file(path, directory, ext) : (ext == 'json' ? file(path, directory, ext + 'c') : '');

	inline public static function file(path:String, directory:String = '', ?ext:String):String
		return root((directory == 'root' ? ['$path${ext == null || path.endsWith('.$ext') ? '' : '.$ext'}'] : [
			Path.removeTrailingSlashes(directory),
			'$path${ext == null || path.endsWith('.$ext') ? '' : '.$ext'}'
		]).join('/'), directory == 'root');

	inline public static function vocal(song:String, suffix:String = '', ?variant:String)
		return root('songs/$song/song/${variant != null ? '$variant/' : ''}Voices${suffix != '' ? '-$suffix' : ''}.ogg');

	inline public static function inst(song:String, ?variant:String)
		return root('songs/$song/song/${variant != null ? '$variant/' : ''}Inst.ogg');

	inline public static function fileExists(path:String, startFromRoot:Bool = false):Bool
		return FileSystem.exists(root(path, startFromRoot));

	inline public static function folderExists(path:String, startFromRoot:Bool = false):Bool
		return FileSystem.isDirectory(Path.removeTrailingSlashes(root(path, startFromRoot)));

	public static function readFolder(path:String, startFromRoot:Bool = false):Array<String> {
		if (startFromRoot)
			return FileSystem.readDirectory(Path.removeTrailingSlashes(root(path, true)));
		var files:Array<String> = [];
		for (folder in multiRoot(path))
			for (file in FileSystem.readDirectory(Path.removeTrailingSlashes(folder)))
				files.push(file);
		return files;
	}
}
