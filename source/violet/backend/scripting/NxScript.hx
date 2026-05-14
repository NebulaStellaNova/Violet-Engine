package violet.backend.scripting;

import nx.script.Bytecode.Value;
import haxe.io.Path;
#if CAN_NX_SCRIPT
import haxe.PosInfos;
import nx.script.Interpreter;
import violet.backend.utils.FileUtil;
import violet.backend.utils.NovaUtils;

using violet.backend.utils.ArrayUtil;

class NxScript extends Script {
	var internalScript:Interpreter;

	public function new(path:String, isCode:Bool = false) {
		super(path, isCode);
		internalScript = new Interpreter();
		this.fileName = Path.withoutDirectory(path);
		// initVars();
		execute();
	}

	override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		if (internalScript.vm.getVariable(funcName) == null) return def;
		try {
			return cast internalScript.call(funcName, cast args);
		} catch (e) {
			NovaUtils.addNotification('Novamod Script Exception!', 'Error executing "$fileName:?":$e', ERROR);
		}
		return def;
	}

	override public function set(variable:String, value:Dynamic):Void
		internalScript.set(variable, value);
	override public function get<T>(variable:String, ?def:T):T
		return (cast internalScript.get(variable)) ?? def;

	override public function execute():Void {
		if (executed) return;
		executed = true;
		internalScript.run(scriptCode, this.fileName);
	}
}

#else
class NxScript extends Script {}
#end
