package violet.states.menus;

import violet.backend.utils.ScoreUtil;
import flixel.FlxCamera;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import violet.backend.SubStateBackend;
import violet.backend.objects.Bopper;
import violet.backend.objects.BopperSpriteGroup;
import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;
import violet.data.level.Level;
import violet.data.level.LevelRegistry;
import violet.data.song.SongRegistry;

class StoryMenu extends SubStateBackend {

    public static var skipTransition:Bool = false;

    var charactersSprites:TypedBopperSpriteGroup<TypedBopperSpriteGroup<Bopper>> = new TypedBopperSpriteGroup<TypedBopperSpriteGroup<Bopper>>();
    var difficultySprites:FlxTypedSpriteGroup<FlxTypedSpriteGroup<NovaSprite>> = new FlxTypedSpriteGroup<FlxTypedSpriteGroup<NovaSprite>>();

    var leftArrow:NovaSprite;
    var rightArrow:NovaSprite;

    var scoreText:NovaText;
    var levelText:NovaText;
    var trackText:NovaText;

    var updateAlpha:Bool = false;

    static var curSelected:Int = 0;
    static var curDifficulty:Int = 1;
    public var curDifficultyString(get, never):String;
    function get_curDifficultyString() {
        return levelList[curSelected].getDifficulties()[curDifficulty];
    }
    var levelList:Array<Level> = [];

    var storyCam:FlxCamera;

    var titleGraphics:Array<NovaSprite> = [];

    var topBar:FlxSprite;
    var weekBG:FlxSprite;
    var bottomBox:FlxSprite;

    var canInteract:Bool = false;

    var isFlashing:Bool = false;

    public function build() {
		var mainMenu:MainMenu = new MainMenu();
        mainMenu.canSelect = false;
		StoryMenu.skipTransition = true;
		mainMenu.openSubState(this);
		return mainMenu;
	}

    override public function create() {
        super.create();

        NovaUtils.playMenuMusic();

        storyCam = new FlxCamera();
        storyCam.bgColor = FlxColor.TRANSPARENT;
        FlxG.cameras.add(storyCam, false);

        topBar = new NovaSprite(0, -112).makeGraphic(FlxG.width, 112, FlxColor.BLACK);
        topBar.camera = storyCam;
        topBar.scrollFactor.set();

        weekBG = new NovaSprite(0, -500).makeGraphic(FlxG.width, 500, 0xFFFFFFFF);
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

        leftArrow = new NovaSprite(Paths.image('menus/storymenu/arrow'));
        leftArrow.camera = storyCam;
        leftArrow.scrollFactor.set();
        leftArrow.color = 0xFF00ffff;

        rightArrow = new NovaSprite(Paths.image('menus/storymenu/arrow'));
        rightArrow.flipX = true;
        rightArrow.camera = storyCam;
        rightArrow.scrollFactor.set();
        rightArrow.color = 0xFF00ffff;

        add(bottomBox);
        var yLevel = 0.0;
        for (i=>level in levelList = LevelRegistry.getVisibleLevels()) {
            var titleAsset = level.buildTitleGraphic();
            titleAsset.camera = storyCam;
            titleAsset.y = yLevel-titleAsset.height;
            titleAsset.alpha = 0;
            titleAsset.updateHitbox();
            titleAsset.screenCenter(X);
            titleGraphics.push(titleAsset);
            add(titleAsset);
            if (skipTransition) {
                titleAsset.y = yLevel;
                titleAsset.alpha = 1;
            } else FlxTween.tween(titleAsset, { y: yLevel, alpha: 1 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.4 + i * 0.1, onComplete: (_) -> updateAlpha = true });
            yLevel += titleAsset.height + 20;

            var diffGroup:FlxTypedSpriteGroup<NovaSprite> = new FlxTypedSpriteGroup<NovaSprite>();
            for (i in level.getDifficulties()) {
                var sprite = new NovaSprite(Paths.image('menus/storymenu/difficulties/$i'));
                sprite.updateHitbox();
                sprite.x -= sprite.width / 2;
                sprite.y -= sprite.height / 2;
                diffGroup.add(sprite);
            }
            diffGroup.updateHitbox();
            difficultySprites.add(diffGroup);

            var charGroup:TypedBopperSpriteGroup<Bopper> = level.buildProps();
            charactersSprites.add(charGroup);
        }
        add(weekBG);

        difficultySprites.camera = storyCam;
        difficultySprites.updateHitbox();
        difficultySprites.scrollFactor.set();
        difficultySprites.x = FlxG.width + (difficultySprites.width / 2);
        difficultySprites.y = 560;
        add(difficultySprites);

        charactersSprites.camera = storyCam;
        // charactersSprites.updateHitbox();
        charactersSprites.scrollFactor.set();
        charactersSprites.y -= charactersSprites.height;
        // charactersSprites.x -= FlxG.width / 2;
        // charactersSprites.y -= FlxG.height / 2;
        add(charactersSprites);

        add(topBar);
        add(scoreText);
        add(levelText);
        add(leftArrow);
        add(rightArrow);
        add(trackText);

        updateTrackList();
        weekBG.color = levelList[curSelected]._data.background;

        trackText.x = -trackText.getWidth();

        if (skipTransition) {
            topBar.y = -56;
            weekBG.y = -45;
            charactersSprites.y = 0;
            bottomBox.y = 0;
            scoreText.y = 11;
            levelText.y = 11;
            trackText.x = (FlxG.width/2) - (trackText.getWidth()/2) - 450;
            difficultySprites.x = 920;
            canInteract = true;
            updateAlpha = true;
        } else {
            FlxTween.tween(topBar, { y: -56 }, 0.5, { ease: FlxEase.backOut });
            FlxTween.tween(weekBG, { y: -45 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.2 });
            FlxTween.tween(charactersSprites, { y: 0 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.3 });
            FlxTween.tween(bottomBox, { y: 0 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.4 });
            FlxTween.tween(scoreText, { y: 11 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.6 });
            FlxTween.tween(levelText, { y: 11 }, 0.5, { ease: FlxEase.backOut, startDelay: 0.6 });
            FlxTween.tween(trackText, { x: (FlxG.width/2) - (trackText.getWidth()/2) - 450 }, 0.5, { ease: FlxEase.expoOut, startDelay: 0.6 });
            FlxTween.tween(difficultySprites, { x: 920 }, 0.5, { ease: FlxEase.expoOut, startDelay: 0.6 });
            FlxTimer.wait(1.2, ()->{
                canInteract = true;
            });
        }
    }

    var time:Float = 0;
    var scoreLerp:Float = 0;
    override public function update(elapsed:Float) {
        super.update(elapsed);
		time += elapsed;

        scoreLerp = lerp(scoreLerp, ScoreUtil.getLevelScore(levelList[curSelected].id, curDifficultyString), 0.2);
        scoreText.text = 'HIGH SCORE: ' + ScoreUtil.stringifyScore(scoreLerp, 0, true);
        scoreText.updateHitbox();

        if (isFlashing)
			titleGraphics[curSelected].color = (time % 0.1 > 0.05) ? FlxColor.WHITE : 0xFF33ffff;

        if (Controls.back) {
			exit();
            canInteract = false;
		}

        leftArrow.color = Controls.uiLeftPress ? FlxColor.WHITE : 0xFF00ffff;
        rightArrow.color = Controls.uiRightPress ? FlxColor.WHITE : 0xFF00ffff;

        leftArrow.scale.x = leftArrow.scale.y = Controls.uiLeftPress ? 0.9 : 1.0;
        rightArrow.scale.x = rightArrow.scale.y = Controls.uiRightPress ? 0.9 : 1.0;

        if (Controls.accept) {
            selectLevel();
        }

        if (Controls.uiDown) {
            scroll(1);
        }
        if (Controls.uiUp) {
            scroll(-1);
        }
        if (Controls.uiRight) {
            changeDifficulty(1);
        }
        if (Controls.uiLeft) {
            changeDifficulty(-1);
        }

        levelText.text = levelList[curSelected].getTitle();
        levelText.updateHitbox();
        levelText.x = FlxG.width - levelText.getWidth() - 11;

        leftArrow.x = difficultySprites.x - leftArrow.width - 16;
        leftArrow.y = difficultySprites.y + (difficultySprites.height / 2) - (leftArrow.height / 2);

        rightArrow.x = difficultySprites.x + difficultySprites.width + 16;
        rightArrow.y = difficultySprites.y + (difficultySprites.height / 2) - (rightArrow.height / 2);

        storyCam.scroll.y = MathUtil.lerp(storyCam.scroll.y, (titleGraphics[curSelected].y - (weekBG.y + weekBG.height)) + (titleGraphics[curSelected].height/2) - 135, 0.2);
        weekBG.color = MathUtil.colorLerp(weekBG.color, levelList[curSelected]._data.background, 0.2);

        for (i=>group in charactersSprites.members) {
            group.visible = (i == curSelected);
            for (charSprite in group.members) {
                charSprite.updateHitbox();
            }
        }

        for (i=>group in difficultySprites.members) {
            group.visible = (i == curSelected);
            for (j=>diffSprite in group.members) {
                diffSprite.visible = (j == curDifficulty);
            }
        }

        for (i=>titleAsset in titleGraphics) {
            if (updateAlpha) {
                var targetAlpha:Float = i == curSelected ? 1.0 : 0.5;
                titleAsset.alpha = MathUtil.lerp(titleAsset.alpha, targetAlpha, 0.2);
            }
        }
    }

    function scroll(direction:Int, playSound:Bool = true) {
        if (!canInteract) return;
        curSelected = FlxMath.wrap(curSelected + direction, 0, levelList.length - 1);

        updateTrackList();
        if (playSound)
		    NovaUtils.playMenuSFX(SCROLL);
    }

    function changeDifficulty(direction:Int) {
        if (!canInteract) return;
        var difficulties = levelList[curSelected].getDifficulties();
        curDifficulty = FlxMath.wrap(curDifficulty + direction, 0, difficulties.length - 1);
        // FlxG.sound.play(Cache.sound('menu/scroll'));
    }

    function selectLevel() {
        if (!canInteract) return;
        canInteract = false;
        isFlashing = true;
        NovaUtils.playMenuSFX(CONFIRM);
        new FlxTimer().start(1.25, (_)->{
            storyCam.fade(0.25, ()->{
                PlayState.doFadeOut = true;
                PlayState.isStoryMode = true;
                PlayState.playlist = levelList[curSelected].getSongs();
                PlayState.curStoryLevel = levelList[curSelected].id;
                PlayState.loadSong(PlayState.playlist.shift(), curDifficultyString);
            });
        });
    }

    function updateTrackList() {
        var trackList = "- TRACKS -\n\n";
        var songList = levelList[curSelected].getSongs();
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
		NovaUtils.playMenuSFX(CANCEL);

        updateAlpha = false;
		FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0 }, 0.5*2, { ease: FlxEase.quadInOut, startDelay: 0.4 });

        FlxTween.tween(difficultySprites, { x: FlxG.width + (difficultySprites.width / 2) }, 0.5, { ease: FlxEase.backIn });
        FlxTween.tween(scoreText, { y: -112 }, 0.5, { ease: FlxEase.backIn });
        FlxTween.tween(trackText, { x: -trackText.getWidth() }, 0.5, { ease: FlxEase.backIn });
        FlxTween.tween(levelText, { y: -112 }, 0.5, { ease: FlxEase.backIn });
        FlxTween.tween(topBar, { y: -112 }, 0.5, { ease: FlxEase.backIn });
        FlxTween.tween(weekBG, { y: -500 }, 0.5, { ease: FlxEase.backIn, startDelay: 0.2 });
        FlxTween.tween(charactersSprites, { y: -charactersSprites.height }, 0.5, { ease: FlxEase.backIn, startDelay: 0.3 });
        FlxTween.tween(bottomBox, { y: -FlxG.height }, 0.5, { ease: FlxEase.backIn, startDelay: 0.4 });

        for (titleAsset in titleGraphics) {
            FlxTween.cancelTweensOf(titleAsset);
            FlxTween.tween(titleAsset, { alpha: 0 }, 0.5, { startDelay: 0.2 });
        }

		new FlxTimer().start(0.9, (_)->{
            curSelected = 0;
			close();
		});
	}

}