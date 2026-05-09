package violet.states.menus;

import flixel.FlxCamera;
import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import violet.backend.SubStateBackend;
import violet.backend.audio.Conductor;
import violet.backend.objects.freeplay.Album;
import violet.backend.objects.freeplay.Capsule;
import violet.backend.objects.freeplay.LevelCapsule;
import violet.backend.objects.freeplay.SongCapsule;
import violet.backend.options.Options;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.ParseUtil;
import violet.backend.utils.ScoreUtil;
import violet.data.level.LevelRegistry;
import violet.data.song.Song;
import violet.data.song.SongRegistry;

@:forward
abstract CapsuleInst(Capsule) from Capsule to Capsule from SongCapsule from LevelCapsule {
	inline public function getLevel<T>(func:LevelCapsule->T):Null<T> {
		return getEither(
			(cap, _) -> {
				if (cap != null)
					return func(cap);
				return null;
			}
		);
	}
	inline public function getSong<T>(func:SongCapsule->T):Null<T> {
		return getEither(
			(_, cap) -> {
				if (cap != null)
					return func(cap);
				return null;
			}
		);
	}

	inline public function getEither<T>(func:(LevelCapsule, SongCapsule) -> T):Null<T> {
		if (this is LevelCapsule)
			return func(cast this, null);
		if (this is SongCapsule)
			return func(null, cast this);
		return null;
	}
}

typedef RawCategoryData = {
	var image:String;
	var ?filterBy:CapsuleInst -> Bool;
	var ?sortBy:(CapsuleInst, CapsuleInst) -> Int;
}
@:forward
abstract CategoryData(RawCategoryData) from RawCategoryData to RawCategoryData {
	public function getImage():flixel.graphics.FlxGraphic {
		var path:String = this.image;
		if (!Paths.fileExists(Paths.image(path), true))
			path = 'menus/freeplaymenu/categories/${this.image}';
		return Cache.image(path);
	}

	public function filterList(list:Array<CapsuleInst>):Array<CapsuleInst> {
		if (this.filterBy == null) return list;
		return list.filter(this.filterBy);
	}
	public function sortList(list:Array<CapsuleInst>):Void
		if (this.sortBy != null)
			list.sort(this.sortBy);
}

class FreeplayMenu extends SubStateBackend {

	public static var skipTransition:Bool = false;
	public static var selectedSongIndex(default, set):Int = 0;
	public static var selectedCategoryIndex(default, set):Int = 0;

	// might not get used, unsure at this time
	@:unreflective var _levels:Map<String, LevelCapsule> = [];
	@:unreflective var _songs:Map<String, SongCapsule> = [];

	public var caregoryGroup:FlxTypedGroup<NovaSprite>;
	public final categoryData:Map<String, CategoryData> = [
		'favorited' => {
			image: 'heart',
			filterBy: cap -> {
				return cap.getEither((level, song) -> {
					if (level != null) return [for (song in level.children) song.data.isFavorited].contains(true);
					if (song != null) return song.data.isFavorited;
					return false;
				});
			}
		},
		'all' => { image: 'all' }
	];

	public static var difficultyColors:Map<String, ParseColor> = [
		"easy" => "#00FF00",
		"normal" => "#FFFF00",
		"hard" => "#FF0000",
		"erect" => "#FD579D",
		"nightmare" => "#4E28FB"
	];

	public var albumMap:Map<String, Album> = [];
	public var albumGroup:FlxTypedGroup<Album>;

	public var background:NovaSprite;
	public var bottomBar:NovaSprite;
	public var topBar:NovaSprite;

	public var scoreText:NovaText;
	public var ostText:NovaText;

	public var capsules:FlxTypedGroup<CapsuleInst>;
	// will be used to store capsules that are and aren't in view
	public var _capsules:Array<CapsuleInst> = [];

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

		add(albumGroup = new FlxTypedGroup<Album>());

		for (id in ['none', 'placeholder']) albumMap.set(id, albumGroup.add(new Album(id)));

		final playableChars:Array<String> = [];
		capsules = new FlxTypedGroup<CapsuleInst>();
		for (i => data in LevelRegistry.getAllLevels()) {
			if (data.isDev() ? !Options.data.developerMode : false) continue;

			var levelCap = new LevelCapsule(data);
			capsules.add(levelCap);

			for (i => data in [
				for (data in Song.sortByVariant([
					for (name in data.getSongs())
						for (data in SongRegistry.getSongVariantsByID(name)) {
							final conditions:Array<Bool> = [
								data.isDev() ? Options.data.developerMode : true
							];
							var conditionsMet:Bool = true;
							for (i in conditions)
								if (!i) conditionsMet = false;
							if (conditionsMet)
								data;
						}
				])) data
			]) {
				if (!albumMap.exists(data._data.album) && data._data.album != null) {
					var album = new Album(data._data.album);
					albumMap.set(data._data.album, albumGroup.add(album));

					FlxTween.tween(album, { x: 0 }, 0.5, { ease: FlxEase.expoOut, startDelay: 0.5 });
				}

				var cap = new SongCapsule(levelCap, data);
				cap.init();
				cap.x = FlxG.width;
				cap.y = 100 * i + (FlxG.height/2) - (85/2);
				_capsules.push(capsules.add(cap));
				levelCap.children.push(cap);

				if (!playableChars.contains(data.playableCharacter))
					playableChars.push(data.playableCharacter);
			}

			// init after everything
			levelCap.init();
			levelCap.x = FlxG.width;
			levelCap.y = 100 * i + (FlxG.height/2) - (85/2);
			_capsules.push(levelCap);
		}
		add(capsules);

		playableChars.sort(NovaUtils.sortAlphabetically);
		for (char in playableChars) {
			categoryData.set('char:$char', {
				{
					image: char,
					filterBy: cap -> return cap.getEither((level, song) -> {
						if (level != null) return [for (song in level.children) song.data.playableCharacter == char].contains(true);
						if (song != null) return song.data.playableCharacter == char;
						return false;
					})
				}
			});
		}
		runEvent('categorySetup', new violet.backend.scripting.events.CategorySetupEvent(categoryData));

		bottomBar = new NovaSprite(0, FlxG.height, Paths.image('menus/freeplaymenu/bottomBar'));
		bottomBar.setGraphicSize(FlxG.width);
		bottomBar.updateHitbox();
		add(bottomBar);

		topBar = new NovaSprite(0, 0, Paths.image('menus/freeplaymenu/topBar'));
		topBar.scale.set(bottomBar.scale.x, bottomBar.scale.y);
		topBar.updateHitbox();
		topBar.y = -topBar.height;
		add(topBar);

		caregoryGroup = new FlxTypedGroup<NovaSprite>();
		for (id => data in categoryData) {
			var icon:NovaSprite = cast (id.startsWith('char:') ? new violet.data.icon.HealthIcon(data.image, false) : new NovaSprite().loadGraphic(data.getImage()));
			icon.y = topBar.y + 100;
			caregoryGroup.add(icon);
		}
		add(caregoryGroup);

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

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (Controls.back && !transitioning) close();

		scoreLerp = lerp(
			scoreLerp,
			capsules.members[selectedSongIndex].getEither((level, song) -> {
				var score:Int = 0;
				if (level != null) score = ScoreUtil.getLevelScore(level.data.id, difficultyText.text.toLowerCase());
				if (song != null) score = ScoreUtil.getSongScore(song.data.id, difficultyText.text.toLowerCase(), song.data.variant);
				return cast score; // fuck haxe abstracts man 💀
			}),
			0.3
		);
		scoreText.text = "SCORE: " + ScoreUtil.stringifyScore(scoreLerp, 8);

		scoreText.y = topBar.y + 15;
		difficultyText.y = bottomBar.y + 50;

		if (Controls.uiUp) selectedSongIndex -= 1;
		if (Controls.uiDown) selectedSongIndex += 1;

		if (FlxG.keys.justPressed.HOME) selectedSongIndex = 0;
		if (FlxG.keys.justPressed.END) selectedSongIndex = capsules.length-1;

		if (FlxG.keys.justPressed.PAGEUP) selectedSongIndex -= 5;
		if (FlxG.keys.justPressed.PAGEDOWN) selectedSongIndex += 5;

		if (Controls.uiLeft) changeDiff(-1);
		if (Controls.uiRight) changeDiff(1);

		if (Controls.uiLeftTab) selectedCategoryIndex -= 1;
		if (Controls.uiRightTab) selectedCategoryIndex += 1;

		if (Controls.accept) selectSong();

		for (index => cap in capsules) {
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
		for (index => icon in caregoryGroup) {
			var newX:Float = 300 * (selectedCategoryIndex + 1) + (FlxG.width / 2);
			icon.x = lerp(icon.x, newX, snap ? 1 : 0.2);
		}

		final targetID:String = capsules.members[selectedSongIndex].getEither((_, song) -> {
			if (song != null)
				return song.data._data.album ?? 'placeholder';
			return 'none'; // for it too assign for levels
		});
		for (album in albumMap) {
			if (album.visible = album.id == targetID) {
				ostText.text = album.ostText;
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
		selectedSongIndex = FlxMath.wrap(value, 0, instance.capsules.length - 1);
		instance.changeDiff(0);

		var selectASong = new FlxText(0, 0, 0, instance.capsules.members[selectedSongIndex].getEither((level, song) -> {
			if (level != null) return level.data.getTitle().toUpperCase();
			if (song != null) return song.data.displayName.toUpperCase();
			return '----';
		}) + " · ");
		selectASong.setFormat(Paths.font("Nunito-Medium"), 65, FlxColor.WHITE, "center");
		selectASong.scale.x = selectASong.scale.y = 0.5;
		selectASong.updateHitbox();
		selectASong.drawFrame();

		if (instance.selectASongText != null) instance.remove(instance.selectASongText);
		instance.selectASongText = new FlxBackdrop(selectASong.pixels, X);
		instance.selectASongText.y = -4;
		instance.selectASongText.scale.x = instance.selectASongText.scale.y = instance.topBar.scale.x;
		instance.selectASongText.updateHitbox();
		instance.selectASongText.alpha = 0.5;
		instance.selectASongText.velocity.set(100, 0);
		instance.insert(instance.members.indexOf(instance.topBar) - 1, instance.selectASongText);
		selectASong.destroy();

		if (instance.timer != null) instance.timer.cancel();
		instance.timer = FlxTimer.wait(0.5, instance.onTimerEnd);
		return value;
	}
	static function set_selectedCategoryIndex(value:Int) {
		if (instance.transitioning) return selectedCategoryIndex;
		selectedCategoryIndex = FlxMath.wrap(value, 0, instance.caregoryGroup.length - 1);

		/* if (instance.timer != null) instance.timer.cancel();
		instance.timer = FlxTimer.wait(0.5, instance.onTimerEnd); */
		return value; // TODO: code capsule list updating
	}

	function changeDiff(amount:Int) {
		if (transitioning) return;
		var song:Null<Song> = capsules.members[selectedSongIndex].getSong(cap -> return cap.data);
		if (song == null) {
			difficultyText.text = '...';
			difficultyText.updateHitbox();
			difficultyText.x = 215 - (difficultyText.width/2);
			difficultyText.color = FlxColor.WHITE;
			return;
		}
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
		var songData:Null<Song> = capsules.members[selectedSongIndex].getSong(cap -> return cap.data);
		if (songData == null) return;
		if (current == Song.setupId(songData.id, null, songData.variant)) return;
		else current = Song.setupId(songData.id, null, songData.variant);
		Conductor.playSong(songData.id, songData.variant);
	}

	function selectSong() {
		// only if its a song, please and thank you
		var songData:Null<Song> = capsules.members[selectedSongIndex].getSong(cap -> return cap.data);
		if (songData == null) return;

		if (transitioning) return;
		transitioning = true;
		updateCapsulePosition = false;

		NovaUtils.playMenuSFX(CONFIRM);

		for (index=>text in capsules) {
			if (index != selectedSongIndex) {
				FlxTween.tween(text, {alpha: 0, x: text.x + 500}, 0.3, { ease: FlxEase.backIn});
			} else {
				var selectedSongMeta:Song = capsules.members[selectedSongIndex].getSong(cap -> return cap.data);
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

}