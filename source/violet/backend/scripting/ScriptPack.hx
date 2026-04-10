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
			var basic:FlxBasic = cast object;
			vars = basic.extra;
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

	public function execute() {
		for (script in scripts) {
			if (script == null) continue;
			script.execute();
		}
	}

	public function callVariants<T>(func:String, ?args:Array<Dynamic>, ?def:T):T {
		var funcy = func.charAt(0).toUpperCase() + func.substr(1);
		var variant1 = call(func, args);
		var variant2 = call('on$funcy', args);
		var variant3 = call('upon$funcy', args);
		var out:T = def;
		for (i in [variant1, variant2, variant3]) {
			if (i != def) out = i;
		}
		return out;
	}

	public function event<T:EventBase>(func:String, event:T):T {
		callVariants(func, [event]);
		return event;
	}

}