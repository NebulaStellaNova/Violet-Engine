import flixel.FlxCamera;
import violet.states.PlayState;
import lime.media.openal.AL;
import hxvlc.flixel.FlxVideoSprite;

public var cutsceneCamera:FlxCamera;

var video:FlxVideoSprite;

function postCreate() {
    cutsceneCamera = new FlxCamera();
    FlxG.cameras.add(cutsceneCamera, false);
}

function onStartCountdown(event) {
    if (!PlayState.hasSeenCutscene && PlayState.isStoryMode && Paths.fileExists('songs/${PlayState.songData.songName}/start-cutscene.mp4')) {
        event.cancel();
        inCutscene = true;

        video = new FlxVideoSprite(0, 0);
        video.antialiasing = true;
        video.bitmap.onEndReached.add(finishCutscene);
        video.bitmap.onFormatSetup.add(function():Void {
            if (video.bitmap != null && video.bitmap.bitmapData != null)
            {
                final scale:Float = Math.min(FlxG.width / video.bitmap.bitmapData.width, FlxG.height / video.bitmap.bitmapData.height);

                video.camera = cutsceneCamera;
                video.setGraphicSize(video.bitmap.bitmapData.width * scale, video.bitmap.bitmapData.height * scale);
                video.updateHitbox();
                video.screenCenter();
            }
        });

        video.load(Paths.file('songs/${PlayState.songData.songName}/start-cutscene.mp4'));

        FlxTimer.wait(0.0001, ()->{
            video.play();
        });
        add(video);
    }
}

function onPause(event) {
    if (inCutscene) video?.pause();
}
function onResume() {
    if (inCutscene) video?.resume();
}

function onSkipCutscene() {
    subState.close();
    finishCutscene();
}

function finishCutscene() {
    inCutscene = false;
    PlayState.hasSeenCutscene = true;
    video.destroy();
    video = null;
    startCountdown();
}

function update(elapsed:Float) {
    if (!inCutscene || video == null) cutsceneCamera.alpha = 0;
}