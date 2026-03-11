package violet.backend.utils;

import haxe.ui.components.Label;
import haxe.ui.notifications.NotificationType;
import flixel.FlxCamera;
import haxe.ui.notifications.Notification;
import haxe.io.Path;
import haxe.ui.core.Screen;
import violet.data.Constants;
import violet.backend.audio.Conductor;
import flixel.graphics.frames.FlxAtlasFrames;

import haxe.ui.notifications.NotificationManager;

enum abstract MenuSFX(Int) {
	var SCROLL;
	var CANCEL;
	var CONFIRM;
}

class NovaUtils {

	public static var CURRENT_MUSIC:String = "";

	public static var NOTIFICATION_MANAGER:NotificationManager;
	public static var NOTIFICATION_CAMERA:FlxCamera;

	public static function addNotification(title:String, body:String, type:NotificationType = Default, expiryMs:Int = 10000) {
		var notificationData:haxe.ui.notifications.NotificationData = {title: title, body: body, type: type, expiryMs: expiryMs};
		if (NOTIFICATION_CAMERA == null) {
			NOTIFICATION_CAMERA = new FlxCamera();
			NOTIFICATION_CAMERA.bgColor = FlxColor.TRANSPARENT;
			FlxG.cameras.add(NOTIFICATION_CAMERA, false);
		}
		if (NOTIFICATION_MANAGER == null) {
			NOTIFICATION_MANAGER = new NotificationManager();
		}
		var notification = NOTIFICATION_MANAGER.addNotification(notificationData);
		notification.closeButton.destroy();

		notification.camera = NOTIFICATION_CAMERA;
	}

	public static function playMenuMusic():Void {
		if (CURRENT_MUSIC != Constants.MENU_MUSIC) {
			playMusic(Constants.MENU_MUSIC).volume = 0.5;
		}
	}

	public static function playMenuSFX(which:MenuSFX, volume:Float = 1):FlxSound {
		final bruh = switch (which) {
			case SCROLL: 'scroll';
			case CANCEL: 'cancel';
			case CONFIRM: 'confirm';
		}
		final sound = FlxG.sound.play(Cache.sound('menu/$bruh'), volume);
		sound.persist = true;
		return sound;
	}

	public static function playMusic(path:String, volume:Float = 1, folder:String = 'music'):FlxSound {
		var musicPath:Array<String> = path.split('/');
		CURRENT_MUSIC = path;
		if (folder == 'music')
			musicPath.insert(musicPath.length - 2, Path.withoutExtension(musicPath[musicPath.length - 1]));
		var metaData = null;
		if (Paths.fileExists('$folder/${musicPath.join('/')}.json'))
			metaData = ParseUtil.json('$folder/${musicPath.join('/')}');

		// Setup Conductor
		Conductor.resetConductor();
		FlxG.sound.playMusic(Cache.music(musicPath.join('/'), '', 'ogg', false, folder), volume);
		Conductor.initCallbacks();
		Conductor.initCallbacksSubState();
		if (metaData != null && metaData.bpm != null && metaData.signature != null) Conductor.setInitialBPM(metaData.bpm, metaData.signature[0], metaData.signature[1]);
		return FlxG.sound.music;
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


	public static function getSparrowFrames(path:String):FlxAtlasFrames {
		return FlxAtlasFrames.fromSparrow(Cache.image(path, 'root', null), path.replace(".png", ".xml"));
	}

	public static function getAtlasFrames(path:String):FlxAtlasFrames {
		return animate.FlxAnimateFrames.fromAnimate(haxe.io.Path.withoutExtension(path));
	}
}