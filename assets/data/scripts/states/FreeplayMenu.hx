
import violet.data.song.SongRegistry;
import openfl.filters.GlowFilter;
import violet.states.PlayState;

var curSelected:Int = 0;
var canSelect:Bool = true;
var daCapsules:Array<FlxTypedSpriteGroup> = [];

var camHUD:FlxCamera;
var capsule:GenzuSprite;

var backingCard:GenzuSprite;
var backingImage:GenzuSprite;

var angleMaskShader:AngleMask = new AngleMask();

var screenshot:GenzuSprite;

var blur = new GaussianBlurShader(1);
var glowColor = 0xFF00ccff;

var xPos = -1000; // For Capsule

function create() {

    camHUD = new FlxCamera();
    camHUD.bgColor = FlxColor.TRANSPARENT;
    camHUD.zoom = 0.8;
    FlxG.cameras.add(camHUD, false);

    backingImage = new GenzuSprite(0, 0, Paths.image("menus/freeplay/freeplayBGweek1-bf"));
    backingImage.cameras = [camHUD];
    backingImage.setGraphicSize(FlxG.width / 0.8);
    backingImage.updateHitbox();
    backingImage.screenCenter(Y);
    backingImage.x = -backingImage.width - 150;
    backingImage.shader = angleMaskShader;

    var screenshot = new GenzuSprite(0, 0, Paths.image("menus/freeplay/screenshot-2025-12-27-02-36-39"));
    screenshot.screenCenter();
    screenshot.cameras = [camHUD];
    screenshot.setGraphicSize(FlxG.width / 0.8);
    // add(screenshot);

    backingCard = new GenzuSprite(0, 0, Paths.image("menus/freeplay/backingCard/pinkBack"));
    backingCard.cameras = [camHUD];
    backingCard.setGraphicSize(FlxG.width / 0.8, FlxG.height / 0.8);
    backingCard.scale.x = backingCard.scale.y;
    backingCard.scale.x = backingCard.scale.y *= 1.1;
    backingCard.x = -backingCard.width;
    backingCard.updateHitbox();
    backingCard.screenCenter(Y);
    backingCard.color = 0xFFFFD863;

    add(backingImage);
    add(backingCard);

    FlxTween.tween(backingCard, {x: -160}, 0.7, {ease: FlxEase.quintOut});
    FlxTween.tween(backingImage, {x: 315}, 0.7, {ease: FlxEase.quintOut, startDelay: 0.1});

    for (i => song in SongRegistry.songs) {
        var capsuleGroup = new FlxTypedSpriteGroup(xPos, 0);

        capsuleGroup.cameras = [camHUD];

        capsule = new GenzuSprite(0, 0, Paths.image("menus/freeplay/capsule/freeplayCapsule"));
        capsule.addAnim("idle", "mp3 capsule w backing NOT SELECTED", [], null, 24, true);
        capsule.addAnim("selected", "mp3 capsule w backing0", [], null, 24, true);
        capsule.cameras = [camHUD];

        capsuleGroup.add(capsule);
        capsuleGroup.screenCenter(FlxAxes.X);

        add(capsuleGroup);
        daCapsules.push(capsuleGroup);

        var textGroup = new FlxTypedSpriteGroup(0, 0);
        var txt = new NovaText(0, 0, null, song.displayName, 40);
        txt.setFont(Paths.font("5by7"));
        txt.updateHitbox();
        txt.x += 120;
        txt.y += 42;
        txt.color = glowColor;
        txt.shader = blur;
        textGroup.add(txt);

        var txt2 = new NovaText(0, 0, null, song.displayName, 40);
        txt2.setFont(Paths.font("5by7"));
        txt2.updateHitbox();
        txt2.x += 120;
        txt2.y += 42;
        textGroup.add(txt2);

        capsuleGroup.add(textGroup);
    }

    FlxTimer.wait(0, ()->{
        xPos = 315;
    });
}

function update() {
    if (Controls.back) exit();

    if (Controls.uiUp) {
        NovaUtils.playMenuSFX(NovaUtils.SCROLL);
        curSelected = FlxMath.wrap(curSelected - 1, 0, SongRegistry.songs.length - 1);
    }

    if (Controls.uiDown) {
        NovaUtils.playMenuSFX(NovaUtils.SCROLL);
        curSelected = FlxMath.wrap(curSelected + 1, 0, SongRegistry.songs.length - 1);
    }

    if (Controls.accept) {
        playSong(SongRegistry.songs[curSelected].id, "normal");
    }

    // not sure why I did it like this but imn not changing it lmaooo (make this a function later lol)
    for (i in 0...daCapsules.length) {
        var capsule = daCapsules[i].members[0];
        capsule.playAnim(curSelected == i ? "selected" : "idle");
        var text = daCapsules[i].members[1];
        text.alpha = curSelected == i ? 1 : 0.6;

        if (curSelected < i) {
            daCapsules[i].x = xPos + lerp(daCapsules[i].x - xPos, - ((i - curSelected)*50), 0.2);
        } else if (curSelected == i) {
            daCapsules[i].x = xPos + lerp(daCapsules[i].x - xPos, 0, 0.2);
        } else if (curSelected > i) {
            daCapsules[i].x = xPos + lerp(daCapsules[i].x - xPos, ((i - curSelected)*50), 0.2);
        }
        daCapsules[i].y = lerp(daCapsules[i].y, ((FlxG.height / 2) + 140 * (i - curSelected)) - 140, 0.2);
    }

}

function playSong(?id:String, ?difficulty:String, ?variation:String) {
    PlayState.loadSong(id, difficulty);
}

function exit() {
    if (canSelect == false) return;

    FlxTween.tween(FlxG.state.bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut, startDelay: 0.4 });

    new FlxTimer().start(0.9, (_)->{
        close();
    });
}