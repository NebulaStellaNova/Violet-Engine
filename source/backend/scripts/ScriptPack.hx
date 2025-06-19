package backend.scripts;

import flixel.util.FlxStringUtil;
import scripting.events.EventBase;

class ScriptPack {
	public var scripts:Array<Script> = [];

	public var parent(default, set):Dynamic;
	inline function set_parent(value:Dynamic):Dynamic {
		for (script in scripts) {
			if (script == null) continue;
			script.parent = value;
		}
		return parent = value;
	}

	public function new() {

	}

	public function addScript(script:Script) {
		var scriptClass = FlxStringUtil.getClassName(script, true);
		trace('Added script "${script.fileName}" to "$this"');
		script.parent = parent;
		scripts.push(script);
	}

	public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {	
		var returner:T = null;
		for (script in scripts) {
			if (script == null) continue;
			var caller:T = script.call(funcName, args);
			if (caller != null)
				returner = caller;
		}
		return returner ?? def;
	}
	public function event<T:EventBase>(func:String, event:T):T {
		for (script in scripts) {
			if (script == null) continue;
			call(func, [event]);
		}
		return event;
	}
}