package violet.states.menus;

import violet.data.song.SongRegistry;
import flixel.math.FlxMath;
import violet.backend.utils.MathUtil;
import flixel.addons.plugin.taskManager.FlxTask;
import violet.data.level.LevelRegistry;
import flixel.FlxCamera;
import violet.backend.SubStateBackend;

class StoryMenu extends SubStateBackend {

    var characters:Array<Array<NovaSprite>> = [];

    var scoreText:NovaText;
    var levelText:NovaText;
    var trackText:NovaText;

    var updateAlpha:Bool = false;

    var curSelected:Int = 0;

    var storyCam:FlxCamera;

    var titleGraphics:Array<NovaSprite> = [];

    var topBar:FlxSprite;
    var weekBG:FlxSprite;
    var bottomBox:FlxSprite;

    var canInteract:Bool = false;

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

        scoreText = new NovaText(11, -100, "HIGH SCORE: 0", 32);
		scoreText.setFont(Paths.font("vcr.ttf"));
        scoreText.updateHitbox();
        scoreText.camera = storyCam;
		scoreText.scrollFactor.set();
        scoreText.y = -scoreText.getHeight();

        levelText = new NovaText(11, -100, "LEVEL NAME", 32);
		levelText.setFont(Paths.font("vcr.ttf"));
        levelText.updateHitbox();
        levelText.camera = storyCam;
		levelText.scrollFactor.set();
        levelText.alpha = 0.7;
        levelText.y = -levelText.getHeight();

        trackText = new NovaText(FlxG.width * 0.05, 500, "- TRACKS -\n\nSome Song Lol", 32);
		trackText.setFont(Paths.font("vcr.ttf"));
        trackText.alignment = CENTER;
        trackText.color = 0xFFE55777;
        trackText.updateHitbox();
        trackText.camera = storyCam;
		trackText.scrollFactor.set();
        trackText.x = -trackText.getWidth();

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
        add(scoreText);
        add(levelText);
        add(trackText);

        updateTrackList();

        trackText.x = -trackText.getWidth();

        FlxTween.tween(topBar, { y: -56 }, 0.5, { ease: FlxEase.backOut });
        FlxTween.tween(weekBG, { y: -45 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.2 });
        FlxTween.tween(bottomBox, { y: 0 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.4 });
        FlxTween.tween(scoreText, { y: 11 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.6 });
        FlxTween.tween(levelText, { y: 11 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.6 });
        FlxTween.tween(trackText, { x: (FlxG.width/2) - (trackText.getWidth()/2) - 450 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.6 });
        FlxTimer.wait(1.2, ()->{
            canInteract = true;
        });
    }

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (Controls.back) {
			exit();
		}

        if (Controls.uiDown) {
            scroll(1);
        }
        if (Controls.uiUp) {
            scroll(-1);
        }

        levelText.text = LevelRegistry.getAllLevels()[curSelected].getTitle();
        levelText.updateHitbox();
        levelText.x = FlxG.width - levelText.getWidth() - 11;

        storyCam.scroll.y = MathUtil.lerp(storyCam.scroll.y, (titleGraphics[curSelected].y - (weekBG.y + weekBG.height)) + (titleGraphics[curSelected].height/2) - 135, 0.2);

        for (i=>titleAsset in titleGraphics) {
            if (updateAlpha) {
                var targetAlpha:Float = i == curSelected ? 1.0 : 0.5;
                titleAsset.alpha = MathUtil.lerp(titleAsset.alpha, targetAlpha, 0.2);
            }
        }
    }

    function scroll(direction:Int, playSound:Bool = true) {
        if (!canInteract) return;
        curSelected = FlxMath.wrap(curSelected + direction, 0, titleGraphics.length - 1);
        updateTrackList();
        if (playSound)
            FlxG.sound.play(Cache.sound('menu/scroll'));
    }

    function updateTrackList() {
        var trackList = "- TRACKS -\n\n";
        var songList = LevelRegistry.getAllLevels()[curSelected].getSongs();
        for (song in songList) {
            trackList += (SongRegistry.getSongByID(song)?.displayName ?? "Unknown") + "\n";
        }
        trackText.text = trackList;
        trackText.updateHitbox();
        if (!canInteract) return;
        trackText.screenCenter(X);
        trackText.x -= 450;
    }

    function exit() {
        if (!canInteract) return;
        updateAlpha = false;
		FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut, startDelay: 0.4 });

        FlxTween.tween(scoreText, { y: -112 }, 0.5, { ease: FlxEase.backIn });
        FlxTween.tween(trackText, { x: -trackText.getWidth() }, 0.5, { ease: FlxEase.backIn });
        FlxTween.tween(levelText, { y: -112 }, 0.5, { ease: FlxEase.backIn });
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