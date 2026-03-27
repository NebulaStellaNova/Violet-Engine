package violet.backend.utils;

// Here Rodney :S
class JsonUtil {
    public static function stringifyClass<T>(value:T):String {
        var type = Type.typeof(value);
        switch (type) {
            case TClass(Array):
                var v:Array<Dynamic> = cast value;
                var out:Array<String> = [];
                for (i in v) {
                    if (i is Float || i is Int) {
                        out.push('$i');
                    } else if (i is String) {
                        out.push('"$i"');
                    }
                }
                return '[ ${out.join(', ')} ]';

            default:
                trace(Type.typeof(value));
        }
        return "";
    }

    public static function stringify(?data:Dynamic) {
        var a:Array<Dynamic> = [0, 0, 0.1, "test"];
        trace(stringifyClass(a));
    }
}