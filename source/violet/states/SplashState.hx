package violet.states;

class SplashState extends violet.backend.StateBackend {

    var haxeLogo:NovaSprite;
    var intro:NovaSprite;
    var playedSound:Bool = false;

    override public function create() {
		super.create();
        //
        //
        //
        //
        //
        //
        //                    Rodney, Please make this embed
        //                                               ||
        //                                               ||
        //                                               ||
        //                                               ||
        //                                               ||
        //                                               ||
        //                                               vv
        haxeLogo = new NovaSprite(225, 30, Paths.image('boot'));
        haxeLogo.animation.addByPrefix('intro', 'flixel', 24, false);
        haxeLogo.animation.play('intro', true);
        haxeLogo.updateHitbox();
        haxeLogo.screenCenter();
        haxeLogo.animation.onFinish.addOnce((n)->{
            FlxG.switchState(TitleState.new);
        });
        add(haxeLogo);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        // `animation` is nullable.
        if (haxeLogo.animation?.curAnim?.curFrame >= 1 && !playedSound) {
            playedSound = true;
            FlxG.sound.play(Paths.sound('flixel'));
        }

        if (Controls.accept) {
            FlxG.switchState(TitleState.new);
        }
    }

}