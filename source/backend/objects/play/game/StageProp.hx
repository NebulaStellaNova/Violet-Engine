package backend.objects.play.game;

import backend.objects.play.game.Stage.PropAnimation;
import flixel.FlxG;
import backend.filesystem.Paths;
import backend.objects.play.game.Stage.PropData;

class StageProp extends NovaSprite {
    
    public var id:String;
    public var data:PropData;

    public function new(data:PropData, parent:Stage) {
        trace(Paths.image((parent.stageData.directory != null ? parent.stageData.directory + "/" : "") + data.assetPath));
        super(data.position[0], data.position[0], Paths.image((parent.stageData.directory != null ? parent.stageData.directory + "/" : "") + data.assetPath));
        this.data = data;
        this.scale.set(data.scale[0], data.scale[1]);
        this.scrollFactor.set(data.scroll[0], data.scroll[1]);
        this.zIndex = data.zIndex;
        this.id = data.name;
        this.updateHitbox();
        this.x = data.position[0];// + (this.width/2);
        this.y = data.position[1];
        if (data.animations != null) {
            for (anim in data.animations) {
                switch (getAnimationType(anim)) {
                    case "indices":
                        this.addAnimIndices(anim.name, anim.prefix, anim.frameIndices, anim.offsets ?? [0, 0], anim.looped ?? false, anim.frameRate ?? 24);
                        /* if (anim.alias != null) {
                            this.addAnimIndices(anim.alias, anim.prefix, anim.frameIndices, anim.offsets ?? [0, 0], anim.looped ?? false, anim.frameRate ?? 24);
                        } */
                    case "prefix":
                        this.addAnim(anim.name, anim.prefix, anim.offsets ?? [0, 0], anim.looped ?? false, anim.frameRate ?? 24);
                        /* if (anim.alias != null) {
                            this.addAnim(anim.alias, anim.prefix, animOffsets, anim.looped ?? false, anim.frameRate ?? 24);
                        } */
                    default:
                        log("How did this even run?", ErrorMessage);
                }
            }
        }
        if (data.startingAnimation != null) {
            this.playAnim(data.startingAnimation);
        }
    }

    function getAnimationType(animData:PropAnimation) {
		if (animData.frameIndices != null && animData.frameIndices != []) {
			return "indices";
		} else {
			return "prefix";
		}
	}
}