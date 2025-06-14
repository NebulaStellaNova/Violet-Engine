package utils;

import flixel.util.FlxSpriteUtil;
import flixel.util.FlxColor;
import backend.objects.NovaSprite;

class NovaUtil {
	public static function desaturateSprite(sprite:NovaSprite, brightness:Float) {
		sprite.colorTransform.redOffset = 255;
		sprite.colorTransform.greenOffset = 255;
		sprite.colorTransform.blueOffset = 255;
		sprite.alpha = brightness;
	}
	
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