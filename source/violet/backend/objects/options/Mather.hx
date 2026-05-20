package violet.backend.objects.options;

class Mather {
	public static function wrap(value:Float, min:Float, max:Float):Float {
		// If you're wondering why I'm doing this, it's because FlxMath.wrap requires INTS for some reason.
		if (value > max) value = min;
		else if (value < min) value = max;
		return value;
	}
}