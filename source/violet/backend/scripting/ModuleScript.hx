package violet.backend.scripting;

import violet.backend.utils.NovaUtils;
import rulescript.types.ScriptedModule;
import rulescript.scriptedClass.RuleScriptedClass.ScriptedClass;
import rulescript.RuleScript;
import sys.FileSystem;
import rulescript.types.ScriptedTypeUtil;
import rulescript.scriptedClass.RuleScriptedClass.Access;
import hscript.Expr.ModuleDecl;
import rulescript.parsers.HxParser;
import rulescript.types.Typedefs;
import violet.backend.utils.FileUtil;

class ModuleScript extends Script {

	public var internalScript:RuleScript;

	override public function new(path:String) {
		super(path, false);

		ScriptedTypeUtil.resolveModule = resolveModule;

		Typedefs.register("funkin.modding.module.Module", violet.backend.scripting.hxc.Module);

		var resolved = ScriptedTypeUtil.resolveScript(path);
		var script:Access = new Access(resolved);

		var module = cast (resolved, ScriptedModule);

		var cl = RuleScript.resolveScriptedClass(path, FunkinScript.context);

		if(cl  != null) {
			var inst = cl.createInstance();
			trace("yo");
		}



		// /* internalScript = */ RuleScript.createScriptedInstance(path, FunkinScript.context);
	}

	public static function resolveModule(path:String):Array<ModuleDecl>
	{
		var parser = new HxParser();
		parser.allowAll();
		parser.mode = MODULE;

		if (!FileSystem.exists(path))
			return null;

		var o = parser.parseModule(FileUtil.getFileContent(path));
		return o;
	}

	/* override public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
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
		return internalScript.access.getVariable(variable) ?? def; */
}