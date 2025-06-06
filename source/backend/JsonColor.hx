package backend;

import flixel.util.FlxColor;

/**
 * This abstract is used to help with parsing variables that are supposed to return color codes.
 */
enum abstract JsonColor(String) {
	@:from inline public static function fromString(from:String):JsonColor
		return cast FlxColor.fromString(from ?? 'white').toWebString();
	@:to inline public function toString():String
		return this ?? '#FFFFFF';

	@:from inline public static function fromInt(from:Int):JsonColor
		return FlxColor.fromInt(from ?? FlxColor.WHITE).toWebString();
	@:to inline public function toInt():Int
		return FlxColor.fromString(this ?? 'white');
	@:to inline public function toFlxColor():FlxColor
		return FlxColor.fromString(this ?? 'white');

	@:from inline public static function fromArray(from:Array<Int>):JsonColor
		return cast FlxColor.fromRGB(from[0] ?? 255, from[1] ?? 255, from[2] ?? 255);
}