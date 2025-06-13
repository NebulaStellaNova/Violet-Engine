package backend.objects.play;

import backend.filesystem.Paths;

class Note extends NovaSprite {
    public static var swagWidth:Float = 160 * 0.7;

    public var direction:Int = 0;
    public var typeID:Int = 0;
    public var type:String = "default";
    public var skin:String = "default";
    public var time:Float = 0;
    public var extra:Map<String, Dynamic> = new Map<String, Dynamic>();
    public var sustainLength:Float = 0;
    public var strumlineID:Int = 0;
    public var scrollSpeed:Float = 3;
    public var parentStrum:Strum;
    public var skinData:NoteSkin;
    public var directionStrings:Array<String> = ["left", "down", "up", "right"];

    override public function new(parent:Strum, id:Int, time:Float, skin:String) {
        super(0, 0, Paths.image('game/notes/$skin/notes'));
        skinData = Paths.parseJson('images/game/notes/$skin/meta');
        
        var globalOffset:Array<Float> = skinData.offsets.global != null ? [skinData.offsets.global[0], skinData.offsets.global[1]] : [0, 0];
        for (i=>direction in ["noteLeft", "noteDown", "noteUp", "noteRight"]) {
            this.addAnim(directionStrings[i], direction, [skinData.offsets.notes[0]+globalOffset[0], skinData.offsets.notes[1]+globalOffset[1]]);
        }
        this.playAnim(directionStrings[id]);
        this.updateHitbox();
        this.scale.set(0.7, 0.7);
        this.skin = skin;
        this.direction = id;
        this.parentStrum = parent;
        this.time = time;
    }
}