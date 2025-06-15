package backend.scripts;

import backend.scripts.psych.LuaCallbacks;
import haxe.PosInfos;
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

using StringTools;
using utils.ArrayUtil;

class LuaScript extends LScript {

	public var fileName:String;
	public var folderName:String;

	public var psychVariables:Map<String, Dynamic> = new Map();

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

	public function new(path:String, preset:Bool = true) {
		var code:String = Paths.readStringFromPath(path);
		this.fileName = path.split("/").getLastOf();
		if (path.split("/").getFirstOf() == "mods") {
			this.folderName = path.split("/")[1];
		} else {
			this.folderName = path.split("/").getFirstOf(); 
		}
		var finalCode = code;

		finalCode = checkForBlacklists(finalCode);

		finalCode += '\n' + Paths.readStringFromPath("assets/data/scripts/luaImports.lua");
		super(finalCode);
		this.print = (line:Int, s:String) -> {
			//var finalLine:String = '${line != -1 ? '$line' : '?'}';
			var info:PosInfos = {
				fileName: '$folderName:$fileName',//'$folderName:$fileName:$finalLine',
				lineNumber: line,
				className: '$folderName:$fileName',
				methodName: ""
			}
			log(s, info);
		}
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

		LuaCallbacks.applyPsychCallbacksToScript(this);

		// Custom
		//set('add', (object: FlxBasic) -> return FlxG.state.add(object));
		//set('insert', (pos: Int, object: FlxBasic) -> return FlxG.state.insert(pos, object));
	}

	public function call(func, ?params)
		this.callFunc(func, params ?? []);

	public function set(what, value:Dynamic)
		this.setVar(what, value);
}