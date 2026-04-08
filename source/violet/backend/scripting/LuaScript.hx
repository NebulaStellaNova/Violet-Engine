package violet.backend.scripting;

#if CAN_LUA_SCRIPT
import haxe.PosInfos;
import lscript.LScript;
import violet.backend.utils.FileUtil;

using StringTools;
using violet.backend.utils.ArrayUtil;

class LuaScript extends Script {

	var internalScript:LScript;

	override function set_parent(value:Dynamic):Dynamic
		return internalScript.parent = value;
	override function get_parent():Dynamic
		return internalScript.parent;

	public var storedVars:Map<String, Dynamic> = [];
	override function setPublicVars(vars:Map<String, Dynamic>):Void
		storedVars = vars ?? [];

	public function new(path:String, preset:Bool = true) {
		super(path);
		this.fullPath = path;
		// scriptCode += '\n' + FileUtil.getFileContent("assets/data/scripts/import.lua");
		for (i in violet.backend.filesystem.ModdingAPI.getActiveMods()) {
			if (Paths.fileExists('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/scripts/import.lua', true))
				scriptCode += '\n' + FileUtil.getFileContent('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/scripts/import.lua');
		}

		internalScript = new LScript(checkForBlacklistedImports());
		internalScript.print = (line:Int, s:String) -> {
			var info:PosInfos = {
				fileName: '$folderName/$fileName',
				lineNumber: line,
				className: '$folderName/$fileName',
				methodName: "",
				customParams: [] // Fuck YOU
			}
			violet.backend.console.Logs.traceCallback(s, info);
		}
		initVars();
		internalScript.execute();
	}

	override function initVars() {
		super.initVars();

		set('print', (value:String) -> {
			final info:PosInfos = {
				fileName: '$folderName/$fileName',
				lineNumber: 0,
				className: '$folderName/$fileName',
				methodName: "",
				customParams: [] // Fuck YOU
			}
			violet.backend.console.Logs.traceCallback(value, info);
		});

		violet.backend.scripting.psych.LuaCallbacks.applyPsychCallbacksToScript(this);
	}

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T
		return internalScript.callFunc(funcName, args ?? []) ?? def;

	override public function set(variable:String, value:Dynamic)
		internalScript.setVar(variable, value);
	override public function get<T>(variable:String, ?def:T):T
		return internalScript.getVar(variable) ?? def;

}
#else
class LuaScript extends Script {
	public function new(path:String, preset:Bool = true) {
		super('', true);
		trace('warning:Lua scripting is not available for the time being, crashes on execute. (path: "$path")');
	}
}
#end