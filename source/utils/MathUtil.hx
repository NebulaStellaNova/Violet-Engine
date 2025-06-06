package utils;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class MathUtil {
    public static function getElapsedRatio(ratio:Float, fps:Float = 60):Float
		return FlxMath.bound(ratio * fps * FlxG.elapsed, 0, 1);

    public static function lerp(a:Float, b:Float, ratio:Float, fpsSensitive:Bool = true):Float
        return FlxMath.lerp(a, b, fpsSensitive ? getElapsedRatio(ratio) : ratio);

    public static function colorLerp(a:FlxColor, b:FlxColor, ratio:Float, fpsSensitive:Bool = true):FlxColor {
		return FlxColor.fromRGBFloat(
			lerp(a.redFloat, b.redFloat, ratio, fpsSensitive),
			lerp(a.greenFloat, b.greenFloat, ratio, fpsSensitive),
			lerp(a.blueFloat, b.blueFloat, ratio, fpsSensitive),
			lerp(a.alphaFloat, b.alphaFloat, ratio, fpsSensitive)
		);
	}
}