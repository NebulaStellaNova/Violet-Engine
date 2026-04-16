package violet.backend.scripting;

import rulescript.types.ScriptedTypeUtil;
import rulescript.scriptedClass.RuleScriptedClass.Access;
import hscript.Expr.ModuleDecl;
import rulescript.parsers.HxParser;
import rulescript.types.Typedefs;
import violet.backend.utils.FileUtil;

class ModuleScript extends Script {
	override public function new(path:String) {
		super(path, false);

		ScriptedTypeUtil.resolveModule = resolveModule;

		Typedefs.register("funkin.modding.module.Module", violet.backend.scripting.hxc.Module);

		var script:Access = new Access(ScriptedTypeUtil.resolveScript(path));
		// script.main();
	}

	public static function resolveModule(path:String):Array<ModuleDecl>
	{
		var parser = new HxParser();
		parser.allowAll();
		parser.mode = MODULE;

		return parser.parseModule(FileUtil.getFileContent(path));
	}
}