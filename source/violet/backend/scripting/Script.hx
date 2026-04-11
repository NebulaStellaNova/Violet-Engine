package violet.backend.scripting;

import violet.backend.objects.special_thanks.GenzuSprite;
import violet.backend.objects.special_thanks.JamSprite;
import violet.backend.utils.NovaUtils;
import flixel.group.FlxGroup;
import flixel.util.FlxAxes;
import violet.backend.utils.MathUtil;
import flixel.FlxBasic;
import flixel.util.FlxStringUtil;
import flixel.util.FlxDestroyUtil;

import violet.backend.utils.FileUtil;
import violet.backend.filesystem.Paths;
import violet.backend.filesystem.ModdingAPI;

using violet.backend.utils.ArrayUtil;

class Script implements IFlxDestroyable {

	var scriptCode:String;
	var executed:Bool = false;

	@:unreflective public var hasBlacklisted:Bool = false;

	public var fileName:String;
	public var fullPath:String;
	public var folderName:String;

	public static var autoImports:Map<String, Dynamic> = [
		// Flixel
		'FlxG' => FlxG,
		'FlxBasic' => FlxBasic,
		'FlxObject' => flixel.FlxObject,
		'FlxCamera' => flixel.FlxCamera,
		'FlxGroup' => FlxGroup,
		'FlxTypedGroup' => FlxTypedGroup,
		'FlxMath' => flixel.math.FlxMath,
		'FlxAngle' => flixel.math.FlxAngle,
		'FlxEase' => FlxEase,
		'FlxTimer' => FlxTimer,
		'FlxSound' => FlxSound,
		'FlxTween' => FlxTween,
		'FlxSpriteGroup' => FlxSpriteGroup,
		'FlxTypedSpriteGroup' => FlxTypedSpriteGroup,

		// Engine
		'Paths' => Paths,
		'FlxText' => NovaText,
		'NovaText' => NovaText,
		'controls' => Controls,
		'Controls' => Controls,
		'NovaUtils' => NovaUtils,
		'FlxSprite' => NovaSprite,
		'NovaSprite' => NovaSprite,
		'FunkinSprite' => NovaSprite,
		'FunkinShader' => violet.backend.objects.ModShader,
		'ModShader' => violet.backend.objects.ModShader,
		'ModState' => violet.states.ModState,

		'Cache' => Cache,

		'CameraOffset' => violet.states.PlayState.CameraOffset,

		// Shaders
		'AngleMask' => violet.backend.shaders.AngleMask,
		'GaussianBlurShader' => violet.backend.shaders.GaussianBlurShader,

		// Special Thanks
		'GenzuSprite' => GenzuSprite,
		'JamSprite' => JamSprite,

		// Objects
		'X' => FlxAxes.X,
		'Y' => FlxAxes.Y,
		'XY' => FlxAxes.XY,
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
			CYAN: FlxColor.CYAN,
			fromRGB: FlxColor.fromRGB,
			fromString: FlxColor.fromString
		}
	];

	// run this function in their sub-classes
	function initVars():Void {
		for (key => value in autoImports)
			set(key, value);
	}

	public var parent(get, set):Dynamic;
	function set_parent(value:Dynamic):Dynamic return null;
	function get_parent():Dynamic return null;

	public function setPublicVars(vars:Map<String, Dynamic>) {}

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

	public function execute() {
		// make the script code here, in their sub-classes
	}

	public function destroy() {
		//
	}

	inline function checkIfBlacklisted(code:String, importString:String) {
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
				NovaUtils.addNotification('Novamod Script Exception!', 'Error executing "$fileName":\nImported module "$importString" is blacklisted.', ERROR);
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