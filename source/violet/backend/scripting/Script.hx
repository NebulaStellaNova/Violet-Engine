package violet.backend.scripting;

import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxAxes;
import violet.backend.utils.MathUtil;
import flixel.FlxBasic;
import flixel.util.FlxStringUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

import violet.backend.utils.FileUtil;
import violet.backend.filesystem.Paths;
import violet.backend.filesystem.ModdingAPI;

using violet.backend.utils.ArrayUtil;

class Script implements IFlxDestroyable {
	var scriptCode:String;
	var executed:Bool = false;

	@:unreflective
	public var hasBlacklisted:Bool = false;

	public var fileName:String;
	public var folderName:String;

	public var autoImports:Map<String, Dynamic> = [
		// Flixel
		'FlxG' => flixel.FlxG,
		'FlxAngle' => flixel.math.FlxAngle,
		'FlxBasic' => flixel.FlxBasic,
		'FlxObject' => flixel.FlxObject,
		'FlxCamera' => flixel.FlxCamera,
		'FlxTween' => flixel.tweens.FlxTween,
		'FlxTimer' => flixel.util.FlxTimer,
		'FlxMath' => flixel.math.FlxMath,
		'FlxTypedGroup' => FlxTypedGroup,
		'FlxSpriteGroup' => flixel.group.FlxSpriteGroup,
		'FlxSound' => flixel.sound.FlxSound,

		// Engine
		'FunkinSprite' => NovaSprite,
		'NovaSprite' => NovaSprite,
		'FlxSprite' => NovaSprite,
		'controls' => Controls,
		'Controls' => Controls,
		'FlxText' => NovaText,
		'Paths' => Paths,

		// Callbacks
		'add' => (object:FlxBasic) -> return FlxG.state.add(object),
		'remove' => (object:FlxBasic) -> return FlxG.state.remove(object),
		'insert' => (pos:Int, object:FlxBasic) -> return FlxG.state.insert(pos, object),
		'lerp' => MathUtil.lerp,

		// Objects
		'FlxAxes' => {
			X: FlxAxes.X,
			Y: FlxAxes.Y,
			XY: FlxAxes.XY
		},
		'FlxColor' => {
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
		}
	];

	public var parent(get, set):Dynamic;
	function set_parent(value:Dynamic):Dynamic
		return null;
	function get_parent():Dynamic
		return null;

	public function new(path:String, isCode:Bool = false) {
		var code:String = !isCode ? FileUtil.getFileContent(path) : path;
		if (!isCode) {
			var filePath = path.split("/");
			this.fileName = filePath.pop();
			if (filePath.getFirstOf() == "mods") this.folderName = filePath[1];
			else this.folderName = filePath.getFirstOf();
		}
		this.scriptCode = code;
	}

	public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T
		return def;

	public function set(variable:String, value:Dynamic) {
		//
	}
	public function get<T>(variable:String, ?def:T):T
		return def;

	public function destroy() {
		//
	}

	inline private function checkIfBlacklisted(code:String, importString:String) {
		var importsIncluded = [];
		var variations = [
			'import $importString;',
			'script:import("$importString")',
			'script:import(\'$importString\')',
			'script.import("$importString")',
			'script.import(\'$importString\')',
			importString
		];
		for (i in variations) {
			if (code.contains(i) && !importsIncluded.contains(importString)) {
				trace('error:Can not execute script "$fileName" as import "$importString" is blacklisted.' );
				violet.backend.CrashHandler.errorNotif('Novamod Script Exception!', 'Error executing "$fileName":\nImported module "$importString" is blacklisted.');
				code.replace(i, "");
				hasBlacklisted = true;
				importsIncluded.push(importString);
			}
		}
		return code;
	}

	public function checkForBlacklistedImports():String { // IDK why I made it return, it's whatever tho.
		for (theImport in ModdingAPI.BLACKLISTED_IMPORTS) {
			var importString:String = FlxStringUtil.getClassName(theImport);
			scriptCode = checkIfBlacklisted(scriptCode, importString);
		}
		return scriptCode = hasBlacklisted ? "" : scriptCode;
	}
}