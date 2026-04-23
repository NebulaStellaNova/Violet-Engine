package violet.states.menus;

import violet.backend.audio.Conductor;
import flixel.effects.FlxFlicker;
import violet.backend.utils.ScoreUtil;
import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import violet.data.song.Song;
import violet.backend.objects.freeplay.Capsule;
import violet.data.song.SongRegistry;
import violet.backend.options.Options;
import violet.backend.utils.ParseUtil.ParseColor;
import flixel.FlxCamera;
import violet.backend.SubStateBackend;

class FreeplayMenu extends SubStateBackend {

	public static var skipTransition:Bool = false;
	public static var selectedSongIndex:Int = 0;

	public static var difficultyColors:Map<String, ParseColor> = [
		"easy" => "#00FF00",
		"normal" => "#FFFF00",
		"hard" => "#FF0000",
		"erect" => "#FD579D",
		"nightmare" => "#4E28FB"
	];

	/**
	```haxe
		songs = SongRegistry.getAllSongs().filter(song -> {
			var conditions:Array<Bool> = [
				Options.data.developerMode ? true : !song._data?.isDev ?? true,
				song.playableCharacter == player.id,
				song.variant == '' || song.variant == null || song.variant == playableID
			];
			var conditionsMet:Bool = true;
			for (i in conditions)
				if (!i)
					conditionsMet = false;
			return conditionsMet;
		});
	```
	*/

	public var background:NovaSprite;
	public var bottomBar:NovaSprite;
	public var topBar:NovaSprite;

	public var scoreText:NovaText;

	public var songCapsules:Array<Capsule> = [];

	public var capsuleOffset:FlxPoint = new FlxPoint(0, 0);

	public var difficultyText:NovaText;

	override function create() {
		super.create();

		this.camera = new FlxCamera();
		this.camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(this.camera, false);

		background = new NovaSprite(-FlxG.width, 0, Paths.image('menus/freeplaymenu/background'));
		background.setGraphicSize(FlxG.width, FlxG.height);
		add(background);

		for (i => data in getSongList()) {
			var cap = new Capsule(data);
			cap.x = FlxG.width;
			cap.y = 100 * i + (FlxG.height/2) - (85/2);
			add(cap);
			songCapsules.push(cap);
		}

		bottomBar = new NovaSprite(0, FlxG.height, Paths.image('menus/freeplaymenu/bottomBar'));
		bottomBar.setGraphicSize(FlxG.width);
		bottomBar.updateHitbox();
		add(bottomBar);

		topBar = new NovaSprite(0, 0, Paths.image('menus/freeplaymenu/topBar'));
		topBar.scale.set(bottomBar.scale.x, bottomBar.scale.y);
		topBar.updateHitbox();
		topBar.y = -topBar.height;
		add(topBar);

		scoreText = new NovaText(30, 15, 0, "SCORE: 00000000", Paths.font('ErasBoldITC'));
		scoreText.size = 80;
		scoreText.updateHitbox();
		add(scoreText);

		difficultyText = new NovaText(FlxG.width - 30, 15, 0, "NORMAL", Paths.font('akira', null, 'otf'));
		difficultyText.size = 90;
		difficultyText.scale.x = difficultyText.scale.y = 0.5;
		difficultyText.scale.y *= 1.8;
		difficultyText.updateHitbox();
		add(difficultyText);

		capsuleOffset.x = FlxG.width;

		if (skipTransition) {
			background.x = 0;
			bottomBar.y = FlxG.height - bottomBar.height;
			topBar.y = 0;
			capsuleOffset.x = 0;
		} else {
			FlxTween.tween(background, {x: 0}, 1, { ease: FlxEase.expoOut });
			FlxTween.tween(capsuleOffset, {x: 0}, 1, { ease: FlxEase.expoOut });
			FlxTween.tween(bottomBar, {y: FlxG.height - bottomBar.height}, 0.5, { ease: FlxEase.expoOut, startDelay: 0.5 });
			FlxTween.tween(topBar, {y: 0}, 0.5, { ease: FlxEase.expoOut, startDelay: 0.5 });
		}

		changeSelection(0);
	}

	public function build() {
		var mainMenu:MainMenu = new MainMenu();
		mainMenu.canSelect = false;
		FreeplayMenu.skipTransition = true;
		mainMenu.openSubState(this);
		mainMenu.persistentUpdate = true;
		return mainMenu;
	}

	public var snap:Bool = true;

	public var scoreLerp:Float = 0;

	public var updateCapsulePosition:Bool = true;

	override function update(elapsed) {
		super.update(elapsed);

		if (Controls.back && !transitioning) close();

		scoreLerp = lerp(scoreLerp, ScoreUtil.getSongScore(getSongList()[selectedSongIndex].id, difficultyText.text.toLowerCase()), 0.3);
		scoreText.text = "SCORE: " + ScoreUtil.stringifyScore(scoreLerp, 8);

		scoreText.y = topBar.y + 15;
		difficultyText.y = bottomBar.y + 50;

		for (index=>cap in songCapsules) {
			var offset = 55 * (selectedSongIndex - index);
			offset += (selectedSongIndex - index) == 0 ? 0 : 50;

			if (updateCapsulePosition) {
				cap.x -= capsuleOffset.x;
				cap.x = lerp(cap.x, (FlxG.width/2) + offset, snap ? 1 : 0.2);
				cap.x += capsuleOffset.x;
				cap.y -= capsuleOffset.y;
				cap.y = lerp(cap.y, 100 * (index - selectedSongIndex) + (FlxG.height/2) - (85/2), snap ? 1 : 0.2);
				cap.y += capsuleOffset.y;
			}
			cap.backCase.x = lerp(cap.backCase.x, cap.frontCase.x + (index == selectedSongIndex ? -15 : -5), snap ? 1 : 0.2);
		}

		if (Controls.uiUp) changeSelection(-1);
		if (Controls.uiDown) changeSelection(1);

		if (Controls.uiLeft) changeDiff(-1);
		if (Controls.uiRight) changeDiff(1);

		if (Controls.accept) selectSong();

		snap = false;
	}

	function changeSelection(amount:Int) {
		selectedSongIndex = FlxMath.wrap(selectedSongIndex + amount, 0, songCapsules.length - 1);
		if (amount != 0) NovaUtils.playMenuSFX();
		changeDiff(0);
	}

	function changeDiff(amount:Int) {
		var song = getSongList()[selectedSongIndex];
		var currentDiffIndex = song.difficulties.indexOf(difficultyText.text.toLowerCase());
		var newDiffIndex = FlxMath.wrap(currentDiffIndex + amount, 0, song.difficulties.length - 1);
		difficultyText.text = song.difficulties[newDiffIndex].toUpperCase();
		difficultyText.updateHitbox();
		difficultyText.x = 215 - (difficultyText.width/2);
		difficultyText.color = difficultyColors.get(difficultyText.text.toLowerCase());
	}

	function selectSong() {
		updateCapsulePosition = false;

		NovaUtils.playMenuSFX(CONFIRM);

		for (index=>text in songCapsules) {
			if (index != selectedSongIndex) {
				FlxTween.tween(text, {alpha: 0, x: text.x + 500}, 0.3, { ease: FlxEase.backIn});
			} else {
				var selectedSongMeta = getSongList()[selectedSongIndex];
				FlxFlicker.flicker(text, 1, 0.06, false, false, _->{
					FlxG.sound.music.fadeOut(0.5);
					camera.fade(FlxColor.BLACK, 0.5, ()->{
						PlayState.loadSong(selectedSongMeta.id, difficultyText.text.toLowerCase(), selectedSongMeta.variant);
					});
				});
			}
		}
	}

	public var transitioning:Bool = false;

	override function close() {
		if (transitioning) {
			cancelAllTweens();
			super.close();
			return;
		}
		transitioning = true;
		cancelAllTweens();

		if (Std.isOfType(_parentState, MainMenu)) FlxTween.tween(cast(_parentState, MainMenu).bg, { x: 0 }, 1, { ease: FlxEase.quadInOut });
		FlxTween.tween(background, {x: -FlxG.width}, 0.5, { ease: FlxEase.expoIn });
		FlxTween.tween(bottomBar, {y: FlxG.height}, 0.5, { ease: FlxEase.expoIn });
		FlxTween.tween(topBar, {y: -topBar.height}, 0.5, { ease: FlxEase.expoIn });
		FlxTween.tween(capsuleOffset, {x: FlxG.width}, 0.5, { ease: FlxEase.expoIn });

		FlxTimer.wait(0.5, ()->{
			close();
			selectedSongIndex = 0;
		});
	}

	public function cancelAllTweens() {
		FlxTween.cancelTweensOf(background);
		FlxTween.cancelTweensOf(bottomBar);
		FlxTween.cancelTweensOf(topBar);
		FlxTween.cancelTweensOf(capsuleOffset);
	}

	public function getSongList():Array<Song> {
		return SongRegistry.getAllSongs().filter(song -> {
			var conditions:Array<Bool> = [
				Options.data.developerMode ? true : !song._data?.isDev ?? true
			];
			var conditionsMet:Bool = true;
			for (i in conditions)
				if (!i)
					conditionsMet = false;
			return conditionsMet;
		});
	}
}
