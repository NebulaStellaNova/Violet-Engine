package backend.scripts;

import flixel.math.FlxAngle;
import haxe.PosInfos;
import flixel.*;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import hxwindowmode.WindowColorMode;
import lscript.LScript;
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

	public static var psychVariables:Map<String, Dynamic> = [];

	public var blacklistImports:Array<Class<Dynamic>> = [
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

	public function new(path:String, preset:Bool = true) {
		super(path);
		scriptCode = checkForBlacklists(scriptCode);
		scriptCode += '\n' + Paths.readStringFromPath("assets/data/scripts/luaImports.lua");

		internalScript = new LScript(scriptCode);
		internalScript.print = (line:Int, s:String) -> {
			var info:PosInfos = {
				fileName: '$folderName/$fileName',
				lineNumber: line,
				className: '$folderName/$fileName',
				methodName: ""
			}
			log(s, (s == "Nova Engine has Lua Support" ? SystemMessage : LogMessage), info);
		}
		initVars();
		internalScript.execute();
	}

	public function initVars() {
		// Flixel
		set('FlxG', FlxG);
		set('FlxAngle', FlxAngle);
		set('FlxBasic', FlxBasic);
		set('FlxObject', FlxObject);
		set('FlxSprite', FlxSprite);
		set('FlxCamera', FlxCamera);
		set('FlxText', FlxText);
		set('FlxTween', FlxTween);
		set('FlxTimer', FlxTimer);
		set('FlxMath', FlxMath);
		set('FlxGroup', FlxGroup);
		set('FlxSpriteGroup', FlxSpriteGroup);
		set('FlxSound', FlxSound);
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
		set('NovaSprite', NovaSprite);
		set('Paths', Paths);
		set('WindowColorMode', WindowColorMode);

		backend.scripts.psych.LuaCallbacks.applyPsychCallbacksToScript(this);

		// Custom
		/* set('add', (object:FlxBasic) -> return FlxG.state.add(object));
		set('remove', (object:FlxBasic) -> return FlxG.state.remove(object));
		set('insert', (pos:Int, object:FlxBasic) -> return FlxG.state.insert(pos, object));

		set('trace', (value:Dynamic) -> log(value, internalScript.interp.posInfos()));
		set('log', (value:Dynamic, type:backend.console.Logs.LogType = LogMessage) -> log(value, type, internalScript.interp.posInfos())); */
	}

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T
		return internalScript.callFunc(funcName, args ?? []) ?? def;

	override public function set(variable:String, value:Dynamic)
		internalScript.setVar(variable, value);
	override public function get<T>(variable:String, ?def:T):T
		return internalScript.getVar(variable) ?? def;
}