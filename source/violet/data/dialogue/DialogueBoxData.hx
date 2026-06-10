package violet.data.dialogue;

import flixel.text.FlxText;
import violet.backend.utils.ParseUtil;
import violet.data.ArrayPoint;
import violet.data.animation.AnimationData;

enum abstract TextBorderStyle(String) from String to String {
	var NONE = 'none';
	var SHADOW = 'shadow';
	var OUTLINE = 'outline';
	var OUTLINE_FAST = 'outline_fast';

	@:from inline public static function fromFlx(value:FlxTextBorderStyle):TextBorderStyle {
		return switch (value) {
			case FlxTextBorderStyle.NONE: NONE;
			case FlxTextBorderStyle.SHADOW: SHADOW;
			case FlxTextBorderStyle.SHADOW_XY(_, _): SHADOW;
			case FlxTextBorderStyle.OUTLINE: OUTLINE;
			case FlxTextBorderStyle.OUTLINE_FAST: OUTLINE_FAST;
		}
	}
	@:to inline public function toFlx():FlxTextBorderStyle {
		return switch (abstract) {
			case NONE: FlxTextBorderStyle.NONE;
			case SHADOW: FlxTextBorderStyle.SHADOW;
			case OUTLINE: FlxTextBorderStyle.OUTLINE;
			case OUTLINE_FAST: FlxTextBorderStyle.OUTLINE_FAST;
		}
	}
}

typedef DialogueBoxData = {
	public var name:String;
	public var assetPath:String;
	public var ?isPixel:Bool;
	public var ?offsets:Array<Float>;
	public var text:DialogueBoxTextData;
	public var ?scale:Float;
	public var ?animations:Array<AnimationData>;
}

typedef DialogueBoxTextData = {
	var ?offsets:Array<Float>;
	var ?width:Float;
	var ?size:Int;
	var ?color:ParseColor;
	var ?font:String;
	var ?borderColor:ParseColor;
	var ?borderSize:ArrayPoint<Float>;
	var ?borderStyle:TextBorderStyle;
}