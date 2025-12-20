package violet.states.menus;

import flixel.math.FlxMath;
import violet.backend.utils.MathUtil;
import flixel.addons.plugin.taskManager.FlxTask;
import violet.data.level.LevelRegistry;
import flixel.FlxCamera;
import violet.backend.SubStateBackend;

class StoryMenu extends SubStateBackend {

    var updateAlpha:Bool = false;

    var curSelected:Int = 0;

    var storyCam:FlxCamera;

    var titleGraphics:Array<NovaSprite> = [];

    var topBar:FlxSprite;
    var weekBG:FlxSprite;
    var bottomBox:FlxSprite;

    override public function create() {
        super.create();

        storyCam = new FlxCamera();
        storyCam.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(storyCam, false);

        topBar = new NovaSprite(0, -112).makeGraphic(FlxG.width, 112, FlxColor.BLACK);
        topBar.camera = storyCam;
        topBar.scrollFactor.set();

        weekBG = new NovaSprite(0, -500).makeGraphic(FlxG.width, 500, 0xFFF9CF51);
        weekBG.camera = storyCam;
        weekBG.scrollFactor.set();

        bottomBox = new NovaSprite(0, -FlxG.height).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bottomBox.camera = storyCam;
        bottomBox.scrollFactor.set();


        add(bottomBox);
        var yLevel = 0.0;
        for (i=>level in LevelRegistry.getAllLevels()) {
            var titleAsset = level.buildTitleGraphic();
            titleAsset.camera = storyCam;
            titleAsset.y = yLevel-titleAsset.height;
            titleAsset.alpha = 0;
            titleAsset.updateHitbox();
            titleAsset.screenCenter(X);
            titleGraphics.push(titleAsset);
            add(titleAsset);
            FlxTween.tween(titleAsset, { y: yLevel, alpha: 1 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.4 + i * 0.1, onComplete: (_) -> updateAlpha = true });
            yLevel += titleAsset.height + 20;
        }
        add(weekBG);
        add(topBar);

        FlxTween.tween(topBar, { y: -56 }, 0.5, { ease: FlxEase.backOut });
        FlxTween.tween(weekBG, { y: -100 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.2 });
        FlxTween.tween(bottomBox, { y: 0 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.4 });
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (Controls.back) {
			exit();
		}

        if (Controls.uiDown) {
            curSelected = FlxMath.wrap(curSelected + 1, 0, titleGraphics.length - 1);
        }
        if (Controls.uiUp) {
            curSelected = FlxMath.wrap(curSelected - 1, 0, titleGraphics.length - 1);
        }

        storyCam.scroll.y = MathUtil.lerp(storyCam.scroll.y, (titleGraphics[curSelected].y - (weekBG.y + weekBG.height)) + (titleGraphics[curSelected].height/2) - 160, 0.2);

        for (i=>titleAsset in titleGraphics) {
            if (updateAlpha) {
                var targetAlpha:Float = i == curSelected ? 1.0 : 0.5;
                titleAsset.alpha = MathUtil.lerp(titleAsset.alpha, targetAlpha, 0.2);
            }
        }
    }

    function exit() {
        updateAlpha = false;
		FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut, startDelay: 0.4 });

        FlxTween.tween(topBar, { y: -112 }, 0.5, { ease: FlxEase.backIn });
        FlxTween.tween(weekBG, { y: -500 }, 0.5, { ease: FlxEase.backIn, startDelay: 0.2 });
        FlxTween.tween(bottomBox, { y: -FlxG.height }, 0.5, { ease: FlxEase.backIn, startDelay: 0.4 });

        for (i=>titleAsset in titleGraphics) {
            FlxTween.cancelTweensOf(titleAsset);
            FlxTween.tween(titleAsset, { alpha: 0 }, 0.5, { startDelay: 0.2 });
        }

		new FlxTimer().start(0.9, (_)->{
			close();
		});
	}
}