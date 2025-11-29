package violet.backend;

import flixel.FlxCamera;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;
import lime.app.Application;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;
import haxe.ui.notifications.NotificationManager;
import haxe.ui.notifications.NotificationType;

class CrashHandler {
	private static var notificationCamera:FlxCamera = null;
	// @:unreflective public static var notificationManager:NotificationManager;

	static var SEPERATOR = '=====================';

	public static function init():Void {
		//Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		// Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(
			UncaughtErrorEvent.UNCAUGHT_ERROR,
			function(event:UncaughtErrorEvent) {
				// one of these oughta do it
				event.stopImmediatePropagation();
				event.stopPropagation();
				event.preventDefault();
				onCrash(event.error);
			}
		);

		#if cpp
		untyped __global__.__hxcpp_set_critical_error_handler(onCrash);
		#end

		// notificationManager = new haxe.ui.notifications.NotificationManager();

		FlxG.signals.preStateCreate.add((_)->{
			notifList = [];
		});
		/* FlxG.signals.postStateSwitch.add(()->{
			new flixel.util.FlxTimer().start(1, (_)->{
				triggerNotifs();
			});
		}); */
	}

	static function onCrash(e:UncaughtErrorEvent):Void {
		trace("warning:Uh Oh!");
		errorNotif("test", "yo");
		/* @:privateAccess FlxG.game._nextState = new violet.states.TitleState();
		@:privateAccess FlxG.game.switchState(); */
		return;
		var path:String = './crash/VioletEngine_${Date.now().toString().replace(' ', '_').replace(':', "'")}.txt';

		var errMsg:String = '';
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(s, file, line, column):
					errMsg += '$file (line $line)\n';
				default: Sys.println(stackItem);
			}
		}

		var currentState:String = 'No state loaded';
		if (FlxG.state != null) {
			var currentStateCls:Null<Class<Dynamic>> = Type.getClass(FlxG.state);
			if (currentStateCls != null) {
				currentState = Type.getClassName(currentStateCls) ?? 'No state loaded';
			}
		}

		var crashLines:Array<String> = [
			SEPERATOR,
			'Nova Engine Crash Report',
			SEPERATOR,
			'\n',
			'Flixel Current State: ${currentState}',
			'Error: ' + e.error,
			'\n',
			'Crash Dump Saved In: ${Path.normalize(path)}',
			'\n',
			SEPERATOR
			// 'Mods Loaded:'
		];
		// for (i in Paths.getModList()) {
		// 	crashLines.push(' - $i');
		// }
		errMsg = crashLines.join('\n');

		/* errMsg += '\nUncaught Error: ' + e.error;
		// remove if you're modding and want the crash log message to contain the link
		// please remember to actually modify the link for the github page to report the issues to.
		//#if officialBuild
		//errMsg += '\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine';
		//#end
		errMsg += '\n\n> Crash Handler written by: sqirra-rng'; */

		if (!FileSystem.exists('./crash/'))
			FileSystem.createDirectory('./crash/');

		File.saveContent(path, '$errMsg\n');

		Sys.println(errMsg);
		Sys.println('Crash dump saved in ${Path.normalize(path)}.');

		Application.current.window.alert(errMsg, 'Error!');

		Sys.exit(1);
	}

	public static var notifList:Array<Dynamic> = [];
	public static function triggerNotifs() {
		var notificationManager = new haxe.ui.notifications.NotificationManager();
		for (i in notifList) {
			notificationManager.addNotification({
				title: i.title,
				body: i.description,
				type: NotificationType.Error,
				expiryMs: 5000,
				actions: []
			});
		}
	}

	@:unreflective public static function errorNotif(title:String, description:String) {
		var addIt = true;
		for (i in notifList) if (i.title == title && i.description == description) addIt = false;
		if (addIt) notifList.push({title: title, description: description});
	}
}