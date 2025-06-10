package backend.objects.play;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;

class StrumLine extends FlxTypedSpriteGroup<Strum> {
    public var type:String = "opponent"; // player, spectator, opponent

    public function new(length:Int, type:String = "opponent", position:Float = 0.5) {
        super();
        this.type = type;
        this.y = 20;
        for (i in 0...length) {
            var strum = new Strum(i % 4);
            strum.parent = this;
            strum.x = (160 * 0.7)*i;
            strum.scale.set(0.7, 0.7);
            strum.updateHitbox();
            this.add(strum);
        }
        this.x = (FlxG.width*position)-(this.width/2);
    }

}