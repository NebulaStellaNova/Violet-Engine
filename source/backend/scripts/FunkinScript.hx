package backend.scripts;

import flixel.*;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import hxwindowmode.WindowColorMode;
import rulescript.RuleScript;
import rulescript.parsers.HxParser;
import backend.filesystem.Paths;
import backend.objects.NovaSprite;

using StringTools;
using utils.ArrayUtil;
using utils.MathUtil;
/**
 * @author @Zyflx (mostly)
 * @modified @NebulaStellaNova
 */
class FunkinScript extends Script {
	var internalScript:RuleScript;

	override function set_parent(value:Dynamic):Dynamic
		return internalScript.superInstance = value;
	override function get_parent():Dynamic
		return internalScript.superInstance;

	public function new(path:String):Void {
		super(path);
		internalScript = new RuleScript();
		internalScript.scriptName = '$folderName/$fileName';
		initVars();
		executeScript();
	}

	function importClass<T>(name:String, daClass:Class<T>) {
		internalScript.interp.imports.set(name, daClass);
		internalScript.interp.variables.set(name, daClass);
	}

	function initVars():Void {
		// Flixel
		importClass('FlxG', FlxG);
		importClass('FlxBasic', FlxBasic);
		importClass('FlxObject', FlxObject);
		importClass('FlxSprite', FlxSprite);
		importClass('FlxCamera', FlxCamera);
		importClass('FlxText', FlxText);
		importClass('FlxTween', FlxTween);
		importClass('FlxTimer', FlxTimer);
		importClass('FlxMath', FlxMath);
		importClass('FlxTypedGroup', FlxTypedGroup);
		importClass('FlxSpriteGroup', FlxSpriteGroup);
		importClass('FlxSound', FlxSound);
		set('FlxColor', {
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
		set('FlxAxes', {
			X: FlxAxes.X,
			Y: FlxAxes.Y,
			XY: FlxAxes.XY
		});

		// Engine
		importClass('FunkinSprite', NovaSprite);
		importClass('NovaSprite', NovaSprite);
		importClass('Paths', Paths);
		importClass('WindowColorMode', WindowColorMode);

		// Custom
		set('add', (object:FlxBasic) -> return FlxG.state.add(object));
		set('remove', (object:FlxBasic) -> return FlxG.state.remove(object));
		set('insert', (pos:Int, object:FlxBasic) -> return FlxG.state.insert(pos, object));

		set('trace', (value:Dynamic) -> log(value, internalScript.interp.posInfos()));
		set('log', (value:Dynamic, type:backend.console.Logs.LogType = LogMessage) -> log(value, type, internalScript.interp.posInfos()));

        set('lerp', MathUtil.lerp);
	}

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		var func = this.get(funcName);
		if (func != null && Reflect.isFunction(func))
			return Reflect.callMethod(null, func, args ?? []) ?? def;
		return null;
	}

	override public function set(variable:String, value:Dynamic):Void
		internalScript.variables.set(variable, value);
	override public function get<T>(variable:String, ?def:T):T
		return internalScript.variables.get(variable) ?? def;

	public function executeScript():Void {
		if (executed) return;
		internalScript.getParser(HxParser).allowAll();
		internalScript.tryExecute(scriptCode);
		executed = true;
	}
}