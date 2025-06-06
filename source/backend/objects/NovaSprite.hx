package backend.objects;

import flixel.graphics.frames.FlxAtlasFrames;
import backend.filesystem.Paths;
import flixel.FlxSprite;

using StringTools;
class NovaSprite extends FlxSprite {

    var offsets:Map<String, Array<Float>> = [];

    public function new(x, y, ?path:String) {
        super(x, y);
        if (Paths.fileExists(path.replace(".png", ".xml"))) {
            this.frames = FlxAtlasFrames.fromSparrow(path, path.replace(".png", ".xml"));
        } else {
            this.loadGraphic(path);
        }
    }
    
    // @:unreflective  // no touchy by scripting

    public function playAnim(id, ?forced = false) {
        // code this later LOL
        if (this.animation.exists(id))
            this.animation.play(id, forced);
        else
            log('Uh Ooooh! No animation found with ID: $id', WarningMessage);
    }

    public function addAnim(name:String, prefix:String, ?offsets:Array<Float>, looped:Bool = false) {
        this.animation.addByPrefix(name, prefix, 24, looped);
        this.offsets.set(name, offsets ?? [0, 0]);
        // log('Prefix: $prefix', LogMessage);
    }



}