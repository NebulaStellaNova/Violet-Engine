package violet.backend.scripting;
#if CAN_HAXE_SCRIPT
import rulescript.Context;

import flixel.*;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
// import hxwindowmode.WindowColorMode;
import rulescript.RuleScript;
import rulescript.parsers.HxParser;
import violet.backend.filesystem.Paths;
import violet.backend.objects.NovaSprite;
import violet.backend.utils.FileUtil;
import violet.backend.console.Logs;
import violet.backend.utils.NovaUtils;
import haxe.io.Path;

using StringTools;
using violet.backend.utils.ArrayUtil;
using violet.backend.utils.MathUtil;

/**
 * @author @Zyflx (mostly)
 * @modified @NebulaStellaNova
 */
class FunkinScript extends Script {

	public static var context:Context = new Context();
	var internalScript:RuleScript;

	override function set_parent(value:Dynamic):Dynamic
		return internalScript.superInstance = value;
	override function get_parent():Dynamic
		return internalScript.superInstance;

	override function setPublicVars(vars:Map<String, Dynamic>):Void
		internalScript.context.publicVariables = vars;

	public var isHXC:Bool = false;
	public function new(path:String, isCode:Bool = false, isHXC:Bool = false, ?extraPath:String):Void {
		super(path, isCode);
		this.isHXC = isHXC;
		this.fullPath = path;
		if (extraPath != null) {
			this.fullPath = extraPath;
			this.fileName = Path.withoutDirectory(extraPath);
		}
		internalScript = new RuleScript(context);
		internalScript.scriptName = '$folderName/$fileName';
		initVars();
		if (!isHXC) for (i in violet.backend.filesystem.ModdingAPI.getActiveMods()) {
			if (Paths.fileExists('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/scripts/import.hx', true))
				scriptCode += '\n' + FileUtil.getFileContent('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/scripts/import.hx');
		}
		checkForBlacklistedImports();
	}

	override function initVars():Void {
		// super.initVars();

		set('log', (value:Dynamic, type:LogType = LogMessage) ->
			Logs.log(value, type, internalScript.access.posInfos())
		);
		set('trace', Reflect.makeVarArgs(args ->
			Logs.traceCallback([for (arg in args) Std.string(arg)].join(', '), internalScript.access.posInfos())
		));
	}

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		if (!internalScript.access.variableExists(funcName)) return def;
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
			NovaUtils.addNotification('Novamod Script Exception!', 'Error executing "$fileName:$lineNum":$errorMsg', ERROR);
		}
		return def;
	}

	override public function set(variable:String, value:Dynamic):Void
		internalScript.access.setVariable(variable, value);
	override public function get<T>(variable:String, ?def:T):T
		return internalScript.access.getVariable(variable) ?? def;


	/**
	 * Implement: https://github.com/Kriptel/RuleScript/blob/master/test/src/Main.hx#L339
	 */
	override public function execute():Void {
		if (executed) return;
		if (isHXC) internalScript.getParser(HxParser).mode = MODULE;
		internalScript.getParser(HxParser).allowAll();
		internalScript.tryExecute(scriptCode, (exception:haxe.Exception) -> {
			var data:Array<String> = exception.message.split(":");
			var scriptString = data.shift();
			var lineNum = data.shift();
			var errorMsg = data.join(':');
			NovaUtils.addNotification('Novamod Script Exception!', 'Error executing "$fileName":${errorMsg}\nOn Line #${lineNum}', ERROR);
			return exception;
		});
		call('new');
		executed = true;
	}

}
#end