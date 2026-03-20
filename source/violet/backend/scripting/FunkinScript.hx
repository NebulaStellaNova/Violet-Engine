#if CAN_HAXE_SCRIPT
package violet.backend.scripting;

import violet.backend.utils.NovaUtils;

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
import flixel.util.FlxTimer;
// import hxwindowmode.WindowColorMode;
import rulescript.RuleScript;
import rulescript.parsers.HxParser;
import violet.backend.filesystem.Paths;
import violet.backend.objects.NovaSprite;
import violet.backend.utils.FileUtil;

using StringTools;
using violet.backend.utils.ArrayUtil;
using violet.backend.utils.MathUtil;
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

	public function new(path:String, isCode:Bool = false, isHXC:Bool = false):Void {
		super(path, isCode);
		internalScript = new RuleScript();
		internalScript.scriptName = '$folderName/$fileName';
		initVars();
		if (!isHXC) for (i in violet.backend.filesystem.ModdingAPI.getActiveMods()) {
			if (Paths.fileExists('mods/${i.folder}/data/scripts/import.hx', true))
				scriptCode += '\n' + FileUtil.getFileContent('mods/${i.folder}/data/scripts/import.hx');
		}
		checkForBlacklistedImports();
		executeScript();
	}

	function initVars():Void {
		for (key in autoImports.keys()) {
			set(key, autoImports.get(key));
		}
		/* // Flixel
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
		set('FlxTypedGroup', FlxTypedGroup);
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
		set('FunkinSprite', NovaSprite);
		set('NovaSprite', NovaSprite);
		set('Paths', Paths);
		// set('WindowColorMode', WindowColorMode);

		// Custom
		set('add', (object:FlxBasic) -> return FlxG.state.add(object));
		set('remove', (object:FlxBasic) -> return FlxG.state.remove(object));
		set('insert', (pos:Int, object:FlxBasic) -> return FlxG.state.insert(pos, object)); */

		set('trace', (value) -> violet.backend.console.Logs.traceCallback(value, internalScript.getInterp(rulescript.interps.RuleScriptInterp).posInfos()));
		// set('log', (value:Dynamic, type:violet.backend.console.Logs.LogType = LogMessage) -> violet.backend.console.Logs.log(value, type, internalScript.interp.posInfos()));

        // set('lerp', MathUtil.lerp);

		/* set("debugPrint", function(text:Dynamic = '', color:String = 'WHITE') {
            cast (FlxG.state, MusicBeatState).debugPrint(text, color);
        }); */
	}

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		try {
			var func = this.get(funcName);
			if (func != null && Reflect.isFunction(func))
				return Reflect.callMethod(null, func, args ?? []) ?? def;
		} catch (e) {
			// trace('error:${e.message}');
			var data:Array<String> = e.message.split(":");
			var scriptString = data.shift();
			var lineNum = data.shift();
			var errorMsg = data.join(':');
			NovaUtils.addNotification('Novamod Script Exception!', 'Error executing "$fileName":${errorMsg}\nOn Line #${lineNum}', ERROR);
		}
		return null;
	}

	override public function set(variable:String, value:Dynamic):Void
		internalScript.variables.set(variable, value);
	override public function get<T>(variable:String, ?def:T):T
		return internalScript.variables.get(variable) ?? def;

	public function executeScript():Void {
		if (executed) return;
		internalScript.getParser(HxParser).allowAll();
		internalScript.tryExecute(scriptCode, (exception:haxe.Exception) -> {
			var data:Array<String> = exception.message.split(":");
			var scriptString = data.shift();
			var lineNum = data.shift();
			var errorMsg = data.join(':');
			NovaUtils.addNotification('Novamod Script Exception!', 'Error executing "$fileName":${errorMsg}\nOn Line #${lineNum}', ERROR);
			return exception;
		});
		executed = true;
	}
}

#end