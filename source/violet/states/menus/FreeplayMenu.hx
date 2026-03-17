package violet.states.menus;

import violet.data.chart.ChartRegistry;
import violet.data.freeplay.Player;
import violet.ui.freeplay.Album;
import violet.backend.audio.Conductor;
import violet.backend.options.Options;
import flixel.FlxCamera;
import flixel.math.FlxMath;
import violet.backend.SubStateBackend;
import violet.backend.objects.special_thanks.GenzuSprite;
import violet.backend.shaders.AngleMask;
import violet.backend.shaders.GaussianBlurShader;
import violet.backend.utils.NovaUtils;
import violet.data.song.Song;
import violet.data.song.SongRegistry;
import violet.states.PlayState;
import violet.ui.freeplay.Capsule;

class FreeplayMenu extends SubStateBackend {
	static var prevInst:String = "";
	public static var skipTransition:Bool = false;

	static var curSelectedSong:Int = 0;
	static var curSelectedDiff:Int = 0;
	static var curSelectedVar:Int = 0;
	static var lastSong:Int = -1;

	var canSelect:Bool = true;
	var daCapsules:Array<Capsule> = [];
	var camHUD:FlxCamera;
	var capsule:GenzuSprite;
	var backingCard:GenzuSprite;
	var backingImage:GenzuSprite;
	var angleMaskShader:AngleMask = new AngleMask();
	var screenshot:GenzuSprite;
	var blur = new GaussianBlurShader(1);
	var glowColor = 0xFF00ccff;
	var xPos = 315; // For Capsule
	var black:NovaSprite;
	var diffSprite:GenzuSprite;
	var freeplayText:NovaText;
	var ostText:NovaText;
	var spacing:Float = 145;
	var instTimer = new FlxTimer();
	var dj:GenzuSprite;
	var selector1:GenzuSprite;
	var selector2:GenzuSprite;

	var songs:Array<Song> = [];
	var album:Album;
	var player:Player;

	override function create() {
		super.create();

		prevInst = "";

		camHUD = new FlxCamera();
		camHUD.bgColor = FlxColor.TRANSPARENT;
		camHUD.zoom = 0.8;
		FlxG.cameras.add(camHUD, false);

		backingImage = new GenzuSprite(0, 0, Paths.image("menus/freeplay/freeplayBGweek1-bf"));
		backingImage.cameras = [camHUD];
		backingImage.setGraphicSize(FlxG.width / 0.8);
		backingImage.updateHitbox();
		backingImage.screenCenter(Y);
		backingImage.x = -backingImage.width - 150;
		backingImage.shader = angleMaskShader;

		backingCard = new GenzuSprite(0, 0, Paths.image("menus/freeplay/backingCard/pinkBack"));
		backingCard.cameras = [camHUD];
		backingCard.setGraphicSize(FlxG.width / 0.8, FlxG.height / 0.8);
		backingCard.scale.x = backingCard.scale.y;
		backingCard.scale.x = backingCard.scale.y *= 1.1;
		backingCard.x = -backingCard.width;
		backingCard.updateHitbox();
		backingCard.screenCenter(Y);
		backingCard.color = 0xFFFFD863;

		black = new NovaSprite().makeGraphic(FlxG.width * 1.5, 165, FlxColor.BLACK);
		black.camera = camHUD;
		black.screenCenter(X);
		black.updateHitbox();
		black.y -= 300;

		add(backingImage);
		add(backingCard);

		diffSprite = new GenzuSprite(0, 0, Paths.image("menus/freeplay/difficulties/easy"));
		diffSprite.scale.set(1.3, 1.3);
		diffSprite.camera = camHUD;
		diffSprite.updateHitbox();

		selector1 = new GenzuSprite(-250, 10, Paths.image("menus/freeplay/difficulties/selector"));
		selector1.scale.set(1.28, 1.28);
		selector1.addAnim("pressed", "arrow pointer loop", [], null, 24, true);
		selector1.playAnim("pressed");
		selector1.camera = camHUD;

		selector2 = new GenzuSprite(-250, selector1.y, Paths.image("menus/freeplay/difficulties/selector"));
		selector2.scale.set(1.28, 1.28);
		selector2.addAnim("pressed", "arrow pointer loop", [], null, 24, true);
		selector2.playAnim("pressed");
		selector2.camera = camHUD;
		selector2.flipX = true;

		freeplayText = new NovaText(-145, -150, null, "FREEPLAY", 60);
		freeplayText.setFont(Paths.font("vcr.ttf"));
		freeplayText.updateHitbox();
		freeplayText.camera = camHUD;

		ostText = new NovaText(0, -150, FlxG.width, "OFFICIAL OST", 60);
		ostText.setFont(Paths.font("vcr.ttf"));
		ostText.alignment = RIGHT;
		ostText.updateHitbox();
		ostText.x = FlxG.width - ostText.width + 150;
		ostText.camera = camHUD;

		album = new Album('placeholder');
		album.x = FlxG.width;
		album.camera = camHUD;

		diffSprite.y = selector2.y;

		// Rodney don't flame gen for this I did it.
		FlxTween.tween(backingCard, 	{ x: -160 }, 				1.0, 	{ ease: FlxEase.expoOut, startDelay: 0.0 });
		FlxTween.tween(backingImage, 	{ x: 315 }, 				1.0, 	{ ease: FlxEase.expoOut, startDelay: 0.1 });
		FlxTween.tween(black, 			{ y: -175 }, 				0.6, 	{ ease: FlxEase.expoOut, startDelay: 0.2 });
		FlxTween.tween(selector2, 		{ x: 260 }, 				0.6, 	{ ease: FlxEase.expoOut, startDelay: 0.3 });
		FlxTween.tween(selector1, 		{ x: -130 }, 				0.6, 	{ ease: FlxEase.expoOut, startDelay: 0.4 });
		FlxTween.tween(diffSprite, { x: ((-130 + 260) / 2) - (diffSprite.width / 2) + 27}, 0.7, { ease: FlxEase.expoOut, startDelay: 0.5 }); // idk mane
		FlxTween.tween(freeplayText, 	{ y: -78 }, 				0.8, 	{ ease: FlxEase.expoOut, startDelay: 0.6 });
		FlxTween.tween(ostText, 		{ y: -78 }, 				0.8, 	{ ease: FlxEase.expoOut, startDelay: 0.7 });
		FlxTween.tween(album, 		    { x: 0 },            		0.8, 	{ ease: FlxEase.expoOut, startDelay: 0.7 });

		player = new Player('bf');

		songs = SongRegistry.getAllSongs().filter(song -> {
			if (Options.data.developerMode) {
				return true;
			} else {
				return !song._data?.isDev ?? true;
			}
		});
		for (i => song in songs) {
			var yOffset = 10;
			var startY = (FlxG.height / 2) + spacing * (i - curSelectedSong) - spacing + yOffset;
			var capsule = new Capsule(song);
			capsule.setPosition(-1000, startY);
			capsule.cameras = [camHUD];
			add(capsule);
			daCapsules.push(capsule);
			capsule.updateBPM(Std.int(song._data.bpm));
			trace(ChartRegistry.fetchChart(song.songName));
		}

		add(black);
		add(diffSprite);
		add(selector1);
		add(selector2);
		add(freeplayText);
		add(ostText);
		add(album);

		changeSelection(0);
		diffSprite.x = -FlxG.width;

		if (skipTransition) {
			FlxTween.globalManager.completeAll();
			camHUD.fade(0.5, true);
		}

		skipTransition = false;
	}

	public function build() {
		var mainMenu:MainMenu = new MainMenu();
		FreeplayMenu.skipTransition = true;
		mainMenu.openSubState(this);
		return mainMenu;
	}

	override function update(elapsed) {
		super.update(elapsed);

		if (Controls.back && canSelect)
			exit();

		if (Controls.uiUp && canSelect) {
			NovaUtils.playMenuSFX(SCROLL);
			changeSelection(-1);
		}

		if (Controls.uiDown && canSelect) {
			NovaUtils.playMenuSFX(SCROLL);
			changeSelection(1);
		}

		if (Controls.uiLeft && canSelect) {
			changeDiff(-1);
			NovaUtils.playMenuSFX(SCROLL);

			selector1.x -= 10;
			FlxTween.cancelTweensOf(selector1);
			FlxTween.tween(selector1, {x: -130}, 0.5, {ease: FlxEase.expoOut});
		}

		if (Controls.uiRight && canSelect) {
			changeDiff(1);
			NovaUtils.playMenuSFX(SCROLL);

			selector2.x += 10;
			FlxTween.cancelTweensOf(selector2);
			FlxTween.tween(selector2, {x: 260}, 0.5, {ease: FlxEase.expoOut});
		}

		if (Controls.accept && canSelect) {
			playSong(songs[curSelectedSong].id, songs[curSelectedSong].difficulties[curSelectedDiff]);
		}
	}

	function changeSelection(amount:Int) {
		var yOffset = 10;
		var prevSong:Song = songs[curSelectedSong];
		curSelectedSong = FlxMath.wrap(curSelectedSong + amount, 0, songs.length - 1);
		for (i => capsule in daCapsules) {
			capsule.setSelected(curSelectedSong == i);
			FlxTween.cancelTweensOf(capsule);

			var distance = Math.abs(i - curSelectedSong);
			var delay = amount == 0 ? 0.4 + (distance * 0.09) : 0.0;

			if (curSelectedSong < i) {
				var xOffset = i == curSelectedSong + 1 ? 0 : (i - curSelectedSong) * 50;
				FlxTween.tween(capsule, {x: xPos - xOffset, y: (FlxG.height / 2) + spacing * (i - curSelectedSong) - spacing + yOffset}, 0.5,
					{ease: FlxEase.expoOut, startDelay: delay});
			} else if (curSelectedSong == i) {
				FlxTween.tween(capsule, {x: xPos, y: (FlxG.height / 2) - spacing + yOffset}, 0.5, {ease: FlxEase.expoOut, startDelay: delay});
			} else if (curSelectedSong > i) {
				if (i == curSelectedSong - 2) {
					FlxTween.tween(capsule, {x: xPos + ((i - curSelectedSong) * 50), y: -300 + yOffset}, 0.5, {ease: FlxEase.expoOut, startDelay: delay});
				} else {
					FlxTween.tween(capsule,
						{x: xPos + ((i - curSelectedSong) * 50), y: (FlxG.height / 2) + spacing * (i - curSelectedSong) - spacing + yOffset}, 0.5,
						{ease: FlxEase.expoOut, startDelay: delay});
				}
			}
		}

		var song:Song = songs[curSelectedSong];
		var prevDiffList = prevSong.difficulties;
		var curDiffList = song.difficulties;
		var newIndex:Int = Math.floor(song.difficulties.length / 2);
		if (prevDiffList[curSelectedDiff] == prevDiffList[curSelectedDiff])
			for (i => diff in curDiffList)
				if (diff == prevDiffList[curSelectedDiff]) {
					newIndex = i;
					break;
				}
		changeDiff(newIndex, true);
		playInst();
		updateAlbum();
	}

	function playInst() {
		var inst = '${songs[curSelectedSong].songName}/song/Inst${songs[curSelectedSong].variant != '' ? '-${songs[curSelectedSong].variant}' : ''}';
		instTimer.cancel();

		if (inst == prevInst)
			return;

		instTimer = new FlxTimer().start(0.8, (_) -> {
			prevInst = inst;
			Conductor.playSong(songs[curSelectedSong].songName, songs[curSelectedSong].variant);
			Conductor.instrumental.volume = 0.8;
			Conductor.instrumental.looped = true;
		});
	}

	function changeDiff(amount:Int, pureSelect:Bool = false) {
		var song:Song = songs[curSelectedSong];
		curSelectedDiff = FlxMath.wrap(pureSelect ? amount : curSelectedDiff + amount, 0, song.difficulties.length - 1);
		if (curSelectedDiff >= song.difficulties.length)
			curSelectedDiff = 0;

		var direction = amount > 0 ? 1 : -1;
		var distance = 80;

		if (pureSelect) {
			diffSprite.loadSprite(Paths.image('menus/freeplay/difficulties/${song.difficulties[curSelectedDiff]}'));
			if (diffSprite.animated) {
				diffSprite.addAnim('idle', 'idle', 24, true);
				diffSprite.playAnim('idle', true);
			}
			for (i => capsule in daCapsules)
				capsule.updateRatingForDiff(songs[i], songs[i].difficulties[FlxMath.wrap(curSelectedDiff, 0, songs[i].difficulties.length - 1)]);
			return;
		}

		FlxTween.cancelTweensOf(diffSprite);
		FlxTween.tween(diffSprite, {x: diffSprite.x - (distance * amount), alpha: 0}, 0.15, {
			ease: FlxEase.expoIn,
			onComplete: (_) -> {
				diffSprite.loadSprite(Paths.image('menus/freeplay/difficulties/${song.difficulties[curSelectedDiff]}'));
				if (diffSprite.animated) {
					diffSprite.addAnim('idle', 'idle', 24, true);
					diffSprite.playAnim('idle', true);
				}
				diffSprite.updateHitbox();
				diffSprite.x = distance * direction * 2;
				for (i => capsule in daCapsules)
					capsule.updateRatingForDiff(songs[i], songs[i].difficulties[FlxMath.wrap(curSelectedDiff, 0, songs[i].difficulties.length - 1)]);
				FlxTween.tween(diffSprite, {x: ((selector1.x + selector2.x) / 2) - (diffSprite.width / 2) + 27, alpha: 1}, 0.1, {ease: FlxEase.expoOut});
			}
		});

		updateAlbum();
	}

	function updateAlbum() {
		album.setAlbum(songs[curSelectedSong]?._data?.album ?? 'placeholder');
		ostText.text = album?.ostText;
		ostText.updateHitbox();
	}

	function playSong(?id:String, ?difficulty:String, ?variation:String) {
		canSelect = false;

		daCapsules[curSelectedSong].playConfirm();

		NovaUtils.playMenuSFX(CONFIRM);
		FlxTimer.wait(1, () -> {
			FlxG.sound.music.fadeOut(0.5);
			camHUD.fade(FlxColor.BLACK, 0.5, false, () -> {
				FlxTimer.wait(0.5, () -> {
					PlayState.doFadeOut = true;
					PlayState.loadSong(id, difficulty);
				});
			});
		});
	}

	function exit() {
		NovaUtils.playMenuSFX(CANCEL);

		if (!canSelect)
			return;
		canSelect = false;

		FlxTween.cancelTweensOf(ostText);
		FlxTween.cancelTweensOf(freeplayText);
		FlxTween.cancelTweensOf(diffSprite);
		FlxTween.cancelTweensOf(selector1);
		FlxTween.cancelTweensOf(selector2);
		FlxTween.cancelTweensOf(black);
		FlxTween.cancelTweensOf(backingImage);
		FlxTween.cancelTweensOf(backingCard);
		FlxTween.cancelTweensOf(album);

		FlxTween.tween(ostText, {y: -150}, 0.3, {ease: FlxEase.expoIn});
		FlxTween.tween(freeplayText, {y: -150}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.1});
		FlxTween.tween(diffSprite, {x: -FlxG.width}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.2});
		FlxTween.tween(selector1, {x: -250}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.3});
		FlxTween.tween(selector2, {x: -250}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.3});
		FlxTween.tween(black, {y: -300}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.4});
		FlxTween.tween(backingImage, {x: -backingImage.width - 160}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.5});
		FlxTween.tween(backingCard, {x: -backingCard.width - 160}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.6});
		FlxTween.tween(album, {x: FlxG.width}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.5});

		FlxTween.tween(cast(_parentState, MainMenu).bg, {x: 0}, 0.3 * 2, {ease: FlxEase.quadInOut, startDelay: 0.7});

		var origin = curSelectedSong - 1;

		for (i => capsuleGroup in daCapsules) {
			FlxTween.cancelTweensOf(capsuleGroup);
			var distance = Math.abs(i - origin);
			FlxTween.tween(capsuleGroup, {x: -1000}, 0.4, {
				ease: FlxEase.expoIn,
				startDelay: 0.2 + (distance * 0.05)
			});
		}
		new FlxTimer().start(1.2, (_) -> {
			close();
		});
	}
}
