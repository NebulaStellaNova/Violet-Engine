package violet.backend.filesystem;

import violet.backend.utils.FileUtil;
import violet.backend.scripting.ScriptPack;

using violet.backend.utils.ArrayUtil;

class HXCHandler extends flixel.FlxBasic {

	public static var instance:HXCHandler;

	public static var importRedirects:Map<String, String> = [
		'funkin.modding.module.Module' => 'violet.backend.scripting.hxc.Module'
	];

	public var hxcScripts:ScriptPack = new ScriptPack();

	override public function new() {
		super();
		instance = this;
	}

	public function addScript(path:String) {
		var scriptCode:String = FileUtil.getFileContent(path);
		for (i in importRedirects.keys())
			scriptCode = scriptCode.replace(i, importRedirects.get(i));

		var script = new violet.backend.scripting.ModuleScript(path);
		var filePath = path.split("/");
		hxcScripts.addScript(script);
	}

	inline public function clear() {
		hxcScripts.clear();
	}

}