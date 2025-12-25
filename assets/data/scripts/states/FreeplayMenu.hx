import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

var canSelect:Bool = true;

function update() {
    if (controls.back) exit();
}

function exit() {
    if (canSelect == false) return;

    FlxTween.tween(FlxG.state.bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut, startDelay: 0.4 });

    new FlxTimer().start(0.9, (_)->{
        close();
    });
}