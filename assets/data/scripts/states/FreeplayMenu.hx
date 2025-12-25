
import violet.data.song.SongRegistry;

var curSelected:Int = 0;
var canSelect:Bool = true;
var daCapsules:Array<FlxTypedSpriteGroup> = [];

var camHUD:FlxCamera;
var capsule:NovaSprite;

function create() {

    camHUD = new FlxCamera();
    camHUD.bgColor = FlxColor.TRANSPARENT;
    camHUD.zoom = 0.8;
    FlxG.cameras.add(camHUD, false);

    for (i => song in SongRegistry.songs) {
        trace(i);

        var capsuleGroup = new FlxTypedSpriteGroup();
        capsuleGroup.cameras = [camHUD];

        capsule = new NovaSprite(0, i, Paths.image("menus/freeplay/capsule/freeplayCapsule"));
        capsule.cameras = [camHUD];
        
        capsuleGroup.add(capsule);
        capsuleGroup.screenCenter(FlxAxes.X);

        add(capsuleGroup);
        daCapsules.push(capsuleGroup);
    }
}

function update() {
    if (controls.back) exit();

    if (controls.uiUp) {
        curSelected = FlxMath.wrap(curSelected - 1, 0, SongRegistry.songs.length - 1);
    }

    if (controls.uiDown) {
        curSelected = FlxMath.wrap(curSelected + 1, 0, SongRegistry.songs.length - 1);
    }


    for (i in 0...daCapsules.length) {
        if (curSelected < i ) {
            daCapsules[i].x = lerp(daCapsules[i].x, 335 - ((i-curSelected)*50), 0.2);
        } else if (curSelected == i) {
            daCapsules[i].x = lerp(daCapsules[i].x, 335, 0.2);
        } else if (curSelected > i) {
            daCapsules[i].x = lerp(daCapsules[i].x, 335 + ((i-curSelected)*50), 0.2);
        }
        daCapsules[i].y = lerp(daCapsules[i].y, ((FlxG.height / 2) + 160 * (i - curSelected)) - 140, 0.2);
    }
    
}

function exit() {
    if (canSelect == false) return;

    FlxTween.tween(FlxG.state.bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut, startDelay: 0.4 });

    new FlxTimer().start(0.9, (_)->{
        close();
    });
}
