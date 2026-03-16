package violet.backend.filesystem;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.media.Sound;
import violet.backend.display.BetterBitmapData;

@:bitmap('assets/images/logo/logo.png')
private class HaxeLogo extends BitmapData {}

class Cache {

	public static var soundFoldersToCache:Array<String> = [
		'menu',
		'miss'
	];

	public static function init():Void {
		trace("debug:<yellow>Initializing Cache System...");
		for (i in soundFoldersToCache) {
			for (item in Paths.readFolder(['sounds', i].join('/'))) {
				final jointPath:String = [i, item].join('/');
				sound(jointPath);
				trace('debug:<cyan>Cached sound asset "<magenta>${Paths.sound(jointPath)}<cyan>"');
			}
		}
	}

	static final cache:Map<String, Dynamic> = new Map<String, Dynamic>();

	public static function image(path:String, directory:String = '', ?ext:String = 'png'):FlxGraphic {
		var imagePath:String = Paths.image(path, directory, ext);
		if (cache.exists(imagePath)) return cache.get(imagePath);

		var bitmap:BitmapData = null;
		if (Paths.fileExists(imagePath, true))
			bitmap = BetterBitmapData.fromFile(imagePath);

		if (bitmap == null) {
			trace('error:No bitmap data from path "$imagePath".');
			return FlxGraphic.fromClass(HaxeLogo, 'flixel/images/logo/logo.png');
		}

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, imagePath, false);
		graphic.destroyOnNoUse = false;
		graphic.persist = true;
		cache.set(imagePath, graphic);
		return graphic;
	}

	inline public static function sound(path:String, directory:String = '', ?ext:String = 'ogg', beepWhenNull:Bool = false, folder:String = 'sounds'):Sound
		return audio(path, directory == 'root' ? 'root' : [directory, folder].join('/'), ext, beepWhenNull);

	inline public static function music(path:String, directory:String = '', ?ext:String = 'ogg', beepWhenNull:Bool = true, folder:String = 'music'):Sound
		return audio(path, directory == 'root' ? 'root' : [directory, folder].join('/'), ext, beepWhenNull);

	static function audio(path:String, directory:String = '', ?ext:String = 'ogg', beepWhenNull:Bool = false):Sound {
		var audioPath:String = Paths.file(path, directory, ext);
		if (cache.exists(audioPath)) return cache.get(audioPath);

		var sound:Sound = null;
		if (Paths.fileExists(audioPath, true))
			sound = Sound.fromFile(audioPath);

		if (sound == null && audioPath != "" && audioPath != '.$ext') {
			trace('error:No sound data from path "$audioPath".');
			return /* beepWhenNull ? Sound.fromFile('flixel/sounds/beep.ogg') : */ null;
		}
		cache.set(audioPath, sound);
		return sound;
	}
}