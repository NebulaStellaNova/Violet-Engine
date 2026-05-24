package violet.data.dialogue;

import violet.backend.utils.ParseUtil;
import violet.data.animation.AnimationData;

typedef DialogueBoxData = {
	public var name:String;
	public var assetPath:String;
	public var ?flipX:Bool;
	public var ?flipY:Bool;
	public var ?isPixel:Bool;
	public var ?offsets:Array<Float>;
	public var text:DialogueBoxTextData;
	public var ?scale:Float;
	public var ?animations:Array<AnimationData>;
}

typedef DialogueBoxTextData = {
	var ?offsets:Array<Float>;
	var ?width:Int;
	var ?size:Int;
	var ?color:ParseColor;
	var ?fontFamily:String;
	var shadowColor:ParseColor;
	var ?shadowWidth:Int;
}