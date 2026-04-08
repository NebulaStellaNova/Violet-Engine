package violet.backend.filesystem;

import violet.backend.utils.FileUtil;
import violet.backend.scripting.ScriptPack;

using violet.backend.utils.ArrayUtil;

class HXCHandler extends flixel.FlxBasic {
	public static var instance:HXCHandler;

	public var hxcScripts:ScriptPack = new ScriptPack();
	public var clear:Void->Void;

	public var importRedirects:Map<String, String> = [
		'funkin.modding.module.Module' => 'violet.backend.scripting.hxc.Module'
	];

	public function addScript(path:String) {
		var scriptCode:String = FileUtil.getFileContent(path);
		for (i in importRedirects.keys()) {
			scriptCode = scriptCode.replace(i, importRedirects.get(i));
		}

		var script = new violet.backend.scripting.FunkinScript(scriptCode, true, true, path);
		script.fullPath = path;
		var filePath = path.split("/");
		script.fileName = filePath.pop();
		if (filePath.getFirstOf() == "mods") script.folderName = filePath[1];
		else script.folderName = filePath.getFirstOf();
		hxcScripts.addScript(script);
	}

	override public function new() {
		super();
		clear = hxcScripts.clear;
		instance = this;
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
	}
}