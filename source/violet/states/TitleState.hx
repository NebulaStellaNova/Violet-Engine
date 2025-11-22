package violet.states;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import violet.backend.utils.NovaUtils;
import violet.backend.StateBackend;
import violet.backend.filesystem.Paths;
import violet.backend.objects.NovaSprite;

class TitleState extends StateBackend {

	public var logoBase:NovaSprite;
	public var logoFull:NovaSprite;
	public var logoText:NovaSprite;

	override public function create() {
		super.create();

		/* bootAnimation = new NovaSprite(Paths.image("menus/titlescreen/bootAnimation"));
		bootAnimation.addAnim("boot", "animation", 40);
		bootAnimation.playAnim("boot", true);
		bootAnimation.scale.set(0.7, 0.7);
		add(bootAnimation); */

		logoFull = new NovaSprite(Paths.image("menus/titlescreen/logoFull"));
		logoFull.scale.set(0.7, 0.7);
		logoFull.visible = false;
		add(logoFull);

		logoBase = new NovaSprite(Paths.image("menus/titlescreen/baseLogo"));
		logoBase.scale.set(0.6, 0.6);
		logoBase.alpha = 0;
		add(logoBase);

		logoText = new NovaSprite(Paths.image("menus/titlescreen/violetEngineText"));
		logoText.scale.set(0.7, 0.7);
		logoText.addAnim("boot", "writingAnimation", 40, false);
		logoText.playAnim("boot", true);
		logoText.animation.finish();
		logoText.visible = false;
		add(logoText);

		FlxTween.tween(logoBase, { alpha: 1 }, 2, { startDelay: 1, ease: FlxEase.smootherStepOut, onComplete: (a)->{
			logoText.playAnim("boot", true);
			logoText.animation.onFinish.add((a)->{
				logoText.visible = false;
				logoBase.visible = false;
				logoFull.visible = true;
				FlxTween.tween(logoFull, { x: 25, y: 25 }, 1, { startDelay: 1, ease: FlxEase.smootherStepInOut });
				FlxTween.tween(logoFull.scale, { x: 0.6, y: 0.6 }, 1, { startDelay: 1, ease: FlxEase.smootherStepInOut });
			});
			logoText.visible = true;
		}});
		FlxTween.tween(logoBase.scale, { x: 0.7, y: 0.7 }, 2, { startDelay: 1, ease: FlxEase.smootherStepOut });

		NovaUtils.playMusic("mainMenuTheme", 0);
		FlxG.sound.music.fadeIn(1, 0, 1);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
		if (logoFull.visible) return;

		logoBase.updateHitbox();
		logoBase.screenCenter();
		logoBase.y -= 12;

		logoFull.updateHitbox();
		logoFull.screenCenter();

		logoText.x = 313;
		logoText.y = 426;
	}
}