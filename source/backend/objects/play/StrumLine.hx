package backend.objects.play;

import backend.objects.play.game.Character;
import flixel.FlxG;
import flixel.group.FlxSpriteGroup;

enum abstract UserType(String) from String to String {
    var OPPONENT = 'opponent';
    var PLAYER = 'player';
    var SPECTATOR = 'spectator';
}

class StrumLine extends FlxTypedSpriteGroup<Strum> {
    public var type:UserType;
    public var parentCharacters:Array<Character> = [];

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

    public function addCharacter(character:Character) {
        if (character != null) {
            this.parentCharacters.push(character);
        }
    }

    public function characterPlayAnim(id:String, forced:Bool = false) {
        // Code this
        for (character in this.parentCharacters) {
            character.playAnim(id, forced);
        }
    }
    public function characterPlaySingAnim(id:String, forced:Bool = false) {
        // Code this
        for (character in this.parentCharacters) {
            character.playSingAnim(id);
        }
    }

}