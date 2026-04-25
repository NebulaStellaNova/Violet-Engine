package violet.backend.filesystem;

import haxe.io.Path;
import sys.FileSystem;
import moonchart.backend.Util as MoonUtil;
import violet.backend.utils.FileUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.StringUtil;
#if ANIMATE_SUPPORT
import animate.FlxAnimateAssets;

typedef AssetType = #if (flixel >= "5.9.0") flixel.system.frontEnds.AssetFrontEnd.FlxAssetType #else openfl.utils.AssetType #end;
#end

class Paths {
	public static #if release inline #end final ASSETS_FOLDER:String = #if REDIRECT_ASSETS_FOLDER "../../../../assets" #else "resources" #end;

	private static function notifyIfBlank(foundPath:String, targetPath:String, type:String) {
		if (foundPath == "" && Path.withoutExtension(Path.withoutDirectory('$targetPath')) != 'null') {
			NovaUtils.addNotification(StringUtil.capitalizeFirst(type) + " not found!", 'Could not find $type asset at "${ASSETS_FOLDER}/$targetPath"', ERROR);
		}
		return foundPath;
	}

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

	#if release inline #end public static function getFileName(path:String, startFromRoot:Bool = false)
		return fileName(root(path, startFromRoot));

	public static function fileName(file:String) {
		return Path.withoutExtension(Path.withoutDirectory(file));
	}

	public static function fixPath(path:String) {
		while (path.contains("//")) {
			path = path.replace("//", "/");
		}
		return path;
	}

	public static function root(path:String, startFromRoot:Bool = false):String {
		if (startFromRoot)
			return path;
		var rootPaths:Array<String> = [].concat(#if MOD_SUPPORT [for (meta in ModdingAPI.getActiveMods()) '${ModdingAPI.MOD_FOLDER}/${meta.folder}'] #else [] #end).concat([ASSETS_FOLDER]);
		for (root in rootPaths) {
			if (folderExists(fixPath('$root/$path'), true) || fileExists(fixPath('$root/$path'), true))
				return Path.normalize('$root/$path');
		}
		return '';
	}

	public static function multiRoot(path:String, modOnly:Bool = false):Array<String> {
		var rootPaths:Array<String> = (modOnly ? [] : [ASSETS_FOLDER]).concat(#if MOD_SUPPORT [for (meta in ModdingAPI.getActiveMods()) '${ModdingAPI.MOD_FOLDER}/${meta.folder}'] #else [] #end);
		var results:Array<String> = [];
		for (root in rootPaths)
			if (folderExists('$root/$path', true) || fileExists('$root/$path', true))
				results.push(Path.normalize('$root/$path'));
		return results;
	}

	#if release inline #end public static function font(path:String, directory:String = '', ?ext:String = 'ttf'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'fonts'].join('/'), ext);

	#if release inline #end public static function xml(path:String, directory:String = '', ?ext:String = 'xml'):String
		return file(path, directory == 'root' ? 'root' : [directory].join('/'), ext);

	#if release inline #end public static function ui(path:String, directory:String = ''):String {
		return xml('data/ui/$path', directory);
	}

	#if release inline #end public static function atlas(path:String, directory:String = ''):String {
		return file(Path.withoutExtension(path) + '/Animation', directory == 'root' ? 'root' : [directory, 'images'].join('/'), "json");
	}

	#if release inline #end public static function image(path:String, directory:String = '', ?ext:String = 'png'):String {
		var out = file(path, directory == 'root' ? 'root' : [directory, 'images'].join('/'), ext);
		if (out != '') return out;
		else return atlas(path, directory);
	}

	#if release inline #end public static function sound(path:String, directory:String = '', ?ext:String = 'ogg'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'sounds'].join('/'), ext);

	#if release inline #end public static function frag(path:String, directory:String = '', ?ext:String = 'frag'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'shaders'].join('/'), ext);
	#if release inline #end public static function vert(path:String, directory:String = '', ?ext:String = 'vert'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'shaders'].join('/'), ext);

	#if release inline #end public static function music(path:String, directory:String = '', ?ext:String = 'ogg'):String
		return file(path, directory == 'root' ? 'root' : [directory, 'music'].join('/'), ext);

	#if release inline #end public static function yaml(path:String, directory:String = '', ?ext:String = 'yaml'):String {
		return file(path, directory, ext) != "" ? file(path, directory, ext) : file(path, directory, ext == 'yaml' ? 'yml' : ext);
	}

	#if release inline #end public static function json(path:String, directory:String = '', ?ext:String = 'json'):String
		return file(path, directory, ext) != '' ? file(path, directory, ext) : (ext == 'json' ? file(path, directory, ext + 'c') : '');

	#if release inline #end public static function file(path:String, directory:String = '', ?ext:String):String
		return root((directory == 'root' ? ['$path${ext == null || path.endsWith('.$ext') ? '' : '.$ext'}'] : [
			Path.removeTrailingSlashes(directory),
			'$path${ext == null || path.endsWith('.$ext') ? '' : '.$ext'}'
		]).join('/'), directory == 'root');

	#if release inline #end public static function vocal(song:String, suffix:String = '', ?variant:String, dashes:Bool = true):String {
		var prefix = dashes ? '-' : '';
		return root('songs/$song/song/Voices${suffix != '' ? '$prefix$suffix' : ''}${variant != '' ? '$prefix$variant' : ''}.ogg');
	}

	#if release inline #end public static function inst(song:String, ?variant:String):String
		return root('songs/$song/song/${variant != null ? '$variant/' : ''}Inst.ogg');

	#if release inline #end public static function fileExists(path:String, startFromRoot:Bool = false):Bool {
		return path != "" ? _checkExists(root(path, startFromRoot)) : false;
	}

	#if release inline #end public static function folderExists(path:String, startFromRoot:Bool = false):Bool
		return #if mobile _readFolder(Path.removeTrailingSlashes(root(path, startFromRoot))).length != 0 || #end FileSystem.isDirectory(Path.removeTrailingSlashes(root(path, startFromRoot)));

	public static function readFolder(path:String, startFromRoot:Bool = false, ?filter:String->Bool, modOnly:Bool = false):Array<String> {
		if (startFromRoot) {
			var files = folderExists(path, startFromRoot) ? _handleDirectories(Path.removeTrailingSlashes(root(path, true))) : [];
			var out = (filter != null ? files.filter(filter) : files);
			out.sort(NovaUtils.sortAlphabetically);
			return out;
		}
		var files:Array<String> = [];
		for (folder in multiRoot(path, modOnly))
			for (file in _handleDirectories(Path.removeTrailingSlashes(folder)))
				files.push(file);
		var out = (filter != null ? files.filter(filter) : files);
		out.sort(NovaUtils.sortAlphabetically)
		return out;
	}

	/**
	 * Used for mobile
	 *
	 * ![a](https://raw.githubusercontent.com/NebulaStellaNova/Hamsters/refs/heads/main/taking%20notes.png)
	 */
	private static function _checkExists(path:String) {
		return #if mobile openfl.utils.Assets.exists(path) || #end FileSystem.exists(path);
	}

	private static function _handleDirectories(path) {
		#if mobile var internal = _readFolder(path); #end
		return #if mobile internal.length != 0 ? internal : #end FileSystem.readDirectory(path);
	}

	private static function _readFolder(path) {
		var fileList:Array<String> = openfl.utils.Assets.list(TEXT).filter((id:String) -> {
			return id.startsWith(path);
		});
		return [for (i in fileList) i.split("/").pop()];
	}
}
