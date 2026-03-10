package violet.data.animation;

typedef AnimationData = {
	/**
	 * The name of the animation.
	 */
	var name:String;

	/**
	 * The prefix for each frame in the animation.
	 */
	var ?prefix:String;

	/**
	 * Optionally specify an asset path to use for this specific animation.
	 */
	var ?assetPath:String;

	/**
	 * The offset to use for the animation.
	 */
	var ?offsets:Array<Float>;

	/**
	 * Whether the animation should loop or not.
	 */
	var ?looped:Bool;

	/**
	 * Whether the animation's sprites should be flipped horizontally.
	 */
	var ?flipX:Bool;

	/**
	 * Whether the animation's sprites should be flipped vertically.
	 */
	var ?flipY:Bool;

	/**
	 * The frame rate of the animation.
	 */
	var ?frameRate:Int;

	/**
	 * If you want this animation to use only certain frames of an animation with a given prefix,
	 * select them here.
	 */
	var ?frameIndices:Array<Int>;

	/**
	 * Used to determine whether when adding via an atlas if it should get the animation via a frame label name.
	 */
	var ?byLabel:Bool;
}