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

using StringTools;
using utils.ArrayUtil;
/**
 * @author @Zyflx (mostly)
 * @modified @NebulaStellaNova
 */
class FunkinScript extends RuleScript {
	private var scriptCode:String;
	private var executed:Bool = false;
	public var fileName:String;

	public function new(path:String, preset:Bool = true):Void {
		var scriptCode:String = Paths.readStringFromPath(path);
		this.fileName = path.split("/").getLastOf();
		super(null, new rulescript.parsers.HxParser());
		this.scriptCode = scriptCode;
		if(preset) presetVariables();
		executeScript();
	}

	public function presetVariables():Void {
		// Flixel
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
			TRANSPARENT:FlxColor.TRANSPARENT,
			WHITE:FlxColor.WHITE,
			GRAY:FlxColor.GRAY,
			BLACK:FlxColor.BLACK,
			GREEN:FlxColor.GREEN,
			LIME:FlxColor.LIME,
			YELLOW:FlxColor.YELLOW,
			ORANGE:FlxColor.ORANGE,
			RED:FlxColor.RED,
			PURPLE:FlxColor.PURPLE,
			BLUE:FlxColor.BLUE,
			BROWN:FlxColor.BROWN,
			PINK:FlxColor.PINK,
			MAGENTA:FlxColor.MAGENTA,
			CYAN:FlxColor.CYAN
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
		set('add', (object:FlxBasic) -> return FlxG.state.add(object));
		set('insert', (pos:Int, object:FlxBasic) -> return FlxG.state.insert(pos, object));
	}

	public function call(funcName:String, ?args:Array<Dynamic>):Dynamic {
		final func:Dynamic = variables.get(funcName);
		if(func == null) return null;

		if(Reflect.isFunction(func))
			return Reflect.callMethod(null, func, args ?? []);

		return null;
	}

	public function set(variable:String, value:Dynamic):Void {
		variables.set(variable, value);
	}

	inline public function get(variable:String):Dynamic {
		return variables.get(variable);
	}

	public function executeScript():Void {
		if(executed) return;
		getParser(HxParser).allowAll();
		tryExecute(scriptCode);
		executed = true;
	}
}