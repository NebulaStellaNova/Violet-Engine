package violet.backend.utils;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;

class MathUtil {

	public static function getElapsedRatio(ratio:Float):Float
		return FlxMath.bound(ratio * 60 * FlxG.elapsed, 0, 1);

	public static function lerp(a:Float, b:Float, ratio:Float, fpsSensitive:Bool = true):Float
		return a = FlxMath.lerp(a, b, fpsSensitive ? getElapsedRatio(ratio) : ratio);

	public static function pointLerp(point:FlxPoint, target:Float, ratio:Float, pointer:FlxAxes):FlxPoint{
		if (pointer.x) point.x = lerp(point.x, target, ratio);
		if (pointer.y) point.y = lerp(point.y, target, ratio);
		return point;
	}

	public static function colorLerp(a:FlxColor, b:FlxColor, ratio:Float, fpsSensitive:Bool = true):FlxColor {
		return FlxColor.fromRGBFloat(
			lerp(a.redFloat, b.redFloat, ratio, fpsSensitive),
			lerp(a.greenFloat, b.greenFloat, ratio, fpsSensitive),
			lerp(a.blueFloat, b.blueFloat, ratio, fpsSensitive),
			lerp(a.alphaFloat, b.alphaFloat, ratio, fpsSensitive)
		);
	}

}