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
import violet.data.icon.HealthIcon;
import violet.data.level.LevelRegistry;
import violet.data.song.Song;
import violet.data.song.SongRegistry;

// the abstracts used here are mainly to help interally, since with scripts you don't need to deal with haxe calling you out on type defines

@:forward
abstract CapsuleInst(Capsule) from Capsule to Capsule from SongCapsule from LevelCapsule {
	public var hidden(get, never):Bool;
	inline function get_hidden():Bool {
		return getEither((level, song) -> {
			if (level != null) return level.hidden;
			if (song != null) return song.hidden || song.parent.collasped;
			return true;
		});
	}

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
	var id:String;
	var ?image:String;
	var ?filterBy:SongCapsule -> Bool;
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

	public function filterList(list:Array<CapsuleInst>):Void {
		for (cap in list) cap.getSong(song -> {
			if (this.filterBy == null) song.hidden = false;
			else song.hidden = !this.filterBy(song);

			if (!song.parent.collasped && !song.hidden && !song.initalized) {
				final prevX = song.x; final prevY = song.y;
				song.setPosition();
				song.init();
				song.setPosition(prevX, prevY);
			}
			if (!song.parent.hidden && !song.parent.initalized) {
				final prevX = song.parent.x; final prevY = song.parent.y;
				song.parent.setPosition();
				song.parent.init();
				song.parent.setPosition(prevX, prevY);
			}
		});
	}
	public function sortList(list:Array<CapsuleInst>):Void {
		// default sort order
		list.sort((a, b) -> {
			var _a = a.getEither((level, song) -> {
				if (level != null) return level.defaultIndex;
				if (song != null) return song.defaultIndex;
				return 0;
			});
			var _b = b.getEither((level, song) -> {
				if (level != null) return level.defaultIndex;
				if (song != null) return song.defaultIndex;
				return 0;
			});

			return _a == _b ? 0 : (_a > _b ? 1 : -1);
		});

		// custom sort order
		if (this.sortBy != null)
			list.sort(this.sortBy);

		// favorited sort order
		list.sort((a, b) -> {
			var _a = a.getEither((level, song) -> {
				if (level != null) {
					for (song in level.children)
						if (song.hidden || song.parent.collasped)
							continue;
						else if (song.data.isFavorited)
							return true;
					return false;
				}
				if (song != null) return song.data.isFavorited;
				return false;
			});
			var _b = b.getEither((level, song) -> {
				if (level != null) {
					for (song in level.children)
						if (song.hidden || song.parent.collasped)
							continue;
						else if (song.data.isFavorited)
							return true;
					return false;
				}
				if (song != null) return song.data.isFavorited;
				return false;
			});

			if (_a && !_b)
				return -1;
			if (!_a && _b)
				return 1;
			return 0;
		});
	}
}

@:forward
abstract CategoryIcon(NovaSprite) from NovaSprite to NovaSprite from HealthIcon {
	public var categoryData(get, set):CategoryData;
	inline function get_categoryData():CategoryData
		return this.extra.get('categoryData');
	inline function set_categoryData(value:CategoryData):CategoryData {
		this.extra.set('categoryData', value);
		return value;
	}

	inline public function new(data:CategoryData) {
		if (data.id.startsWith('char:'))
			this = new HealthIcon(data.image, false);
		else this = new NovaSprite().loadGraphic(data.getImage());
		categoryData = data;
	}

	inline public function getSprite<T>(func:NovaSprite->T):Null<T> {
		return getEither(
			(cap, _) -> {
				if (cap != null)
					return func(cap);
				return null;
			}
		);
	}
	inline public function getIcon<T>(func:HealthIcon->T):Null<T> {
		return getEither(
			(_, cap) -> {
				if (cap != null)
					return func(cap);
				return null;
			}
		);
	}

	inline public function getEither<T>(func:(NovaSprite, HealthIcon) -> T):Null<T> {
		if (this is HealthIcon)
			return func(null, cast this);
		if (this is NovaSprite)
			return func(cast this, null);
		return null;
	}
}

class FreeplayMenu extends SubStateBackend {

	public static var skipTransition:Bool = false;
	public static var selectedSongIndex(default, set):Int = 0;
	public static var selectedCategoryIndex(default, set):Int = 1;

	public static var categoryPosition(default, never):FlxPoint = FlxPoint.get(870, 80);
	public static var categoryRadius(default, never):FlxPoint = FlxPoint.get(-200, 0);

	public var categoryOrder:Array<CategoryIcon>;
	public var categoryGroup:FlxTypedGroup<CategoryIcon>;
	public var categoryData:Array<CategoryData> = [
		{
			id: 'favorited',
			image: 'heart',
			filterBy: cap -> return cap.data.isFavorited
		},
		{
			id: 'all',
			image: 'all'
		}
	];

	public static var difficultyColors:Map<String, ParseColor> = [
		"easy" => "#00FF00",
		"normal" => "#FFFF00",
		"hard" => "#FF0000",
		"erect" => "#FD579D",
		"nightmare" => "#4E28FB"
	];

	public var albumMap:Map<String, Album> = new Map<String, Album>();
	public var albumGroup:FlxTypedGroup<Album>;

	public var background:NovaSprite;
	public var bottomBar:NovaSprite;
	public var topBar:NovaSprite;

	public var scoreText:NovaText;
	public var ostText:NovaText;

	public var capsules:FlxTypedGroup<CapsuleInst>;
	// will be used to store capsules that aren't in view
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

		for (id in ['none', 'placeholder']) {
			var album = albumGroup.add(new Album(id));
			albumMap.set(id, album);
		}

		final playableChars:Array<String> = [];
		capsules = new FlxTypedGroup<CapsuleInst>();
		var _i:Int = -1;
		for (data in LevelRegistry.getAllLevels()) {
			if (data.isDev() ? !Options.data.developerMode : false) continue;

			var levelCap = new LevelCapsule(data);
			levelCap.defaultIndex = _i++;
			_capsules.push(levelCap);

			for (data in [
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
				}

				var cap = new SongCapsule(levelCap, data);
				cap.defaultIndex = _i++;
				_capsules.push(cap);
				levelCap.children.push(cap);

				if (!playableChars.contains(data.playableCharacter))
					playableChars.push(data.playableCharacter);
			}
		}
		add(capsules);

		playableChars.sort(NovaUtils.sortAlphabetically);
		for (char in playableChars) {
			categoryData.push({
				{
					id: 'char:$char',
					image: char,
					filterBy: cap -> return cap.data.playableCharacter == char
				}
			});
		}
		runEvent('categorySetup', new violet.backend.scripting.events.CategorySetupEvent(categoryData));

		bottomBar = new NovaSprite(0, FlxG.height, Paths.image('menus/freeplaymenu/bottomBar'));
		bottomBar.setGraphicSize(FlxG.width);
		bottomBar.updateHitbox();
		add(bottomBar);

		categoryGroup = new FlxTypedGroup<CategoryIcon>();
		for (data in categoryData)
			categoryGroup.add(new CategoryIcon(data));
		categoryOrder = categoryGroup.members.copy();
		add(categoryGroup);

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

		selectedCategoryIndex = selectedCategoryIndex;

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

	@:unreflective final _cur_cat_pos:FlxPoint = FlxPoint.get();
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

		if (Controls.favorite) {
			capsules.members[selectedSongIndex].toggleFavorite();
			selectedCategoryIndex = selectedCategoryIndex;
		}

		for (index => cap in capsules) {
			if (cap == null || !cap.initalized) continue;

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
		for (index => icon in categoryOrder) {
			var offset = index - selectedCategoryIndex;
			while (offset < 0) offset += categoryOrder.length;
			var angle = (offset / categoryOrder.length) * Math.PI * 2;
			angle += Math.PI / 2;

			var position = _cur_cat_pos.set(
				categoryPosition.x + FlxMath.fastCos(angle) * categoryRadius.x,
				categoryPosition.y + FlxMath.fastSin(angle) * categoryRadius.y
			);
			icon.setPosition(
				lerp(icon.x, position.x - (icon.width / 2), snap ? 1 : 0.2),
				lerp(icon.y, position.y - (icon.height / 2), snap ? 1 : 0.2)
			);

			var depth = (FlxMath.fastSin(angle) + 1) / 2;

			var scale = 0.6 + (depth * 0.4);
			icon.getEither((sprite, icon) -> {
				if (sprite != null) {
					sprite.setGraphicScale(90, 90);
					sprite.scale.scale(scale);
				}
				if (icon != null) {
					icon.scale.set(scale, scale);
					icon.scale.scale(icon._data.scale);
				}
				return null;
			});
			icon.scale.scale(0.7);
			icon.updateHitbox();
			icon.alpha = lerp(icon.alpha, Math.min(1, depth * 1000), snap ? 1 : 0.2);

			icon.zIndex = Std.int(depth * 1000);
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
		if (instance.capsules.length < 1) {
			NovaUtils.addNotification('No Capsules', 'There are no capsules in the list!', WARNING);
			return selectedSongIndex;
		}
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
		if (instance.categoryGroup.length < 1) return selectedCategoryIndex;
		selectedCategoryIndex = FlxMath.wrap(value, 0, instance.categoryGroup.length - 1);

		final cap = instance._capsules[selectedSongIndex];
		final data = instance.categoryData[selectedCategoryIndex];
		data.filterList(instance._capsules);
		data.sortList(instance._capsules);

		instance.capsules.clear();
		for (cap in instance._capsules)
			if (!cap.hidden)
				instance.capsules.add(cap);

		var newIndex = instance.capsules.members.indexOf(cap);
		cap.getSong(cap -> {
			if (cap != null && newIndex == -1)
				newIndex = instance.capsules.members.indexOf(cap.parent);
			return null;
		});
		selectedSongIndex = newIndex == -1 ? 0 : newIndex;

		return value;
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
		var songData:Null<Song> = capsules.members[selectedSongIndex].getEither((level, song) -> {
			if (level != null) {
				level.collasped = !level.collasped;
				for (cap in capsules) if (cap != level) cap.getLevel(cap -> cap.collasped = true);
				selectedCategoryIndex = selectedCategoryIndex;
			}
			if (song != null) return song.data;
			return null;
		});
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