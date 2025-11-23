package violet.states;

import violet.backend.StateBackend;
import violet.backend.filesystem.Paths;
import violet.backend.utils.NovaUtils;
import violet.states.menus.MainMenu;

class TitleState extends StateBackend {
	public var logoBase:NovaSprite;
	public var logoFull:NovaSprite;
	public var logoText:NovaSprite;

	public var titleEnter:NovaSprite;
	public var titleGirlfriend:NovaSprite;

	public var skippedIntro:Bool = false;
	public var allowSwitch:Bool = false;

	override public function create() {
		super.create();

		titleGirlfriend = new NovaSprite(FlxG.width, 50, Paths.image("menus/titlescreen/gfDanceTitle"));
		titleGirlfriend.addAnim("idle", "gfDance", 24, true);
		titleGirlfriend.playAnim("idle", true);
		add(titleGirlfriend);

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

		FlxTween.tween(logoBase, { alpha: 1 }, 2, { startDelay: 1, ease: FlxEase.smootherStepOut, onComplete: (_)->{
			logoText.playAnim("boot", true);
			logoText.animation.onFinish.add((_)->{
				logoText.visible = false;
				logoBase.visible = false;
				logoFull.visible = true;
				FlxTween.tween(logoFull, { x: 25, y: 25 }, 1, { startDelay: 1, ease: FlxEase.smootherStepInOut });
				FlxTween.tween(logoFull.scale, { x: 0.65, y: 0.65 }, 1, { startDelay: 1, ease: FlxEase.smootherStepInOut, onComplete: (_)->{
					titleEnter.updateHitbox();
					FlxTween.tween(titleEnter, { y: FlxG.height - 150 }, 1, { ease: FlxEase.backOut });
					FlxTween.tween(titleGirlfriend, { x: 512 }, 1, { ease: FlxEase.smootherStepOut, onComplete: (_)->skippedIntro = true });
				}});
			});
			logoText.visible = true;
		}});
		FlxTween.tween(logoBase.scale, { x: 0.7, y: 0.7 }, 2, { startDelay: 1, ease: FlxEase.smootherStepOut });

		titleEnter = new NovaSprite(Paths.image("menus/titlescreen/titleEnter"));
		titleEnter.addAnim("pressed", "pressed", null, [7, 7], 24, true);
		titleEnter.addAnim("idle", "idle", null, [0, 0], 24, true);
		titleEnter.playAnim("idle", true);
		titleEnter.y = FlxG.height;
		add(titleEnter);

		NovaUtils.playMusic("mainMenuTheme", 0);
		FlxG.sound.music.fadeIn(1, 0, 1);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.accept && allowSwitch)
			FlxG.switchState(MainMenu.new);
		if (Controls.accept && skippedIntro) {
			titleEnter.playAnim("pressed", true);
			NovaUtils.playSound("menu/confirm");
			allowSwitch = true;
			new FlxTimer().start(0.5, (_) -> {
				FlxTween.tween(titleEnter, { y: FlxG.height }, 1, { ease: FlxEase.backIn });
				FlxTween.tween(logoFull, { x: -logoFull.width }, 1, { ease: FlxEase.backIn });
				FlxTween.tween(titleGirlfriend, { x: FlxG.width }, 1, { ease: FlxEase.smoothStepIn, onComplete: (_)->{
					FlxG.switchState(MainMenu.new);
				}});
			});
		} else if (!skippedIntro && Controls.accept) {
			forEachAlive((a) -> FlxTween.cancelTweensOf(a));
			skippedIntro = true;
			logoFull.visible = true;
			logoText.visible = false;
			logoBase.visible = false;
			titleEnter.y = FlxG.height - 150;
			titleGirlfriend.x = 512;
			logoFull.x = logoFull.y = 25;
			logoFull.scale.set(0.65, 0.65);
		}

		if (logoFull.visible) return;

		logoBase.updateHitbox();
		logoBase.screenCenter();
		logoBase.y -= 12;

		logoFull.updateHitbox();
		logoFull.screenCenter();

		logoText.x = 313;
		logoText.y = 426;

		titleEnter.updateHitbox();
		titleEnter.screenCenter(X);
		titleEnter.x += 240;
	}
}