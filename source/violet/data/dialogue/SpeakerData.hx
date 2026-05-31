package violet.data.dialogue;

import violet.data.animation.AnimationData;

typedef SpeakerData = {
	var name:String;
	var assetPath:String;
	var ?flipX:Bool;
	var ?flipY:Bool;
	var ?isPixel:Bool;
	var ?offsets:Array<Float>;
	var ?scale:Float;
	var ?animations:Array<AnimationData>;

	var ?disableFlipCheck:Bool; // Used internally.
}