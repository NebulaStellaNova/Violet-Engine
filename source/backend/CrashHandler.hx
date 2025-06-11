package backend;

import flixel.FlxG;
import haxe.CallStack;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;

using StringTools;
class CrashHandler {

	@:access(FlxG.stage.__uncaughtErrorEvents)
	public static function init() {
		//Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		//Lib.current.loaderInfo.uncaughtErrorEvents.removeEventListener();
    	Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener("uncaughtError", onError);
	}

	public static function onError(e:UncaughtErrorEvent):Void {
		trace("ran this");
		var errMsg:String = '';
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(' ', '_');
		dateNow = dateNow.replace(':', '\'');

		//path = './crash/Imaginative_$dateNow.txt';

		for (stackItem in callStack) {
			switch (stackItem) {
				case FilePos(_, file, line, _):
					errMsg += '$file (line $line)\n';
				default:
					log(stackItem, ErrorMessage);
			}
		}

		errMsg += '\nUncaught Error: $e.error\n\n> Crash Handler written by: Nebula S. Nova';

		/* if (!FileSystem.exists('./crash/'))
			FileSystem.createDirectory('./crash/');

		File.saveContent(path, errMsg + '\n'); */

		log(errMsg, ErrorMessage);
		apis.WindowsAPI.sendWindowsNotification("Error!", errMsg);
		//log('Crash dump saved in ${FilePath.normalize(path)}', ErrorMessage);

		//FlxWindow.direct.self.alert(errMsg, 'Error!');
		cast (FlxG.state, MusicBeatState).switchState(new states.MainMenuState());
	}
}