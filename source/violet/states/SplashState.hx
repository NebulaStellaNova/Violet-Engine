package violet.states;

class SplashState extends violet.backend.StateBackend {

    var haxeLogo:NovaSprite;
    var intro:NovaSprite;
    var playedSound:Bool = false;

    override public function create() {
		super.create();

        haxeLogo = new NovaSprite(225, 30, Paths.image('menus/splashscreen/haxe'));
        haxeLogo.animation.addByPrefix('intro', 's', 24, false);
        haxeLogo.animation.play('intro', true);
        haxeLogo.animation.onFinish.add((_)->flixel.tweens.FlxTween.tween(haxeLogo, { alpha: 0 }, 1, { onComplete: (_)->{
            intro.visible = true;
            intro.animation.play('intro', true);
            intro.screenCenter();
        }}));
        add(haxeLogo);

        intro = new NovaSprite(0, 0, Paths.image('menus/splashscreen/intro'));
        intro.animation.addByPrefix('intro', 'a', 24, false);
        intro.animation.addByIndices('loop', 'a', [124, 125, 126, 127], null, 24, true);
        intro.animation.onFinish.add((name)->{
            if (name != 'intro') return;
            intro.animation.play('loop', true);
            flixel.tweens.FlxTween.tween(intro, { alpha: 0 }, 1, { onComplete: (_)->{
                FlxG.switchState(TitleState.new);
            }});
        });
        intro.visible = false;
        add(intro);
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);

        // `animation` is nullable.
        if (haxeLogo.animation?.curAnim?.curFrame == 36 && !playedSound) {
            playedSound = true;
            FlxG.sound.play(Cache.sound('haxeIntro'));
        }

        if (Controls.accept) {
            FlxG.switchState(TitleState.new);
        }
    }

}