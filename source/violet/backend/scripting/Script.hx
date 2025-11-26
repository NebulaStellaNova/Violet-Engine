package violet.backend.scripting;

import flixel.util.FlxStringUtil;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

import violet.backend.utils.FileUtil;
import violet.backend.filesystem.Paths;
import violet.backend.filesystem.ModdingAPI;

using violet.backend.utils.ArrayUtil;

class Script implements IFlxDestroyable {
	var hasBlacklisted:Bool = false;
	var scriptCode:String;
	var executed:Bool = false;

	public var fileName:String;
	public var folderName:String;

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
		var variations = [
			'import $importString;',
			'script:import("$importString")',
			'script:import(\'$importString\')',
			'script.import("$importString")',
			'script.import(\'$importString\')'
		];
		for (i in variations) {
			if (code.contains(i)) {
				trace('error:Can not execute script "$fileName" as import "$importString" is blacklisted.' );
				lime.app.Application.current.window.alert('Error executing "$fileName":\nImported module "$importString" is blacklisted.', 'Novamod Script Exception');
				code.replace(i, "");
				hasBlacklisted = true;
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