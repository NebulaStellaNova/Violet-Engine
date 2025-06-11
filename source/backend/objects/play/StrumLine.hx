package backend.objects.play;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

enum abstract UserType(String) from String to String {
    var OPPONENT = 'opponent';
    var PLAYER = 'player';
    var SPECTATOR = 'spectator';
}

class StrumLine extends FlxTypedSpriteGroup<Strum> {
    public var type:UserType;

    public function new(length:Int, type:UserType = OPPONENT, position:Float = 0.5) {
        super();
        this.type = type;
        this.y = 20;
        for (i in 0...length) {
            var strum = new Strum(i % 4, cast (FlxG.state, MusicBeatState).globalVariables.noteSkin);
            strum.parent = this;
            strum.x = Note.swagWidth*i;
            strum.scale.set(0.7, 0.7);
            strum.updateHitbox();
            this.add(strum);
        }
        this.x = (FlxG.width*position)-(this.width/2);
    }

}