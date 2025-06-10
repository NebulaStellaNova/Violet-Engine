package backend.objects.play;

import flixel.FlxG;
import backend.filesystem.Paths;

class Strum extends NovaSprite {
    public var direction:Int = 0;
    public var skin:String = "default";
    public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
    public var skinData:NoteSkin;
    public var directionStrings:Array<String> = ["left", "down", "up", "right"];
    public var notes:Array<Note> = [];
    public var parent:StrumLine;

    override public function new(id:Int, skin:String = 'default') {
        super(0, 0, Paths.image('game/notes/$skin/strums'));
        skinData = Paths.parseJson('images/game/notes/$skin/meta');

        var direction = directionStrings[id];
        var dir = direction.split('');
        dir[0] = dir[0].toUpperCase();
        var capped = dir.join('');
        this.addAnim('static', 'static$capped', skinData.offsets.statics);
        this.addAnim('confirm', '$direction confirm', skinData.offsets.confirm);
        this.addAnim('pressed', '$direction press', skinData.offsets.pressed);
        
        this.animation.onFinish.add((name)->{
            if (name == "confirm") {
                this.playAnim(this.parent.type == "player" ? "pressed" : "static");
            }
        });
    
        this.playAnim('static');
        this.updateHitbox();
        this.skin = skin;
        this.direction = id;
    }

    public function add(note:Note) {
        this.notes.push(note);
        note.x = this.parent.x + ((160 * 0.7)*direction);
        note.y = this.parent.y;
        FlxG.state.add(note);
    }
}