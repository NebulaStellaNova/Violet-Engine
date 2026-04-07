package violet.backend.scripting;
#if CAN_PYTHON_SCRIPT


import paopao.hython.Interp;
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

    var interp = new Interp();
    var parser = new Parser();

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
		executeScript();
	}

	public function initVars():Void {
		for (key in autoImports.keys()) set(key, autoImports.get(key));
		set('random', Random);
		set('print', (value) ->{
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
        set('NovaSprite', violet.backend.objects.NovaSprite.new);
		// set('add', FlxG.state.add);
	}

    override public function set(variable:String, value:Dynamic) {
		interp.setVar(variable, value);
    }

	override public function get<T>(variable:String, ?def:T):T
		return interp.getVar(variable) ?? def;

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		var out = null;
		try { out = interp.calldef(funcName, args); } catch (_) { /* trace(_); *//* Do Nothing idgaf */ }
		return out;
	}

	public function executeScript() {
		try {
			interp.execute(parser.parseString(scriptCode));
		} catch (_) {
			var errorMsg = '$_'.replace('SyntaxError: ', '');
			NovaUtils.addNotification('Novamod Script Exception!', 'Error executing "$fileName": ${errorMsg}', ERROR);
		}
	}
}

#end