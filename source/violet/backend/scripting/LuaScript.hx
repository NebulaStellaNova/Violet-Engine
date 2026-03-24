package violet.backend.scripting;
#if CAN_LUA_SCRIPT

import haxe.PosInfos;
import flixel.*;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
// import hxwindowmode.WindowColorMode;
import lscript.LScript;
import violet.backend.filesystem.Paths;
import violet.backend.objects.NovaSprite;
import violet.backend.utils.FileUtil;

#end
using StringTools;
using violet.backend.utils.ArrayUtil;

class LuaScript extends Script {

	#if CAN_LUA_SCRIPT
	var internalScript:LScript;

	override function set_parent(value:Dynamic):Dynamic
		return internalScript.parent = value;
	override function get_parent():Dynamic
		return internalScript.parent;

	public static var psychVariables:Map<String, Dynamic> = [];

	public function new(path:String, preset:Bool = true) {
		super(path);
		// scriptCode += '\n' + FileUtil.getFileContent("assets/data/scripts/import.lua");
		for (i in violet.backend.filesystem.ModdingAPI.getActiveMods()) {
			if (Paths.fileExists('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/scripts/import.lua', true))
				scriptCode += '\n' + FileUtil.getFileContent('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/scripts/import.lua');
		}

		internalScript = new LScript(scriptCode);
		// #if debug
		internalScript.print = (line:Int, s:String) -> {
			var info:PosInfos = {
				fileName: '$folderName/$fileName',
				lineNumber: line,
				className: '$folderName/$fileName',
				methodName: "",
				customParams: [] // Fuck YOU
			}
			violet.backend.console.Logs.traceCallback(s, info);
			// trace(s, (s == "Nova Engine has Lua Support" ? SystemMessage : LogMessage), info);
		}
		// #end
		checkForBlacklistedImports();
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

		// #if !debug
		set('print', (s:String) -> {
			var info:PosInfos = {
				fileName: '$folderName/$fileName',
				lineNumber: 0,
				className: '$folderName/$fileName',
				methodName: "",
				customParams: [] // Fuck YOU
			}
			violet.backend.console.Logs.traceCallback(s, info);
			// trace(s, (s == "Nova Engine has Lua Support" ? SystemMessage : LogMessage), info);
		});
		// #end
		// set('WindowColorMode', WindowColorMode);

		violet.backend.scripting.psych.LuaCallbacks.applyPsychCallbacksToScript(this);

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

	#end
}
