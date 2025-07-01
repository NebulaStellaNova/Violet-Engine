package;

import haxe.ui.Toolkit;
import apis.WindowsAPI;
import backend.filesystem.Paths;
import backend.objects.NovaSave;
import backend.audio.Conductor;
import flixel.util.FlxStringUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import states.MainMenuState;
import backend.console.Logs;
import flixel.FlxGame;
import openfl.display.Sprite;
import hxwindowmode.WindowColorMode;
import backend.CrashHandler;

class Main extends Sprite
{
	public static var defaultKeybinds:Array<Array<String>> = [
		["W", "E", "LEFT"],
		["F", "F", "DOWN"],
		["J", "K", "UP"],
		["O", "O", "RIGHT"],
	];

	public static var className:String;

	public function new()
	{
		super();
		initEverything();
		addChild(new FlxGame(1280, 720, MainMenuState, 60, 60, true, false));
		CrashHandler.init();
		initEverythingAfter();
		addDebuggerStuff();
		FlxG.signals.preStateCreate.add((state)->{
			className = FlxStringUtil.getClassName(state, true);
			#if FLX_DEBUG
			FlxG.watch.add(Main, "className", 'Current State:');
			#end
			//log(className, DebugMessage);
		});
		FlxG.resetState();
		WindowColorMode.setDarkMode();
		apis.WindowsAPI.sendWindowsNotification("Test", "Test Desc");
		
		WindowsAPI.initConsole();
		
		var commandPrompt = new backend.CommandPrompt();
        backend.Threader.runInThread(commandPrompt.start());
		commandPrompt.active = true;
		initializeToolkit();

		FlxG.stage.window.onClose.add(()->{
			log("Console Closed.", SystemMessage);
			WindowsAPI.closeConsole();
		});
	}

	inline function initializeToolkit() {
		Toolkit.init();
    	Toolkit.theme = 'dark';
	}

	inline function initEverything() {
		Logs.init();
		FlxSprite.defaultAntialiasing = true;
		// NovaSave.setIfNull("hitWindow", 200);
	}
	inline function initEverythingAfter() {
		NovaSave.init();
		NovaSave.setIfNull("downscroll", false);
		NovaSave.setIfNull("ghostTapping", true);
		NovaSave.setIfNull("keybinds", defaultKeybinds);
	}

	inline function addDebuggerStuff() {
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerFunction('resetState', () -> FlxG.resetState());
		FlxG.game.debugger.console.registerFunction('openEditor', () -> FlxG.switchState(states.PonyCustomizationState.new));
		FlxG.game.debugger.console.registerFunction('setSaveData', NovaSave.set);
		FlxG.game.debugger.console.registerFunction('getSaveData', NovaSave.get);
		#end
	}

	override function __update(o, e) {
		super.__update(o, e);
		
		if (FlxG.keys.justPressed.F5) {
			FlxG.state.closeSubState();
			FlxG.resetState();
		}
	}
}
