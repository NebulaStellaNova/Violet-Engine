package backend.objects;

import haxe.display.Display.Package;
import flixel.graphics.frames.FlxAtlasFrames;
import backend.filesystem.Paths;
import flixel.FlxSprite;

using StringTools;
class NovaSprite extends FlxSprite {

    var animated:Bool = false;

    var offsets:Map<String, Array<Float>> = [];

    public function new(x, y, ?path:String) {
        super(x, y);
        if (Paths.fileExists(path.replace(".png", ".xml"))) {
            this.animated = true;
            this.frames = FlxAtlasFrames.fromSparrow(path, path.replace(".png", ".xml"));
        } else {
            this.loadGraphic(path);
        }
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        
        if (this.animated) {
            if (offsets.get(this.animation.name) != null) {
                this.offset.set(offsets.get(this.animation.name)[0] ?? 0, offsets.get(this.animation.name)[1] ?? 0);
            } else {
                this.offset.set(0, 0);
            }
        }
    }
    
    // @:unreflective  // no touchy by scripting

    public function playAnim(id, ?forced = false) {
        if (this.animation.exists(id)) {
            this.animation.play(id, forced);
            this.updateHitbox();
        } else
            log('Uh Ooooh! No animation found with ID: $id', WarningMessage);
        this.offset.set(offsets.get(id)[0] ?? 0, offsets.get(id)[1] ?? 0);
    }

    public function addAnim(name:String, prefix:String, ?offsets:Array<Float>, looped:Bool = false) {
        this.animation.addByPrefix(name, prefix, 24, looped);
        this.offsets.set(name, offsets != null ? [-offsets[0], -offsets[1]] : [0, 0]);
        // log('Prefix: $prefix', LogMessage);
    }



}