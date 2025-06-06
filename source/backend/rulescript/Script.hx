package backend.rulescript;

import flixel.FlxG;
import rulescript.RuleScript;

class Script extends RuleScript {

    public function init() {
        variables.set("trace", log);
    }

    public function initVars() {
        //  -- Methods --  \\
        variables.set("add", FlxG.state.add);
        for (i in Reflect.fields(FlxG.state)) {
            variables.set(i, Reflect.field(FlxG.state, i));
        }

        /* var autoImports = new HScriptImports().getImports();

        for (i in autoImports.keys()) {
            //trace(i);
            set(i, autoImports.get(i));
        } */

    }
    
    public function call(funcName: String, ?args: Array<Dynamic>):Dynamic {
        trace(funcName);
        if (!variables.exists(funcName)) return null;
        final func: Dynamic = variables.get(funcName);

        if(Reflect.isFunction(func))
            return Reflect.callMethod(null, func, args ?? []);

        return null;
    }

    public function get(val:String):Dynamic {
		return variables.get(val);
	}

	public function set(val:String, value:Dynamic) {
		variables.set(val, value);
	}
}