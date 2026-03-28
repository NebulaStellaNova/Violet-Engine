package violet.backend.objects.play;

import violet.data.animation.AnimationData;
import violet.backend.utils.ParseUtil;

enum abstract Side(String) {
    var L = "left";
    var R = "right";
    // var C = "center";
}

typedef BoxData = {
    var assetPath:String;
    var animations:Array<AnimationData>;
}

typedef ConverstationPiece = {
    var text:String;
    var sound:String;
    var portait:String;
    var side:Side;

    @:default("basic")
    var ?box:String;
    @:default(1.0)
    var ?speed:Float;
}

class DialogueHandler extends FlxSpriteGroup {

    public var boxes:Map<String, NovaSprite> = [];
    public var conversation:Array<ConverstationPiece>;

    override public function new(conversation:Array<ConverstationPiece>) {
        super();
        this.conversation = conversation;
        if (conversation == null) return;
        for (i in conversation) {
            i.box ??= "basic";
            i.speed ??= 1;

            if (!boxes.exists(i.box)) {
                var boxData:BoxData = ParseUtil.jsonOrYaml('data/ui/dialogue/boxes/${i.box}');
                if (boxData != null) {
                    var box = new NovaSprite(0, 0, Paths.image(boxData.assetPath));
                    box.addAnimsFromDataArray(boxData.animations);
                    box.animation.onFinish.add(name->{
                        if (name == "open") box.playAnim('idle', true);
                    });
                    box.updateHitbox();
                    box.x -= box.width/2;
                    box.y -= box.height/2;
                    box.playAnim('open', true);
                    add(box);
                    boxes.set(i.box, box);
                } else {
                    trace('error:Could not find data for dialogue box with id "<cyan>${i.box}<reset>" (skipping...)');
                }
            }
        }
    }

}