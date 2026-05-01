package violet.backend.scripting;

import violet.backend.audio.Conductor;
import haxe.io.Path;
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

	public static var importAliases:Map<String, String> = [
		"funkin.modding.module.Module" => "violet.backend.scripting.hxc.Module"
	];
	public static function aliasImports(content:String):String {
		for (i in importAliases.keys()) {
			content = content.replace(i, importAliases.get(i));
		}
		return content;
	}

	// public var internalScript;

	override public function new(path:String) {
		super(path, false);

		ScriptedTypeUtil.resolveModule = function(path)
		{
			if (!FileSystem.exists(path))
				return null;

			return new HxParser().parseModule(aliasImports(FileUtil.getFileContent(path)));
		};

		var contentSplit:Array<String> = FileUtil.getFileContent(path).replace('\n', ' ').split(' ');

		var extension:String = null;
		for (i=>word in contentSplit) {
			if (word == 'extends') {
				extension = contentSplit[i + 1];
				break;
			}
		}
		try {
			switch (extension) {
				case 'Module':
					var script = new violet.backend.scripting.hxc.Module(path);
					// TODO: Implement the shit :D
				default:
					trace('warning:Unknown/Unimplemented V-Slice class "${extension.trim()}" in "${Path.withoutDirectory(path).trim()}", skipping hxc.');
			}
		} catch (e:Dynamic) {
			trace('error:$e');
		}
	}

}