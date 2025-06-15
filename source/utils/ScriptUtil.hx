package utils;

import backend.scripts.*;

class ScriptUtil {
    
    public function castScript(script:Script):Null<Script> {
        switch (Type.getClass(script)) {
            case LuaScript:
                return cast (script, LuaScript);
            case FunkinScript:
                return cast (script, FunkinScript);
            case PythonScript:
                return cast (script, PythonScript);
            default:
                log("UNKNOWN SCRIPT TYPE", ErrorMessage);
                return null;
        }
    }
}