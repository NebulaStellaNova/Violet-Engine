package backend.scripts;

import haxe.PosInfos;
import flixel.*;
import flixel.group.*;
import flixel.math.*;
import flixel.sound.*;
import flixel.text.*;
import flixel.tweens.*;
import flixel.util.*;
import hxwindowmode.WindowColorMode;
import lscript.LScript;
import rulescript.parsers.HxParser;
import backend.filesystem.Paths;
import backend.objects.NovaSprite;

using StringTools;
using utils.ArrayUtil;

class LuaScript extends Script {
	var internalScript:LScript;

	override function set_parent(value:Dynamic):Dynamic
		return internalScript.parent = value;
	override function get_parent():Dynamic
		return internalScript.parent;

	public var blacklistImports:Array<Dynamic> = [
		sys.io.File,
		sys.FileSystem
	];

	function importCheck(code:String, importString:String) {
		var variations = [
			'script:import("$importString")',
			'script:import(\'$importString\')',
			'script.import("$importString")',
			'script.import(\'$importString\')'
		];
		for (i in variations) {
			if (code.contains(i)) {
				log('Blacklisted Lua Import "$importString"', ErrorMessage);
				code.replace(i, "");
			}
		}
		return code;
	}

	function checkForBlacklists(code:String):String {
		for (theImport in blacklistImports) {
			var importString:String = FlxStringUtil.getClassName(theImport);
			code = importCheck(code, importString);
		}
		return code;
	}

	public function new(path:String) {
		super(path);
		scriptCode = checkForBlacklists(scriptCode);
		scriptCode += '\n' + Paths.readStringFromPath("assets/data/scripts/luaImports.lua");

		internalScript = new LScript(scriptCode);
		internalScript.print = (line:Int, s:String) -> {
			var info:PosInfos = {
				fileName: '$folderName:$fileName',
				lineNumber: line,
				className: '$folderName:$fileName',
				methodName: ""
			}
			log(s, info);
		}
		initVars();
		internalScript.execute();
	}

	function initVars() {
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
		set('FlxTypedSpriteGroup', FlxSpriteGroup.FlxTypedSpriteGroup);
		set('FlxTypedGroup', FlxGroup.FlxTypedGroup);
		set('FlxSound', FlxSound);
		set('FlxColor', Type.resolveClass('flixel.util.FlxColor_HSC'));
		set('FlxAxes', Type.resolveClass('flixel.util.FlxAxes_HSC'));

		// Engine
		set('NovaSprite', NovaSprite);
		set('Paths', Paths);
		set('WindowColorMode', WindowColorMode);
	}

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T
		return internalScript.callFunc(funcName, args ?? []) ?? def;

	override public function set(variable:String, value:Dynamic)
		internalScript.setVar(variable, value);
	override public function get<T>(variable:String, ?def:T):T {
		return internalScript.getVar(variable) ?? def;
	}
}