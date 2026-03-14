package violet.states;

import violet.backend.audio.Conductor;
import violet.backend.utils.NovaUtils;
import flixel.math.FlxPoint;
import lemonui.utils.MathUtil;
import flixel.FlxCamera;
import violet.data.character.Character;
import violet.backend.StateBackend;

class GameOverState extends StateBackend {

    // var gameOverData:


    var _:FlxPoint;

    /**
     * ## What's documentation.....
     * ![sil](https://raw.githubusercontent.com/NebulaStellaNova/Hamsters/refs/heads/main/ohh(100).png)
     */
    public function new(character:Character) {
        super();

        Conductor.stop();

        persistentUpdate =  true;


        var gameOverChar = new Character(character.x, character.y, character._data?.deathCharacter ?? "bf-dead");
        gameOverChar.flipX = character.flipX;
        gameOverChar.playAnim('firstDeath', true);
        add(gameOverChar);

        _ = gameOverChar.getMidpoint();
        // FlxTween.tween(camera.scroll, { x: _.x, y: _.y }, 1, { ease: FlxEase.expoOut });

        NovaUtils.playSound("game/gameover/fnf_loss_sfx"); // Plays for a frame then stops idk why
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        FlxG.camera.scroll.x = lerp(FlxG.camera.scroll.x, _.x - (FlxG.width/2), 0.1);
        FlxG.camera.scroll.y = lerp(FlxG.camera.scroll.y, _.y - (FlxG.height/2), 0.1);
    }
}