package violet.backend.utils;

import haxe.io.Path;

using StringTools;

class NovaUtils {
	public static function playMusic(path:String, volume:Float = 1):Void {
		var musicPath:Array<String> = path.split('/');
		musicPath.insert(musicPath.length - 2, Path.withoutExtension(musicPath[musicPath.length - 1]));
		FlxG.sound.playMusic(Cache.music(musicPath.join('/')), volume);
	}
}