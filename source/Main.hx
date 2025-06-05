package;

import flixel.FlxSprite;
import states.MainMenuState;
import backend.console.Logs;
import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		initEverything();
		addChild(new FlxGame(1280, 720, MainMenuState, 60, 60, true, false));
	}

	inline function initEverything() {
		Logs.init();
		FlxSprite.defaultAntialiasing = true;
	}
}
