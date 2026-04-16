package violet.backend.filesystem;

import violet.backend.utils.FileUtil;
import violet.backend.scripting.ScriptPack;

using violet.backend.utils.ArrayUtil;

class HXCHandler extends flixel.FlxBasic {

	public static var instance:HXCHandler;

	public var hxcScripts:ScriptPack = new ScriptPack();

	override public function new() {
		super();
		instance = this;
	}

	public function addScript(path:String) {
		var script = new violet.backend.scripting.ModuleScript(path);
		hxcScripts.addScript(script);
	}

	inline public function clear() {
		hxcScripts.clear();
	}

}