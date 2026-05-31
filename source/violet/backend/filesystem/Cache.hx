package violet.backend.filesystem;

import haxe.io.Bytes;
import openfl.utils.ByteArray;
import sys.FileSystem;
import flixel.util.FlxStringUtil;
import violet.states.PlayState;
import violet.data.character.Character;
import violet.data.stage.Stage;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import openfl.media.Sound;
import violet.backend.display.BetterBitmapData;

@:bitmap('assets/images/logo/default.png')
private class HaxeLogo extends BitmapData {}

class Cache {

	public static function init():Void {
		trace("debug:<yellow>Initializing Cache System...");
		for (i in ['menu', 'miss']) {
			for (item in Paths.readFolder(['sounds', i].join('/'))) {
				final jointPath:String = [i, item].join('/');
				sound(jointPath);
				trace('debug:<cyan>Cached sound asset "<magenta>${Paths.sound(jointPath)#if REDIRECT_ASSETS_FOLDER .replace('../../../../', '') #end}<cyan>"');
			}
		}

		FlxG.signals.preStateSwitch.add(()-> {
			var nextStateID = FlxStringUtil.getClassName(Type.getClass(@:privateAccess FlxG.game._nextState.createInstance()), true);
			var previousStateID = FlxStringUtil.getClassName(FlxG.state, true);
			/* if (nextStateID != previousStateID) */ /* clear(); */
		});
	}

	static final cache:Map<String, Dynamic> = new Map<String, Dynamic>();

	static final imgCache:Array<FlxGraphic> = [];
	static final imgCacheKeys:Array<String> = [];

	/* public static function xml(path:String):String {
		if (cache.exists(path))
	} */

	public static function remove(path:String, directory:String = '', ?ext:String = 'png') {
		var imagePath:String = Paths.image(path, directory, ext);
		for (i=>key in imgCacheKeys) {
			if (key == imagePath) {
				FlxG.bitmap.removeByKey(key);
				imgCache.remove(imgCache[i]);
				imgCacheKeys.remove(key);
			}
		}
	}

	public static function clear() {
		for (i=>key in imgCacheKeys) {
			FlxG.bitmap.removeByKey(key);
		}
		cachedCharacters.clear();
		cache.clear();
		imgCache.resize(0);
		imgCacheKeys.resize(0);
	}

	public static function image(path:String, directory:String = '', ?ext:String = 'png', doCache:Bool = true):FlxGraphic {
		var imagePath:String = Paths.image(path, directory, ext);
		if (imgCacheKeys.contains(imagePath) && doCache) {

			var graphic:FlxGraphic = imgCache[imgCacheKeys.indexOf(imagePath)];

			if (!graphic.isDestroyed) {
				graphic.refresh();
				return graphic;
			}
		}

		var bitmap:BitmapData = null;
		if (Paths.fileExists(imagePath, true))
			bitmap = BetterBitmapData.fromFile(imagePath);

		if (bitmap == null) {
			trace('error:No bitmap data from path "$imagePath".');
			bitmap = BetterBitmapData.fromFile(Paths.image('zuko-here'));
		}

		bitmap.lock();

		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, imagePath, false);
		graphic.destroyOnNoUse = false;
		graphic.persist = true;
		imgCacheKeys.push(imagePath);
		imgCache.push(graphic);

		bitmap.unlock();
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


	// -- In Prep for Change Character Event -- \\

	public static var cachedCharacters:Map<String, Character> = [];
	public static var cachedStages:Map<String, Stage> = [];

	public static function character(id:String) {
		if (cachedCharacters.exists(id)) return;
		cachedCharacters.set(id, new Character(id));
	}

	public static function stage(id:String) {
		if (cachedStages.exists(id)) return;
		cachedStages.set(id, new Stage(id));
	}

}