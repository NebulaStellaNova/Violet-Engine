package backend.scripts;

import flixel.*;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.*;
import flixel.tweens.*;
import flixel.util.*;
import hxwindowmode.WindowColorMode;
import rulescript.RuleScript;
import rulescript.parsers.HxParser;
import backend.filesystem.Paths;
import backend.objects.NovaSprite;

/**
 * @author @Zyflx
 * # THANKS - Nebula
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
		internalScript.scriptName = '$folderName:$fileName';
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
		importClass('FlxSound', FlxSound);
		importClass('FlxColor', Type.resolveClass('flixel.util.FlxColor_HSC'));
		importClass('FlxAxes', Type.resolveClass('flixel.util.FlxAxes_HSC'));

		// Engine
		importClass('NovaSprite', NovaSprite);
		importClass('FunkinSprite', NovaSprite);
		importClass('Paths', Paths);
		importClass('WindowColorMode', WindowColorMode);

		set('trace', (value:Dynamic) -> log(value, internalScript.interp.posInfos()));
		set('log', (value:Dynamic, type:backend.console.Logs.LogType = LogMessage) -> log(value, type, internalScript.interp.posInfos()));
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
		internalScript.tryExecute(scriptCode, (e:haxe.Exception) -> {
			log(e, ErrorMessage);
			return null;
		});
		executed = true;
	}
}