package backend.scripts;
import flixel.util.FlxStringUtil;

class ScriptPack {
    public var scripts:Array<Script> = [];

    public function new() {

    }

    public function addScript(script:Script) {
        var scriptClass = FlxStringUtil.getClassName(script);
        trace('Added script "$scriptClass" to "${this}"');
        scripts.push(script);
    }

    public function call(func, ?params:Array<Dynamic>) {
        for (script in scripts) {
            var scriptClass = FlxStringUtil.getClassName(script);
            switch (Type.getClass(script)) {
                case FunkinScript:
                    cast (script, FunkinScript).call(func, params ?? []);
                    //trace("Funkin Script :D");
                case LuaScript:
                    cast (script, LuaScript).call(func, params ?? []);
                    //trace("Lua Script :D");
                case PythonScript:
                    trace("Python Script :D");
            }
        }
    }
}