package violet.data.stage;

import violet.data.animation.AnimationData;
import thx.semver.Version;

typedef StageData = {
    var name:String;

    @:optional
    @:default([])
    var props:Array<StagePropData>;

    @:optional
    @:default("0.0.0")
    var version:Version;

    @:optional
    @:default(0.7)
    var zoom:Float;

    @:optional
    @:default("")
    var directory:String;

    @:optional
    @:default([0, 0])
    var cameraPosition:Array<Float>;

}

typedef StagePropData = {
    @:optional
    var name:String;

    @:optional
    @:default("StageProp")
    var type:String;

    @:optional
    var assetPath:String;

    var id:String;

    @:optional
    var properties:Dynamic;

    @:optional
    @:default(1)
    var alpha:Int;

    @:optional
    @:default(false)
    var visible:Bool;

    @:optional
    @:default(false)
    var isPixel:Bool;

    @:optional
    @:default(false)
    var flipX:Bool;

    @:optional
    @:default(false)
    var flipY:Bool;

    @:optional
    @:default([0, 0])
    var position:Array<Float>;

    @:optional
    @:default([1, 1])
    var scale:Array<Float>;

    @:optional
    @:default([1, 1])
    var scroll:Array<Float>;

    // -- Animation Stuff -- \\
    @:optional
    @:default([])
    var animations:Array<AnimationData>;

    @:optional
    @:default("idle")
    var startingAnimation:String;

    @:optional
    @:default("NONE")
    var animationType:String;

    // -- Character Stuff -- \\
    @:optional
    @:default([0, 0])
    var cameraOffsets:Array<Float>;

}