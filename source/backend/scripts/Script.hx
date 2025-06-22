package backend.scripts;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import backend.filesystem.Paths;

using utils.ArrayUtil;

class Script implements IFlxDestroyable {
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
		var code:String = !isCode ? Paths.readStringFromPath(path) : path;
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
}