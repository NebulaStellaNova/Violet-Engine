package violet.data.stage;

import violet.data.stage.Stage;
import violet.backend.utils.ParseUtil.ParseColor;
import violet.data.animation.AnimationData;
import thx.semver.Version;

typedef StageData = {
	var name:String;

	/**
	 * If set to true characters will be positioned in the same way as Codename Engine or Psych Engine rather than the V-Slice method.
	 */
	var ?basicCharPos:Bool;

	@:default([])
	var ?props:Array<StagePropData>;

	@:default('0.0.0')
	var ?version:Version;

	@:default(0.7)
	var ?zoom:Float;

	@:default('')
	var ?directory:String;

	@:default([0, 0])
	var ?cameraPosition:Array<Float>;

}

typedef StagePropData = {
	var ?name:String;

	@:default('StageProp')
	var ?type:StageItemType;

	var ?zIndex:Int;

	var ?assetPath:String;

	var id:String;

	var ?properties:Dynamic;

	var ?color:ParseColor;

	@:default(1)
	var ?alpha:Float;

	@:default(0)
	var ?angle:Float;

	@:default(false)
	var ?visible:Bool;

	@:default(false)
	var ?isPixel:Bool;

	@:default(false)
	var ?flipX:Bool;

	@:default(false)
	var ?flipY:Bool;

	@:default([0, 0])
	var ?position:Array<Float>;

	@:default([1, 1])
	var ?scale:Array<Float>;

	@:default([1, 1])
	var ?scroll:Array<Float>;

	// -- Solid Stuff -- \\
	var ?width:Int;
	var ?height:Int;

	// -- Animation Stuff -- \\
	@:default([])
	var ?animations:Array<AnimationData>;

	@:default('idle')
	var ?startingAnimation:String;

	@:default('NONE')
	var ?animationType:String;

	// -- Character Stuff -- \\
	@:default([0, 0])
	var ?cameraOffsets:Array<Float>;

}