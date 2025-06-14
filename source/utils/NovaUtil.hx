package utils;

class NovaUtil {
	public static function objectToMap(object) {
		var map = new Map<String, Dynamic>();
		map.remove("init");
		for (field in Reflect.fields(object)) {
			map.set(field, Reflect.field(object, field));
		}
		return map;
	}

	inline public static function capitalizeFirstLetter(string:String) {
		var split = string.split("");
		split[0] = split[0].toUpperCase();
		return split.join("");
	}
}