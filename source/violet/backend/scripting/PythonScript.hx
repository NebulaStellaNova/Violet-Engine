#if CAN_PYTHON_SCRIPT
package violet.backend.scripting;

import paopao.hython.Parser;
import violet.backend.console.Logs;
import violet.backend.filesystem.Paths;
import violet.backend.utils.FileUtil;
import violet.backend.utils.NovaUtils;

using violet.backend.utils.ArrayUtil;
using violet.backend.utils.StringUtil;

class Random {
	public static var randint = FlxG.random.int;
}

class PythonScript extends Script {

	var interp = new PyInterp();
	var parser = new Parser();

	override function set_parent(value:Dynamic):Dynamic
		return interp.parent = value;
	override function get_parent():Dynamic
		return interp.parent;

	override function setPublicVars(vars:Map<String, Dynamic>):Void
		interp.pubVars = vars;

	public function new(path:String) {
		var filePath = path.split("/");
		this.fullPath = path;
		this.fileName = filePath.pop();
		if (filePath.getFirstOf() == "mods") this.folderName = filePath[1];
		else this.folderName = filePath.getFirstOf();
		var code = "";
		for (i in violet.backend.filesystem.ModdingAPI.getActiveMods()) {
			if (Paths.fileExists('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/scripts/import.py', true))
				code += '\n' + FileUtil.getFileContent('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/scripts/import.py') + '\n';
		}
		code += '\n' + FileUtil.getFileContent(path);
		super(code, true);
		initVars();
	}

	override function initVars():Void {
		super.initVars();

		set('random', Random);
		set('print', (value) -> {
			var lineNumber = 0;
			for (ln => i in scriptCode.split('\n')) {
				if (i.contains('print("$value")') || i.contains('print(\'$value\')')) {
					if (i.contains("# ")) continue;
					lineNumber = ln;
					break;
				}
			}
			Logs.traceCallback(value, {methodName: "??", lineNumber: lineNumber, fileName: fileName, className: ""});
		});

		interp.staVars = Script.staticVars;
	}

	override public function set(variable:String, value:Dynamic)
		interp.setVar(variable, value);
	override public function get<T>(variable:String, ?def:T):T
		return interp.getVar(variable) ?? def;

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		try { return interp.calldef(funcName, args); } catch (_) {}
		return null;
	}

	override public function execute():Void {
		if (executed) return;
		try {
			interp.execute(parser.parseString(scriptCode));
			call('new');
			executed = true;
		} catch (_) {
			var errorMsg = '$_'.replace('SyntaxError: ', '');
			NovaUtils.addNotification('Novamod Script Exception!', 'Error executing "$fileName": ${errorMsg}', ERROR);
		}
	}

}

class PyInterp extends paopao.hython.Interp {

	public var parent:Dynamic;
	// even if they can't be created, it's still nice to be able to get them
	public var pubVars:Map<String, Dynamic> = [];
	public var staVars:Map<String, Dynamic> = [];

	override function resetVariables():Void {
		super.resetVariables();
		pubVars = [];
		staVars = [];
		parent = null;
	}

	override function resolve(id:String):Dynamic {
		var v = variables.get(id);
		if (v == null && !variables.exists(id)) {
			if (allowClassResolve) {
				var c = Type.resolveClass(id);
				if (c != null) {
					return Reflect.makeVarArgs(function(args:Array<Dynamic>) {
						return Type.createInstance(c, args);
					});
				}
			}

			if (parent != null)
				return Reflect.getProperty(parent, id);

			if (v == null) {
				if (staVars.exists(id))
					return staVars.get(id);
				if (pubVars.exists(id))
					return pubVars.get(id);
			}

			if (v == null)
				error(EUnknownVariable(id));
		}
		return v;
	}

}
#end