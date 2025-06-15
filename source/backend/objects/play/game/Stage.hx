package backend.objects.play.game;

import openfl.text.StageText;
import backend.filesystem.Paths;
import haxe.display.Display.Package;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;


typedef PropAnimation = {
    var name:String;
    var prefix:String;
    var looped:Bool;
    var flipX:Bool;
    var flipY:Bool;
    var frameIndices:Array<Int>;

}

typedef PropData = {
    var flipX:Bool;
    var flipY:Bool;
    var zIndex:Int;
    var name:String;
    var danceEvery:Int;
    var animType:String;
    var assetPath:String;
    var scale:Array<Float>;
    var scroll:Array<Float>;
    var position:Array<Float>;
    var startingAnimation:String;
    var animations:Array<PropData>;
}

typedef StageCharacter = {
    var zIndex:Int;
    var position:Array<Float>;
    var directory:Array<Float>;
}

typedef StageCharacterGroup = {
    var bf:StageCharacter;
    var dad:StageCharacter;
    var gf:StageCharacter;
}

typedef StageData = {
    var name:String;
    var direcory:String;
    var cameraZoom:Float;
    var props:Array<PropData>;
    var characters:StageCharacterGroup;
}

class Stage extends FlxTypedSpriteGroup<StageProp> {

    public var stageData:StageData;

    public function new(id:String) {
        super();

        if (!Paths.fileExists(Paths.json('data/stages/$id'))) {
            log('Stage Not Found With ID "$id"');
            this.stageData = Paths.parseJson('data/stages/mainStage');
            return;
        }
        this.stageData = Paths.parseJson('data/stages/$id');
    }

    public function getProp(id:String):StageProp {
        for (i in this.members) {
            if (i.id == id) {
                return i;
            }
        }
        log('Could not find prop with id "$id"', ErrorMessage);
        return new StageProp('unknown', 0, 0);
    }

}