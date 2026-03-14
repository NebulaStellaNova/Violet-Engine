import violet.states.PlayState;
import flixel.tweens.FlxTween;
import violet.backend.audio.Conductor;
import flixel.addons.sound.FlxRhythmConductor;

public var currentAudio;
public var cutsceneLoop;
var timers = [];

function postCreate() {
    if (PlayState.hasSeenCutscene || !PlayState.isStoryMode) return;
    camHUD.alpha = 0;
}

function wait(duration, callback) {
    timers.push(FlxTimer.wait(duration, callback));
}

function onStartCountdown(event) {
    if (PlayState.hasSeenCutscene || !PlayState.isStoryMode) return;
    inCutscene = true;
    event.cancel();

    // cutsceneAudioP1.play();
    cutsceneLoop = NovaUtils.playSound('cutscene/tank/DISTORTO', 1);
    cutsceneLoop.play();
    cutsceneLoop.fadeIn(1, 0, 0.5);

    var cutsceneAudioP1 = NovaUtils.playSound('cutscene/tank/ugh-1', 1);
    cutsceneAudioP1.pause();

    var cutsceneAudioBeep = NovaUtils.playSound('cutscene/tank/ugh-beep', 1);
    cutsceneAudioBeep.pause();

    var cutsceneAudioP2 = NovaUtils.playSound('cutscene/tank/ugh-2', 1);
    cutsceneAudioP2.pause();

    FlxG.sound.pause();

    var cutsceneTankman = new NovaSprite(115, 325, Paths.image('stages/week7/cutscene/ugh/part1'));
    cutsceneTankman.addAnim('animation', 'TANK TALK 1 P1');
    cutsceneTankman.playAnim('animation', true);
    insert(members.indexOf(strumLines.members[0].characters[0]), cutsceneTankman);

    var cutsceneTankman2 = new NovaSprite(115, 325, Paths.image('stages/week7/cutscene/ugh/part2'));
    cutsceneTankman2.addAnim('animation2', 'TANK TALK 1 P2', null, [-37.5, -8]);
    cutsceneTankman2.playAnim('animation2', true);
    cutsceneTankman2.visible = false;
    insert(members.indexOf(strumLines.members[0].characters[0]), cutsceneTankman2);

    cutsceneTankman.playAnim('animation', true);

    wait(0.05, ()->{
        FlxG.sound.pause();
        currentAudio = cutsceneAudioP1;
        currentAudio.play();
        cutsceneLoop.play();
    });
    wait(3, ()->handleEvent({name: "Camera Movement", params: [1]}));
    wait(4, ()->{
        FlxG.sound.pause();
        strumLines.members[1].characters[0].playSingAnim(2);
        currentAudio = cutsceneAudioBeep;
        currentAudio.play();
        cutsceneLoop.play();
    });
    wait(4.5, ()->{
        strumLines.members[1].characters[0].dance(true);
    });
    wait(5.25, ()->handleEvent({name: "Camera Movement", params: [0]}));
    wait(6, ()->{
        FlxG.sound.pause();
        FlxG.state.remove(cutsceneTankman);
        currentAudio = cutsceneAudioP2;
        currentAudio.play();
        cutsceneLoop.play();
        cutsceneTankman2.playAnim('animation2', true);
        cutsceneTankman2.visible = true;
    });
    wait(13, ()->{
        FlxTween.tween(camHUD, { alpha: 1 }, 0.5);
        cutsceneLoop.fadeOut(1);
        cutsceneTankman2.visible = false;
        PlayState.hasSeenCutscene = true;
        strumLines.members[0].characters[0].visible = true;
        inCutscene = false;
        startCountdown();
    });
    // trace("Fuck.You.Rodney.F");
}

function pauseCutscene() {
    if (PlayState.hasSeenCutscene || !PlayState.isStoryMode) return;
    for (i in timers) i.active = false;
    currentAudio.pause();
    cutsceneLoop.pause();
    // for (i in FlxG.sound.group) i?.stop();
}

function resumeCutscene() {
    if (PlayState.hasSeenCutscene || !PlayState.isStoryMode) return;
    for (i in timers) i.active = true;
    currentAudio.resume();
    cutsceneLoop.resume();
}

function postUpdate(elapsed:Float) {
    if (PlayState.hasSeenCutscene || !PlayState.isStoryMode) return;
    // camGame.zoom = 0.2;
    strumLines.members[0].characters[0].visible = false;
}

function onSkipCutscene() {
    for (i in timers) {
        i.onComplete(i);
        i.cancel();
    }
    subState.close();
    currentAudio.stop();
    cutsceneLoop.stop();
}

function onPause(event) pauseCutscene();
function onResume(event) resumeCutscene();