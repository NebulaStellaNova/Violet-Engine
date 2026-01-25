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
    @:default([0, 0])
    var ?offsets:Array<Float>;

    /**
     * Whether the animation should loop or not.
     */
    @:default(false)
    var ?looped:Bool;

    /**
     * Whether the animation's sprites should be flipped horizontally.
     */
    @:default(false)
    var ?flipX:Bool;

    /**
     * Whether the animation's sprites should be flipped vertically.
     */
    @:default(false)
    var ?flipY:Bool;

    /**
     * The frame rate of the animation.
     */
    @:alias("fps")
    @:default(24)
    var ?frameRate:Int;

    /**
     * If you want this animation to use only certain frames of an animation with a given prefix,
     * select them here.
     */
    @:alias("indices")
    @:default([])
    var ?frameIndices:Array<Int>;

    /**
     * Used to determine whether when adding via an atlas if it should get the animation via a frame label name.
     */
    @:alias("label")
    @:default(false)
    var ?byLabel:Bool;
}