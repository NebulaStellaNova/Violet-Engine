package backend;

import backend.filesystem.Paths;
import apis.WindowsAPI;
import flixel.system.debug.console.ConsoleUtil;
import lime.app.Application;
import haxe.io.Path;
import sys.io.File;
import sys.FileSystem;
import flixel.FlxG;
import haxe.CallStack;
import openfl.Lib;
import openfl.events.UncaughtErrorEvent;

using StringTools;
class CrashHandler {

	public static var SEPERATOR = "=====================";
	public static var NEWLINE = "\n";

	public static function init() {
		//Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onError);
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
	}

	public static function onCrash(e:UncaughtErrorEvent):Void
	{
		
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + "VioletEngine_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
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
			NEWLINE,
			'Flixel Current State: ${currentState}',
			'Error: ' + e.error,
			NEWLINE,
			'Crash Dump Saved In: ${Path.normalize(path)}',
			NEWLINE,	
			SEPERATOR,
			"Mods Loaded:"
		];
		for (i in Paths.getModList()) {
			crashLines.push(' - $i');
		}

		errMsg = crashLines.join('\n');

		/* errMsg += "\nUncaught Error: " + e.error;
		// remove if you're modding and want the crash log message to contain the link
		// please remember to actually modify the link for the github page to report the issues to.
		//#if officialBuild
		//errMsg += "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine";
		//#end
		errMsg += "\n\n> Crash Handler written by: sqirra-rng"; */

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		File.saveContent(path, errMsg + "\n");

		Sys.println(errMsg);
		Sys.println("Crash dump saved in " + Path.normalize(path));
		
		Application.current.window.alert(errMsg, "Error!");
		
		WindowsAPI.closeConsole();
		Sys.exit(1);
	}


}