package utils;

class NovaUtil {
    
    public static function objectToMap(object) {
        var map = [
            "init" => true
        ];
        map.remove("init");
        for (field in Reflect.fields(object)) {
            map.set(field, Reflect.field(object, field));
        }
        return map;
    }
}