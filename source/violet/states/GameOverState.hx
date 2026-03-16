package violet.states;

import violet.data.character.Character;
import violet.backend.audio.Conductor;
import violet.backend.utils.NovaUtils;
import violet.backend.StateBackend;
import lemonui.utils.MathUtil;
import flixel.math.FlxPoint;
import flixel.FlxCamera;

class GameOverState extends StateBackend {

    // var gameOverData:
    static var charData:Character;

    var gameOverChar:Character;

    var doBop:Bool = false;

    var sounds:Array<FlxSound> = [];

    var pressedConfirm:Bool = false;

    var _:FlxPoint;

    /**
     * ## What's documentation.....
     * ![sil](https://raw.githubusercontent.com/NebulaStellaNova/Hamsters/refs/heads/main/ohh(100).png)
     */
    public function new(character:Character) {
        super();
        charData = character;

        Conductor.stop();
    }

    override function create() {
        super.create();

        gameOverChar = new Character(charData.x, charData.y, charData._data?.deathCharacter ?? "bf-dead");
        gameOverChar.flipX = charData.flipX;
        gameOverChar.canDance = false;
        gameOverChar.playAnim('firstDeath', true);
        add(gameOverChar);

        _ = gameOverChar.getMidpoint();
        // FlxTween.tween(camera.scroll, { x: _.x, y: _.y }, 1, { ease: FlxEase.expoOut });

        var sound:FlxSound = NovaUtils.playSound("game/gameover/fnf_loss_sfx");
        sounds.push(sound);
        sound.onComplete = ()->{
            sounds.push(NovaUtils.playMusic("gameOver"));
            doBop = true;
        }
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        FlxG.camera.scroll.x = lerp(FlxG.camera.scroll.x, _.x - (FlxG.width/2), 0.1);
        FlxG.camera.scroll.y = lerp(FlxG.camera.scroll.y, _.y - (FlxG.height/2), 0.1);
        if (Controls.accept) {
            PlayState.doFadeOut = true;
            if (!pressedConfirm) {
                stopAllSounds();
                sounds.push(NovaUtils.playSound("game/gameover/fnf_loss_end"));
                gameOverChar.playAnim('deathConfirm', true);
                FlxG.camera.fade(FlxColor.BLACK, 5, ()->FlxG.switchState(new PlayState()));
                pressedConfirm = true;
            } else {
                stopAllSounds();
                FlxG.switchState(new PlayState());
            }
        }

        if (Controls.resetState || Controls.reloadGame) {
            stopAllSounds();
            FlxG.switchState(new PlayState());
        }
    }

    function stopAllSounds() {
        for (i in sounds) {
            i?.stop();
            sounds.remove(i);
        }
    }

    override function beatHit(curBeat:Int) {
        super.beatHit(curBeat);
        if (pressedConfirm) return;
        gameOverChar.playAnim('deathLoop', true);
    }
}