package;

import flixel.util.FlxStringUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import states.MainMenuState;
import backend.console.Logs;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var className:String;

	public function new()
	{
		super();
		initEverything();
		addChild(new FlxGame(1280, 720, MainMenuState, 60, 60, true, false));
		addDebuggerStuff();
		FlxG.signals.preStateCreate.add((state)->{
			className = FlxStringUtil.getClassName(state, true);
			#if FLX_DEBUG
			FlxG.watch.add(Main, "className", 'Current State:');
			#end
			//log(className, DebugMessage);
		});
		FlxG.resetState();
	}

	inline function initEverything() {
		Logs.init();
		FlxSprite.defaultAntialiasing = true;
	}

	inline function addDebuggerStuff() {
		#if FLX_DEBUG
		FlxG.game.debugger.console.registerFunction('resetState', () -> FlxG.resetState());
		FlxG.game.debugger.console.registerFunction('openEditor', () -> FlxG.switchState(states.PonyCustomationState.new));
		#end
	}
}
