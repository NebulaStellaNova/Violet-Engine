package violet.states.menus;

import flixel.text.FlxText;
import flixel.addons.display.FlxBackdrop;
import violet.backend.objects.freeplay.Album;
import violet.backend.utils.ParseUtil;
import violet.backend.audio.Conductor;
import flixel.effects.FlxFlicker;
import violet.backend.utils.ScoreUtil;
import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import violet.data.song.Song;
import violet.data.song.SongRegistry;
// import violet.data.level.LevelRegistry;
import violet.backend.objects.freeplay.Capsule;
// import violet.backend.objects.freeplay.LevelCapsule;
import violet.backend.objects.freeplay.SongCapsule;
import violet.backend.options.Options;
import violet.backend.utils.ParseUtil;
import flixel.FlxCamera;
import violet.backend.SubStateBackend;

class FreeplayMenu extends SubStateBackend {

	public static var skipTransition:Bool = false;
	public static var selectedSongIndex(default, set):Int = 0;
	public var songList:Array<Song>;

	public static var difficultyColors:Map<String, ParseColor> = [
		"easy" => "#00FF00",
		"normal" => "#FFFF00",
		"hard" => "#FF0000",
		"erect" => "#FD579D",
		"nightmare" => "#4E28FB"
	];

	public var albumMap:Map<String, Album> = [];

	public var background:NovaSprite;
	public var bottomBar:NovaSprite;
	public var topBar:NovaSprite;

	public var scoreText:NovaText;
	public var ostText:NovaText;

	public var songCapsules:Array<Capsule> = [];

	public var capsuleOffset:FlxPoint = new FlxPoint(0, 0);

	public var difficultyText:NovaText;

	public var selectASongText:FlxBackdrop;

	public static var instance:FreeplayMenu;
	override public function new() {
		instance = this;
		super();
	}

	override function create() {
		super.create();

		this.camera = new FlxCamera();
		this.camera.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(this.camera, false);

		background = new NovaSprite(-(FlxG.width+4), -2, Paths.image('menus/freeplaymenu/background'));
		background.setGraphicSize(FlxG.width+4, FlxG.height+4);
		background.updateHitbox();
		add(background);

		var album = new Album('placeholder');
		album.x = 0;
		albumMap.set('placeholder', album);
		add(album);

		songList = getSongList();
		for (i => data in songList) {
			if (!albumMap.exists(data._data.album) && data._data.album != null) {
				var album = new Album(data._data.album);
				album.x = skipTransition ? 0 : -(FlxG.width/2);
				albumMap.set(data._data.album, album);
				add(album);

				FlxTween.tween(album, { x: 0 }, 0.5, { ease: FlxEase.expoOut, startDelay: 0.5 });
			}

			var cap = new SongCapsule(data);
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
			camera.fade(FlxColor.BLACK, 0.5, true);
		} else {
			FlxTween.tween(background, {x: 0}, 1, { ease: FlxEase.expoOut });
			FlxTween.tween(capsuleOffset, {x: 0}, 1, { ease: FlxEase.expoOut });
			FlxTween.tween(bottomBar, {y: FlxG.height - bottomBar.height}, 0.5, { ease: FlxEase.expoOut, startDelay: 0.5 });
			FlxTween.tween(topBar, {y: 0}, 0.5, { ease: FlxEase.expoOut, startDelay: 0.5 });
		}

		selectedSongIndex = selectedSongIndex;

		ostText = new NovaText(100, FlxG.height - 47, 500*2, "FIRE FIGHT P1");
		ostText.setFormat(Paths.font("akira", null, "otf"), 50, FlxColor.WHITE, "center");
		ostText.antialiasing = true;
		ostText.scale.x = ostText.scale.y = 0.5;
		ostText.scale.y *= 1.4;
		ostText.updateHitbox();
		add(ostText);
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

		scoreLerp = lerp(scoreLerp, ScoreUtil.getSongScore(songList[selectedSongIndex].id, difficultyText.text.toLowerCase()), 0.3);
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

		if (Controls.uiUp) selectedSongIndex -= 1;
		if (Controls.uiDown) selectedSongIndex += 1;

		if (FlxG.keys.justPressed.HOME) selectedSongIndex = 0;
		if (FlxG.keys.justPressed.END) selectedSongIndex = songList.length-1;

		if (FlxG.keys.justPressed.PAGEUP) selectedSongIndex -= 5;
		if (FlxG.keys.justPressed.PAGEDOWN) selectedSongIndex += 5;

		if (Controls.uiLeft) changeDiff(-1);
		if (Controls.uiRight) changeDiff(1);

		if (Controls.accept) selectSong();

		var targetID:Null<String> = songList[selectedSongIndex]._data.album;
		targetID ??= 'placeholder';
		for (i in albumMap.keys()) {
			var album = albumMap.get(i);
			album.visible = album.id == targetID;
			if (album.visible) {
				ostText.text = album?.ostText ?? "OFFICIAL OST";
				ostText.updateHitbox();
				ostText.x = 1975 + 25 - ostText.width + 125;
			}
		}

		ostText.y = bottomBar.y + bottomBar.height - 47;

		snap = false;
	}

	var timer:FlxTimer;

	static function set_selectedSongIndex(value:Int) {
		if (instance.transitioning) return selectedSongIndex;
		if (value != selectedSongIndex) NovaUtils.playMenuSFX();
		selectedSongIndex = FlxMath.wrap(value, 0, instance.songCapsules.length - 1);
		instance.changeDiff(0);

		var selectASong = new FlxText(0, 0, 0, instance.songList[selectedSongIndex].displayName.toUpperCase() + " · ");
		selectASong.setFormat(Paths.font("Nunito-Medium"), 65, FlxColor.WHITE, "center");
		selectASong.antialiasing = true;
		selectASong.scale.x = selectASong.scale.y = 0.5;
		selectASong.updateHitbox();
		selectASong.drawFrame();

		if (instance.selectASongText != null) instance.remove(instance.selectASongText);
		instance.selectASongText = new FlxBackdrop(selectASong.pixels, X);
		instance.selectASongText.antialiasing = true;
		instance.selectASongText.y = -4;
		instance.selectASongText.scale.x = instance.selectASongText.scale.y = instance.topBar.scale.x;
		instance.selectASongText.updateHitbox();
		instance.selectASongText.alpha = 0.5;
		instance.selectASongText.velocity.set(100, 0);
		instance.insert(instance.members.indexOf(instance.topBar) - 1, instance.selectASongText);

		if (instance.timer != null) instance.timer.cancel();
		instance.timer = FlxTimer.wait(0.5, instance.onTimerEnd);
		return value;
	}

	function changeDiff(amount:Int) {
		if (transitioning) return;
		var song = songList[selectedSongIndex];
		var currentDiffIndex = song.difficulties.indexOf(difficultyText.text.toLowerCase());
		var newDiffIndex = FlxMath.wrap(currentDiffIndex + amount, 0, song.difficulties.length - 1);
		difficultyText.text = song.difficulties[newDiffIndex].toUpperCase();
		difficultyText.updateHitbox();
		difficultyText.x = 215 - (difficultyText.width/2);
		difficultyText.color = difficultyColors.get(difficultyText.text.toLowerCase());
	}

	var current:String = null;

	function onTimerEnd() {
		if (transitioning) return;
		var songData = songList[selectedSongIndex];
		if (current == '${songData.songName}:${songData.variant}') return;
		else current = '${songData.songName}:${songData.variant}';
		Conductor.playSong(songData.songName, songData.variant);
	}

	function selectSong() {
		if (transitioning) return;
		transitioning = true;
		updateCapsulePosition = false;

		NovaUtils.playMenuSFX(CONFIRM);

		for (index=>text in songCapsules) {
			if (index != selectedSongIndex) {
				FlxTween.tween(text, {alpha: 0, x: text.x + 500}, 0.3, { ease: FlxEase.backIn});
			} else {
				var selectedSongMeta = songList[selectedSongIndex];
				FlxFlicker.flicker(text, 1, 0.06, false, false, _->{
					FlxG.sound.music.fadeOut(0.5);
					camera.fade(FlxColor.BLACK, 0.5, ()->{
						PlayState.doFadeOut = true;
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
		for (i in albumMap) {
			FlxTween.tween(i, {x: -(FlxG.width/2)}, 0.5, { ease: FlxEase.expoIn });
		}

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
		for (i in albumMap) {
			FlxTween.cancelTweensOf(i);
		}
	}

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
	**/
	public function getSongList():Array<Song> {
		/* var list:Array<String> = [];
		for (level in LevelRegistry.getAllLevels()) {
			list.push('WEEK:' + level.id);
			list = list.concat([for (song in level.getSongs()) 'SONG:$song']);
		} */

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