package backend.objects.play;

import flixel.FlxG;
import backend.filesystem.Paths;
import flixel.util.FlxSort;

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
        var globalOffset:Array<Float> = skinData.offsets.global != null ? [skinData.offsets.global[0], skinData.offsets.global[1]] : [0, 0];
        this.addAnim('static', 'static$capped', [skinData.offsets.statics[0]+globalOffset[0], skinData.offsets.statics[1]+globalOffset[1]]);
        this.addAnim('confirm', '$direction confirm', [skinData.offsets.confirm[0]+globalOffset[0], skinData.offsets.confirm[1]+globalOffset[1]]);
        this.addAnim('pressed', '$direction press', [skinData.offsets.pressed[0]+globalOffset[0], skinData.offsets.pressed[1]+globalOffset[1]]);

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

    override function update(elapsed:Float) {
        super.update(elapsed);
        notes.sort((a:Note, b:Note) -> FlxSort.byValues(FlxSort.ASCENDING, a.time, b.time));
    }

    public function add(note:Note) {
        this.notes.push(note);
        note.x = this.parent.x + (Note.swagWidth*direction);
        note.y = this.parent.y;
        FlxG.state.add(note);
    }

    public function onHit(rating:String = "sick", note:Note) {

        if (rating == "sick" || rating == "good") {
            var splash = new NovaSprite(0, 0, Paths.image('game/notes/${note.skinData.splashSkin.name}/splashes'));
            var color = ["purple", "blue", "green", "red"][note.direction];
            splash.addAnim("hit", 'note impact ${FlxG.random.int(1, 2)} ${color}', note.skinData.offsets.splashes);
            splash.playAnim("hit", true);
            splash.updateHitbox();
            splash.x = this.getMidpoint().x - (splash.width/2);
            splash.y = this.getMidpoint().y - (splash.height/2);
            splash.animation.onFinish.add((name)->{
                FlxG.state.remove(splash);
                //splash.destroy();
            });
            FlxG.state.add(splash);
        }
    }
}