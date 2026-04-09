package violet.states.menus;

import violet.ui.freeplay.DifficultyDot;
import violet.backend.utils.ScoreUtil;
import violet.ui.freeplay.ScoreText;
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
import violet.backend.utils.MathUtil;

class FreeplayMenu extends SubStateBackend {
	static var prevInst:String = "";
	public static var skipTransition:Bool = false;

	static var curSelectedSong:Int = 0;
	static var curSelectedDiff:Int = 0;
	static var curSelectedVar:Int = 0;
	static var lastSong:Int = -1;

	static var playableID:String = 'bf';

	public var enableMobileControls:Bool = #if mobile true #else false #end;

	var difficultyDots:Map<String, DifficultyDot> = new Map();

	var difficulties:Array<String> = ["easy", "normal", "hard"];
	var difficultyAssociations = [
		"easy" => "",
		"normal" => "",
		"hard" => "",
		"erect" => "erect",
		"nightmare" => "erect"
	];
	var variant(get, never):String;
	function get_variant() {
		return difficultyAssociations.get(difficulties[curSelectedDiff]) ?? '';
	}

	var highscoreTimer:FlxTimer;

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
	var scoreText:FreeplayScore;
	var lerpScore:Float = 0;
	var intendedScore:Int = 0;
	var highscoreImg:GenzuSprite;

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

		highscoreImg = new GenzuSprite(0, 5, Paths.image('menus/freeplay/score/highscore'));
		highscoreImg.addAnim('idle', 'highscore small instance 1', [], null, 24, false);
		highscoreImg.playAnim('idle');
		highscoreImg.scale.set(1.25, 1.25);
		highscoreImg.x = FlxG.width + 190;
		highscoreImg.camera = camHUD;

		album = new Album('placeholder');
		album.x = FlxG.width;
		album.camera = camHUD;

		diffSprite.y = selector2.y;

		scoreText = new FreeplayScore(0, 30);
		scoreText.camera = camHUD;
		scoreText.x = FlxG.width + 150;
		// scoreText.x = FlxG.width - scoreText.width + 125;

		FlxTween.tween(backingCard, {x: -160}, 1.0, {ease: FlxEase.expoOut, startDelay: 0.0});
		FlxTween.tween(backingImage, {x: 315}, 1.0, {ease: FlxEase.expoOut, startDelay: 0.1});
		FlxTween.tween(black, {y: -175}, 0.6, {ease: FlxEase.expoOut, startDelay: 0.2});
		FlxTween.tween(selector2, {x: 260}, 0.6, {ease: FlxEase.expoOut, startDelay: 0.3});
		FlxTween.tween(selector1, {x: -130}, 0.6, {ease: FlxEase.expoOut, startDelay: 0.4});
		FlxTween.tween(diffSprite, {x: ((-130 + 260) / 2) - (diffSprite.width / 2) + 27}, 0.7, {ease: FlxEase.expoOut, startDelay: 0.5}); // idk mane
		FlxTween.tween(freeplayText, {y: -78}, 0.8, {ease: FlxEase.expoOut, startDelay: 0.6});
		FlxTween.tween(ostText, {y: -78}, 0.8, {ease: FlxEase.expoOut, startDelay: 0.7});
		FlxTween.tween(album, {x: 0}, 0.8, {ease: FlxEase.expoOut, startDelay: 0.7});
		FlxTween.tween(scoreText, {x: FlxG.width - scoreText.width + 125}, 0.8, {ease: FlxEase.expoOut, startDelay: 0.65});
		FlxTween.tween(highscoreImg, {x: FlxG.width - highscoreImg.width - 50}, 0.8, {ease: FlxEase.expoOut, startDelay: 0.65});

		player = new Player(playableID);

		conditionCheck();

		for (i => song in songs) {
			var yOffset = 10;
			var startY = (FlxG.height / 2) + spacing * (i - curSelectedSong) - spacing + yOffset;
			var capsule = new Capsule(song);
			capsule.setPosition(-1000, startY);
			capsule.cameras = [camHUD];
			add(capsule);
			daCapsules.push(capsule);
			capsule.updateBPM(Std.int(song._data.bpm));
		}

		add(black);
		add(diffSprite);
		add(selector1);
		add(selector2);
		add(freeplayText);
		add(ostText);
		add(album);
		add(scoreText);
		add(highscoreImg);

		var x = 2;
		var y = selector2.y + 113;
		var additive = 39;
		for (diff in ["easy", "normal", "hard", "erect", "nightmare"]) {
			var dot = new DifficultyDot(diff);
			dot.x = x;
			dot.y = y;
			dot.setSelected(false);
			dot.camera = camHUD;
			add(dot);
			difficultyDots.set(diff, dot);
			x += additive;
		}
		for (song in songs) {
			for (diff in song.difficulties) {
				if (!difficultyDots.exists(diff.toLowerCase())) {
					var dot = new DifficultyDot(diff.toLowerCase());
					dot.x = x;
					dot.y = y;
					dot.setSelected(false);
					dot.camera = camHUD;
					add(dot);
					difficultyDots.set(diff.toLowerCase(), dot);
					x += additive;
				}
			}
			for (varient in song.variants) {
				var target = SongRegistry.getSongByID('${song.id}:$varient');
				if (target == null) continue;
				for (diff in target.difficulties) {
					if (!difficultyDots.exists(diff.toLowerCase())) {
						var dot = new DifficultyDot(diff.toLowerCase());
						dot.x = x;
						dot.y = y;
						dot.setSelected(false);
						dot.camera = camHUD;
						add(dot);
						difficultyDots.set(diff.toLowerCase(), dot);
						x += additive;
					}
				}
			}
		}

		for (i in difficultyDots) {
			FlxTween.tween(i, {x: i.x }, 0.7, {ease: FlxEase.expoOut, startDelay: 0.56});
			i.x -= 400;
		}

		changeSelection(0);
		diffSprite.x = -FlxG.width;

		if (skipTransition) {
			FlxTween.globalManager.completeAll();
			camHUD.fade(0.5, true);
		}

		skipTransition = false;

		updateScore();

		highscoreTimer = new FlxTimer().start(FlxG.random.float(12, 50), function(tmr) {
			trace('Highscore Animation Timer Check');
			highscoreImg?.playAnim('idle');
			tmr.time = FlxG.random.float(20, 60);
		}, 0);

	}

	public function build() {
		var mainMenu:MainMenu = new MainMenu();
        mainMenu.canSelect = false;
		FreeplayMenu.skipTransition = true;
		mainMenu.openSubState(this);
		return mainMenu;
	}

	function updateScore() {
		var newSong:Song = songs[curSelectedSong];
		// scoreText.updateScore(ScoreUtil.getSongScore(newSong.songName, newSong.difficulties[curSelectedDiff], newSong.variant));
		intendedScore = ScoreUtil.getSongScore(newSong.songName, newSong.difficulties[curSelectedDiff], newSong.variant);
	}

	var scroll = 0;

	override function update(elapsed) {
		super.update(elapsed);

		if (lerpScore != intendedScore) {
			lerpScore = MathUtil.lerp(lerpScore, intendedScore, 0.3);
			if (Math.abs(lerpScore - intendedScore) < 1)
				lerpScore = intendedScore;
			scoreText.updateScore(Std.int(lerpScore));
		}

		if (FlxG.keys.justPressed.TAB) {
			FlxG.sound.music.fadeOut(0.5);
			camHUD.fade(FlxColor.BLACK, 0.5, ()->{
				/* playableID = playableID == "bf" ? "pico" : "bf";
				FreeplayMenu.skipTransition = true;
				FreeplayMenu.curSelectedSong = 0; */
				FlxG.switchState(CharacterSelectMenu.new/* new FreeplayMenu().build() */);
			});
		}

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
			playSong(songs[curSelectedSong].id, difficulties[curSelectedDiff]);
		}


		if (!enableMobileControls) return;

		var change = Math.abs(FlxG.mouse.deltaY) + Math.abs(FlxG.mouse.deltaX);
		if (Math.abs(FlxG.mouse.deltaY) > 15 && FlxG.mouse.pressed) {
			var positive = FlxG.mouse.deltaY >= 0;
			var target = (positive ? 1 : -1);
			if (target != 0 && scroll % 3 == 0) {
				NovaUtils.playMenuSFX(SCROLL);
				changeSelection(-target);
			}
			scroll++;
			return;
		} else {
			scroll = 0;
		}


		var offset = 150;

		selector1.x += offset;
		selector1.y += 37;
		if (FlxG.mouse.overlaps(selector1)) {
			if (FlxG.mouse.justPressed) {
				changeDiff(-1);
				selector1.x -= 10;
				FlxTween.cancelTweensOf(selector1);
				FlxTween.tween(selector1, {x: -130}, 0.5, {ease: FlxEase.expoOut});
			}
			selector1.x -= offset;
			selector1.y -= 37;
			return;
		}
		selector1.x -= offset;
		selector1.y -= 37;

		offset = 75;

		selector2.x += offset;
		selector2.y += offset/2;
		if (FlxG.mouse.overlaps(selector2)) {
			if (FlxG.mouse.justPressed) {
				changeDiff(1);
				selector2.x += 10;
				FlxTween.cancelTweensOf(selector2);
				FlxTween.tween(selector2, {x: 260}, 0.5, {ease: FlxEase.expoOut});
			}
			selector2.x -= offset;
			selector2.y -= offset/2;
			return;
		}
		selector2.x -= offset;
		selector2.y -= offset/2;

		for (i => capsule in daCapsules) {
			if (FlxG.mouse.overlaps(capsule) && FlxG.mouse.justPressed) {
				if (i == FreeplayMenu.curSelectedSong) {
					playSong(songs[FreeplayMenu.curSelectedSong].id, difficulties[FreeplayMenu.curSelectedDiff]);
				} else {
					NovaUtils.playMenuSFX(SCROLL);
					changeSelection(i - FreeplayMenu.curSelectedSong);
				}
			}
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

		var prevDiffList = difficulties.copy();
		var song:Song = songs[curSelectedSong];
		difficulties = song.difficulties.copy();
		difficultyAssociations.clear();
		for (i in difficulties) difficultyAssociations.set(i, '');
		for (i in song.variants) {
			if (SongRegistry.songDatas.exists('${song.id}:$i')) {
				var varientData = SongRegistry.getSongByID('${song.id}:$i');
				difficulties = difficulties.concat(varientData.difficulties.copy());
				for (d in varientData.difficulties) {
					difficultyAssociations.set(d, i);
				}
			}
		}
		var curDiffList = difficulties;
		var newIndex:Int = Math.floor(curDiffList.length / 2);
		if (prevDiffList[curSelectedDiff] == prevDiffList[curSelectedDiff])
			for (i => diff in curDiffList)
				if (diff == prevDiffList[curSelectedDiff]) {
					newIndex = i;
					break;
				}
		changeDiff(newIndex, true);
		playInst();
		updateScore();
		updateAlbum();
	}

	function conditionCheck() {
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
	}

	function playInst() {
		var inst = '${songs[curSelectedSong].songName}/song/Inst${variant != '' ? '-${variant}' : ''}';
		instTimer.cancel();

		if (inst == prevInst)
			return;

		instTimer = new FlxTimer().start(0.8, (_) -> {
			prevInst = inst;
			var tv = songs[curSelectedSong].variant;
			Conductor.playSong(songs[curSelectedSong].songName, tv != null && tv != '' ? tv : variant, true);
			Conductor.instrumental.volume = 0.8;
			Conductor.instrumental.looped = true;
		});
	}

	function changeDiff(amount:Int, pureSelect:Bool = false) {
		var song:Song = songs[curSelectedSong];
		curSelectedDiff = FlxMath.wrap(pureSelect ? amount : curSelectedDiff + amount, 0, difficulties.length - 1);
		if (curSelectedDiff >= difficulties.length)
			curSelectedDiff = 0;

		var direction = amount > 0 ? 1 : -1;
		var distance = 80;

		playInst();

		for (i=> capsule in daCapsules) {
			var target = SongRegistry.getSongByID(songs[i].id + (variant != '' ? ':${variant}' : ''));
			target ??= SongRegistry.getSongByID(songs[i].id);
			capsule.songNameText.text = target._data.displayName;
		}

		for (i in difficultyDots.keys()) {
			var dot = difficultyDots.get(i);
			var diffListLower = [for (i in difficulties) i.toLowerCase()];
			dot.alpha = diffListLower.contains(i) ? 1 : 0.5;
			dot.setSelected(difficulties[curSelectedDiff].toLowerCase() == i);
		}

		if (pureSelect) {
			diffSprite.loadSprite(Paths.image('menus/freeplay/difficulties/${difficulties[curSelectedDiff]}'));
			if (diffSprite.animated) {
				diffSprite.addAnim('idle', 'idle', 24, true);
				diffSprite.playAnim('idle', true);
			}
			for (i => capsule in daCapsules)
				capsule.updateRatingForDiff(songs[i], difficulties[FlxMath.wrap(curSelectedDiff, 0, difficulties.length - 1)]);
			return;
		}

		FlxTween.cancelTweensOf(diffSprite);
		FlxTween.tween(diffSprite, {x: diffSprite.x - (distance * amount), alpha: 0}, 0.15, {
			ease: FlxEase.expoIn,
			onComplete: (_) -> {
				diffSprite.loadSprite(Paths.image('menus/freeplay/difficulties/${difficulties[curSelectedDiff]}'));
				if (diffSprite.animated) {
					diffSprite.addAnim('idle', 'idle', 24, true);
					diffSprite.playAnim('idle', true);
				}
				diffSprite.updateHitbox();
				diffSprite.x = distance * direction * 2;
				for (i => capsule in daCapsules)
					capsule.updateRatingForDiff(songs[i], difficulties[FlxMath.wrap(curSelectedDiff, 0, difficulties.length - 1)]);
				FlxTween.tween(diffSprite, {x: ((selector1.x + selector2.x) / 2) - (diffSprite.width / 2) + 27, alpha: 1}, 0.1, {ease: FlxEase.expoOut});
			}
		});
		updateAlbum();
		updateScore();
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
					PlayState.loadSong(id + (variant != '' ? ':${variant}' : ''), difficulty, null);
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
		FlxTween.cancelTweensOf(highscoreImg);
		FlxTween.cancelTweensOf(scoreText);

		for (i in difficultyDots) {
			FlxTween.cancelTweensOf(i);
			FlxTween.tween(i, {x: -FlxG.width}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.25});
		}
		FlxTween.tween(diffSprite, {x: -FlxG.width}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.2});
		FlxTween.tween(ostText, {y: -150}, 0.3, {ease: FlxEase.expoIn});
		FlxTween.tween(freeplayText, {y: -150}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.1});
		FlxTween.tween(diffSprite, {x: -FlxG.width}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.2});
		FlxTween.tween(selector1, {x: -250}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.3});
		FlxTween.tween(selector2, {x: -250}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.3});
		FlxTween.tween(black, {y: -300}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.4});
		FlxTween.tween(backingImage, {x: -backingImage.width - 160}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.5});
		FlxTween.tween(backingCard, {x: -backingCard.width - 160}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.6});
		FlxTween.tween(album, {x: FlxG.width}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.5});
		FlxTween.tween(highscoreImg, {x: FlxG.width + 190}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.6});
		FlxTween.tween(scoreText, {x: FlxG.width + 150}, 0.3, {ease: FlxEase.expoIn, startDelay: 0.55});

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

	override function destroy() {
		highscoreTimer?.cancel();
		super.destroy();
	}
}
