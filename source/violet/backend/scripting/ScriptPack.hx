package violet.backend.scripting;

import flixel.FlxBasic;
import flixel.util.FlxStringUtil;
import violet.backend.scripting.events.EventBase;

class ScriptPack {

	public var scripts:Array<Script> = [];

	public function clear() {
		for (i in scripts) {
			scripts.remove(i);
			i.destroy();
		}
	}

	inline static function setScriptPublicVars(script:Script, object:Dynamic):Void {
		var vars:Map<String, Dynamic> = [];
		if (object != null && object is FlxBasic) {
			var data = Reflect.getProperty(object, 'extra');
			if (data != null) vars = cast data;
		}
		script.setPublicVars(vars);
	}

	public var parent(default, set):Dynamic;
	inline function set_parent(value:Dynamic):Dynamic {
		for (script in scripts) {
			if (script == null) continue;
			script.parent = value;
			setScriptPublicVars(script, value);
		}
		return parent = value;
	}

	public function new() {}

	public function addScript(script:Script) {
		if (script.hasBlacklisted) {
			trace('error:Could not add script "${script.fileName}" to "$this" due to blacklisted imports.');
			return;
		}
		var scriptClass = FlxStringUtil.getClassName(script, true);
		trace('debug:Added script "${script.fileName}" to "$this"');
		script.parent = parent;
		setScriptPublicVars(script, parent);
		scripts.push(script);
	}

	public function set(what:String, to:Dynamic) {
		for (script in scripts) {
			if (script == null) continue;
			script.set(what, to);
		}
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

	public function callVarients<T>(func:String, ?args:Array<Dynamic>, ?def:T):T {
		var funcy = func.charAt(0).toUpperCase() + func.substr(1);
		var varient1 = call(func, args);
		var varient2 = call('on$funcy', args);
		var varient3 = call('upon$funcy', args);
		var out:T = def;
		for (i in [varient1, varient2, varient3]) {
			if (i != def) out = i;
		}
		return out;
	}

	public function event<T:EventBase>(func:String, event:T):T {
		callVarients(func, [event]);
		return event;
	}

}