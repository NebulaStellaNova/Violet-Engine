package backend.scripts;

import flixel.sound.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import backend.filesystem.Paths;
import backend.objects.NovaSprite;
import flixel.util.*;
import flixel.tweens.*;
import flixel.text.*;
import flixel.*;
import rulescript.parsers.HxParser;
import rulescript.RuleScript;
import hxwindowmode.WindowColorMode;
import lscript.LScript;

class LuaScript extends LScript {
	public function new(code:String, preset:Bool = true) {
		super(code);
		if (preset) presetVariables();
		this.execute();
	}

	public function presetVariables() {
		// Thanks Zyflx
		set('FlxG', FlxG);
		set('FlxBasic', FlxBasic);
		set('FlxObject', FlxObject);
		set('FlxSprite', FlxSprite);
		set('FlxCamera', FlxCamera);
		set('FlxText', FlxText);
		set('FlxTween', FlxTween);
		set('FlxTimer', FlxTimer);
		set('FlxMath', FlxMath);
		set('FlxTypedGroup', FlxTypedGroup);
		set('FlxSound', FlxSound);
		set('FlxColor', { // maybe temporary????
			TRANSPARENT: FlxColor.TRANSPARENT,
			WHITE: FlxColor.WHITE,
			GRAY: FlxColor.GRAY,
			BLACK: FlxColor.BLACK,
			GREEN: FlxColor.GREEN,
			LIME: FlxColor.LIME,
			YELLOW: FlxColor.YELLOW,
			ORANGE: FlxColor.ORANGE,
			RED: FlxColor.RED,
			PURPLE: FlxColor.PURPLE,
			BLUE: FlxColor.BLUE,
			BROWN: FlxColor.BROWN,
			PINK: FlxColor.PINK,
			MAGENTA: FlxColor.MAGENTA,
			CYAN: FlxColor.CYAN
		});

		// Engine
		// set('Controls', Controls.instance);
		// set('Scoring', Scoring);
		// set('Conductor', Conductor.instance);
		// set('PlayState', PlayState);
		//set('game', PlayState.current);
		set('NovaSprite', NovaSprite);
		set('Paths', Paths);
		set('WindowColorMode', WindowColorMode);

		set('X', FlxAxes.X);
		set('Y', FlxAxes.Y);
		set('XY', FlxAxes.XY);

		// Custom
		set('add', (object: FlxBasic) -> return FlxG.state.add(object));
		set('insert', (pos: Int, object: FlxBasic) -> return FlxG.state.insert(pos, object));
	}

	public function call(func, ?params)
		this.callFunc(func, params ?? []);

	public function set(what, value)
		this.setVar(what, value);
}