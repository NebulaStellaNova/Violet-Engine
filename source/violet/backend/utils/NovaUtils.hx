package violet.backend.utils;

import violet.backend.audio.Conductor;
import violet.data.Constants;
import haxe.io.Path;

class NovaUtils {

	public static function playMenuMusic():Void {
		if (Conductor.curMusic != Constants.MENU_MUSIC) {
			Conductor.playMusic(Constants.MENU_MUSIC);
		}
	}

	public static function playMusic(path:String, volume:Float = 1):Void {
		var musicPath:Array<String> = path.split('/');
		musicPath.insert(musicPath.length - 2, Path.withoutExtension(musicPath[musicPath.length - 1]));
		FlxG.sound.playMusic(Cache.music(musicPath.join('/')), volume);
	}

	inline public static function getTimerPrecise():Float {
		#if flash
		return flash.Lib.getTimer();
		#elseif ((js && !nodejs) || electron)
		return js.Browser.window.performance.now();
		#elseif (lime_cffi && !macro)
		@:privateAccess
		return cast lime._internal.backend.native.NativeCFFI.lime_system_get_timer();
		#elseif cpp
		return untyped __global__.__time_stamp() * 1000.0;
		#elseif sys
		return Sys.time() * 1000.0;
		#else
		return 0;
		#end
	}
}