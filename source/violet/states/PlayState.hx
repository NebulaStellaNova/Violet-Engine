package violet.states;

import openfl.events.KeyboardEvent;
import violet.backend.utils.StringUtil;
import violet.backend.utils.WindowUtil;
import violet.backend.filesystem.HXCHandler;
import flixel.FlxObject;
import flixel.math.FlxPoint;
import violet.backend.replay.ReplaySystem;
import violet.backend.utils.ParseUtil;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;

import violet.backend.audio.Conductor;
import violet.backend.objects.NovaCamera;
import violet.backend.objects.play.ComboGroup;
import violet.backend.objects.play.HealthBar;
import violet.backend.objects.play.Note;
import violet.backend.objects.play.ScoreTxt;
import violet.backend.objects.play.StrumLine;
import violet.backend.objects.play.Sustain;
import violet.backend.options.Options;
import violet.backend.scripting.events.EventBase;
import violet.backend.scripting.events.NoteHitEvent;
import violet.backend.scripting.events.SongEvent;
import violet.backend.scripting.events.SustainHitEvent;
import violet.backend.utils.MathUtil;
import violet.backend.utils.NovaUtils;
import violet.backend.utils.ScoreUtil;
import violet.data.Constants;
import violet.data.Scoring;
import violet.data.character.Character;
import violet.data.chart.Chart;
import violet.data.chart.ChartData.ChartEvent;
import violet.data.chart.ChartRegistry;
import violet.data.icon.HealthIcon;
import violet.data.song.Song;
import violet.data.song.SongRegistry;
import violet.data.stage.Stage;
import violet.states.menus.FreeplayMenu;
import violet.states.menus.StoryMenu;
import violet.states.menus.MainMenu;
import violet.states.menus.PauseMenu;
import violet.backend.objects.play.DialogueHandler;

#if SCRIPT_SUPPORT
import violet.backend.scripting.ScriptPack;
#end

#if debug
import violet.backend.display.DebugDisplay;
#end

class CameraOffset {

	public var zoom:Float;
	public var x:Float = 0;
	public var y:Float = 0;

	public function new(initialZoom:Float)
		zoom = initialZoom;

}

class PlayState extends violet.backend.StateBackend {

	public var recordingMode:Bool = false;
	public var playbackMode:Bool = false;

	public static var instance:PlayState;
	public static var SONG:Chart;
	public static var songData:Song;
	public static var song:String;
	public static var difficulty:String;
	public static var variation:Null<String>;
	public static var playlist:Array<String> = [];
	public static var doFadeOut:Bool = false;
	public static var hasSeenCutscene:Bool = false;
	public static var hasSeenDialogue:Bool = false;
	public static var isStoryMode:Bool = false;
	public static var curStoryLevel:String;
	public static var storyScore:Int = 0;

	public var defaultSuffix:Array<String> = [];

	public var staticAccess = PlayState;

	public var countdownEase:Float->Float = FlxEase.linear;

	public var inCutscene = false;
	public var inDialogue = false;

	#if SCRIPT_SUPPORT
	public var songScripts:ScriptPack = new ScriptPack();
	#end

	public var camHUD:FlxCamera;
	public var camGame:NovaCamera;

	public var stage:Stage;
	public var characters:Array<Character> = [];
	public var characterIDs:Array<String> = [];

	public var strumLines:FlxTypedGroup<StrumLine>;
	public var generalVocals:FlxSound;

	public var defaultCamZoom:Float = 0.7;

	public var pauseTime:Float = 0;

	public var combo:Int = 0;
	public var misses:Int = 0;
	private var accuracies:Array<Float> = [];
	public var accuracy(get, never):Float;
	function get_accuracy():Float {
		var out = 100.0;
		for (i in accuracies) {
			out += i;
		}
		out /= accuracies.length + 1;
		return Math.round(out * 100) / 100;
	}

	public var score:Int = 0;
	public var healthBar:HealthBar;
	public var health:Float;

	public var iconPlayer:HealthIcon;
	public var iconOpponent:HealthIcon;

	public var scoreTxt:ScoreTxt;

	public var playAsOpponent:Bool = Options.data.playAsOpponent;
	public var ghostTapping:Bool = Options.data.ghostTapping;

	public var hasChangedPracticeMode(default, null):Bool = false;
	public static var practiceMode(default, set):Bool = false;
	static function set_practiceMode(value:Bool):Bool {
		if (value != practiceMode)
			@:bypassAccessor PlayState.instance.hasChangedPracticeMode = true;
		return practiceMode = value;
	}

	public var countdownSprites:Array<String> = [null, 'ready', 'set', 'go'];
	public var countdownSounds:Array<String> = ['introTHREE', 'introTWO', 'introONE', 'introGO'];
	public var countdownTimer:FlxTimer = new FlxTimer();

	public var comboGroup:ComboGroup;

	public var cameraOffsets:Array<CameraOffset> = [];
	public var camGameBase:CameraOffset = new CameraOffset(1);
	public var camGameOffset:CameraOffset = new CameraOffset(0);

	public var strumlineTarget:Int = 0;
	public var camFollowPoint:FlxPoint = new FlxPoint(0, 0);

	public var camBopInterval:Int = 4;
	public var camBopOffset:Int = 0;
	public var camBopAmount:Float = 1;

	/**
	 * The amount of beats the countdown lasts for.
	 */
	public var countdownLength(default, set):Int = 5;
	inline function set_countdownLength(value:Int):Int
		return countdownLength = Std.int(Math.max(value, 1));
	/**
	 * States if the countdown has started.
	 */
	public var countdownStarted(default, null):Bool = false;
	/**
	 * States if the song has started.
	 */
	public var songStarted(default, null):Bool = false;
	/**
	 * States if the song has ended.
	 */
	public var songEnded(default, null):Bool = false;

	override public function create():Void {
		super.create();
		instance = this;
		inCutscene = false;

		FlxG.cameras.reset(camGame = new NovaCamera());
		camHUD = new FlxCamera();
		camHUD.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camHUD, false);

		SONG = ChartRegistry.getChart(song, difficulty, variation);
		songData = SongRegistry.getSongByID(song);
		variation = songData.variant;

		for (i => data in SONG.events) {
			if (data.name == "Change Character") {
				Cache.character(data.params[1]);
			}
		}

		for (i => data in SONG.strumLines) {
			if (data == null) continue;
			for(charName in data.characters) if (charName != null) characterIDs.push(charName);
		}

		ModdingAPI.checkForScripts('songs', songScripts);
		ModdingAPI.checkForScripts('data/scripts/songs', songScripts);
		ModdingAPI.checkForScripts('songs/$song/scripts', songScripts);
		ModdingAPI.checkForScripts('songs/$song/scripts/$difficulty', songScripts);
		songScripts.parent = this;
		songScripts.execute();
		callSongScripts('onLoaded');

		strumLines = new FlxTypedGroup<StrumLine>();

		Conductor.playSong(songData.songName, variation); Conductor.pause();
		Conductor.offset = (countdownLength) * Conductor.beatLengthMs;
		if (SONG.meta.needsVoices) generalVocals = Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(songData.songName, null, PlayState.variation), 'root', null, true), FlxG.sound.defaultMusicGroup));
		else generalVocals = Conductor.addAdditionalTrack(new FlxSound());

		StrumLine.generalScrollSpeed = SONG.scrollSpeed ?? 1;
		for (i => data in SONG.strumLines) {
			if (data == null) continue;

			var strumLine = new StrumLine(data);
			strumLine.camera = camHUD;
			strumLine.visible = data.visible;
			strumLine.z = 1000;
			strumLine.ID = i;
			strumLines.add(strumLine);

			for(i=>charName in data.characters) {
				if (charName == null) continue;
				var char = new Character(i * 50, 0, charName, i == 1);
				char.alpha = 0.5;
				char.stagePosition = data.charStagePosition;
				if (data.charStagePosition == 'boyfriend' && iconPlayer == null) {
					iconPlayer = new HealthIcon(char._data.healthIcon, false);
				} else if (iconOpponent == null) {
					iconOpponent = new HealthIcon(char._data.healthIcon);
				}
				strumLine.characters.push(char);
				characters.push(char);
				songScripts.set(char.id.replace('-', '_').replace(' ', '_ '), char);
				// add(char);
			}

			// note interactions
			strumLine._onVoidTap = onVoidTap;
			strumLine._onNoteHit = onNoteHit;
			strumLine._onSustainHit = onSustainHit;
			strumLine._onNoteMissed = onNoteMissed;
			strumLine._onSustainMissed = onSustainMissed;
		}
		add(strumLines);
		Conductor.onComplete = endSong;

		for (i in SONG._data.noteTypes) {
			ModdingAPI.checkForScripts('data/notetypes', i, songScripts);
		}

		if (playAsOpponent) {
			for (strumLine in strumLines) {
				if (strumLine.controllerType == PLAYER) strumLine.controllerType = OPPONENT;
				else if (strumLine.controllerType == OPPONENT) strumLine.controllerType = PLAYER;
			}
		}

		comboGroup = new ComboGroup(Options.data.kadePopups ? 'kade' : 'funkin');

		stage = new Stage(SONG.stage);
		stage.stageScripts.parent = this;
		stage.load(characters);
		defaultCamZoom = stage._data.zoom;
		camGameBase.zoom = defaultCamZoom;

		if (!members.contains(comboGroup)) {
			comboGroup.visible = false;
			comboGroup.setPosition(FlxG.width / 2, FlxG.height / 2);
			comboGroup.zIndex = -1;
			add(comboGroup);
		}

		healthBar = new HealthBar();
		healthBar.y = Options.data.downscroll ? FlxG.height * 0.1 : FlxG.height * 0.9;
		healthBar.camera = camHUD;
		healthBar.screenCenter(X);
		add(healthBar);

		if (iconOpponent == null) iconOpponent = new HealthIcon('face'); // Null safety
		iconOpponent.scaleFromCenter = false;
		if (iconPlayer == null) iconPlayer = new HealthIcon('face', false); // Null safety
		iconPlayer.scaleFromCenter = false;

		if (iconOpponent._data.color != null && Options.data.coloredHealthBar) {
			healthBar.leftColor = iconOpponent._data.color;
		} else {
			healthBar.leftColor = FlxColor.RED;
		}
		if (iconPlayer._data.color != null && Options.data.coloredHealthBar) {
			healthBar.rightColor = iconPlayer._data.color;
		} else {
			healthBar.rightColor = FlxColor.LIME;
		}

		scoreTxt = new ScoreTxt();
		scoreTxt.x = healthBar.x + healthBar.width - scoreTxt.width;
		scoreTxt.y = healthBar.y + healthBar.height + 5;
		scoreTxt.camera = camHUD;
		add(scoreTxt);

		iconPlayer.camera = camHUD;
		add(iconPlayer);

		iconOpponent.camera = camHUD;
		add(iconOpponent);

		health = 0.5;

		callSongScripts('create');

		startCountdown();
		// startSong();

		for (strumLine in strumLines)
			strumLine.generateNotes(Conductor.songPosition);

		callSongScripts('postCreate');

		if (doFadeOut) {
			doFadeOut = false;
			camHUD.fade(0.001);
			new FlxTimer().start(0.1, (_)->{
				camHUD.fade(0.5, true);
			});
		}

		#if debug
		DebugDisplay.registerVariable('Current Song', () -> return '$song:$difficulty');
		DebugDisplay.registerVariable('Is Story Mode', () -> return isStoryMode);
		DebugDisplay.registerVariable('Misses & Accuracy', () -> return '$misses - $accuracy');
		if (playlist.length != 0) DebugDisplay.registerVariable('Playlist Items', () -> return playlist);
		#end

		Conductor.setSongPosition(0);


		camFollowPoint.x = stage._data.cameraPosition[0];
		camFollowPoint.y = stage._data.cameraPosition[1];
		camGame.followLerp = 0.075;
		snapCamera();
	}

	var healthLerp:Float = 0.5;
	var scoreLerp:Float = 0;

	var prevLerp:Float = 0;
	function snapCamera() {
		prevLerp = camGame.followLerp;
		camGame.followLerp = 0;
	}

	var camXLerp:Float = 0;
	var camYLerp:Float = 0;
	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (!songStarted) Conductor.setSongPosition(0);

		staticExit = exitToMenu;

		callSongScripts('update', [elapsed]);
		callSongScripts('onUpdate', [elapsed]);

		var totalTime = Conductor.instrumental.length;
		var currentTime = Conductor.instrumental.time;

		WindowUtil.suffix = ' - ${songData.displayName} [${StringUtil.capitalizeFirst(difficulty)}] - ${StringUtil.formatTime(currentTime, "m:ss")} / ${StringUtil.formatTime(totalTime, "m:ss")}';

		var camTargetX:Float = camFollowPoint.x - (FlxG.width/2);
		var camTargetY:Float = camFollowPoint.y - (FlxG.height/2);
		var camOffsetX:Float = 0;
		var camOffsetY:Float = 0;

		camGame.zoom = camGameBase.zoom + camGameOffset.zoom;
		for (i in cameraOffsets) {
			camGame.zoom += i.zoom;
			camOffsetX += i.x ?? 0;
			camOffsetY += i.y ?? 0;
		}

		camXLerp = camGame.followLerp == 0 ? camTargetX : lerp(camXLerp, camTargetX, camGame.followLerp);
		camYLerp = camGame.followLerp == 0 ? camTargetY : lerp(camYLerp, camTargetY, camGame.followLerp);

		camGame.scroll.x = camXLerp + camOffsetX;
		camGame.scroll.y = camYLerp + camOffsetY;

		if (camGame.followLerp == 0) {
			camGame.followLerp = prevLerp;
		}

		if (Controls.pause && !FlxG.mouse.justPressed) {
			pause();
		}

		scoreLerp = MathUtil.lerp(scoreLerp, score, 0.25);
		scoreTxt.value = Options.data.disableScoreLerping ? Math.round(score) : Math.round(scoreLerp);

		health = FlxMath.bound(health, 0, 1);

		healthLerp = MathUtil.lerp(healthLerp, health, 0.1);
		healthBar.position = healthLerp;

		iconPlayer.x = healthBar.x + healthBar.defaultWidth * (1-healthLerp);
		iconPlayer.y = healthBar.y + (healthBar.height/2) - (iconPlayer.height/2);

		iconOpponent.x = healthBar.x + healthBar.defaultWidth * (1-healthLerp) - iconOpponent.width;
		iconOpponent.y = healthBar.y + (healthBar.height/2) - (iconOpponent.height/2);

		iconPlayer.updateFromHealth(health);
		iconOpponent.updateFromHealth(health);

		for (i in SONG.events) {
			if (i.time <= Conductor.songPosition) {
				handleEvent(i);
			}
		}

		if (health == 0 || (Controls.reset && Options.data.developerMode)) {
			if (!practiceMode) FlxG.switchState(new GameOverState(strumLines.members[1].characters[0]));
			else health = 0.01;
		}

		callSongScripts('postUpdate', [elapsed]);
		callSongScripts('onUpdatePost', [elapsed]);
	}

	function onVoidTap(id:Int, strumLine:StrumLine) {
		strumLine.strums.members[id].playStrumAnim('press', ghostTapping);
		if (!ghostTapping) {
			playMissSound();
			for (char in strumLine.characters)
				char.playSingAnim(id, true);
			score += Math.round(Scoring.missScore);
			health -= Constants.DEFAULT_HEALTH_LOSS;
		}
	}

	function playMissSound() {
		if (Options.data.playMissSound)
			FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
	}

	function onNoteHit(note:Note) {
		if (!Conductor.instrumental.playing && note.parent.isComputer) return;
		if (note.wasHit) return;
		final event:NoteHitEvent = runSongEvent('noteHit', new NoteHitEvent(note));
		if (event.cancelled) return;

		note.wasHit = true; note.visible = false;
		generalVocals.resume(); note.parent.vocals.resume();
		if (event.playStrumAnim) note.parentStrum.playStrumAnim('confirm', true);

		if (!event.animCancelled)
			for (i=>char in note.parent.characters) {
				char.playSingAnim(note.id, event.animationSuffix, true);
			}

		if (note.parent.isPlayer) {
			final judgement:Judgement = Scoring.judgeNoteHit(note.time - Conductor.framePosition);
			if (judgement.splash && event.spawnSplash != false) note.parentStrum.spawnSplash(note);
			score += Math.round(judgement.score);
			health += Constants.DEFAULT_HEALTH_GAIN;
			combo++;
			comboGroup.popupRating(judgement.rating, combo);

			var noteHitDelta = note.time - Conductor.framePosition;
			// trace(Math.abs(noteHitDelta) + ', ' + Scoring.missThreshold);
			var rawAcc = Math.abs(noteHitDelta) / Scoring.missThreshold;
			var roundedAcc = Math.round(rawAcc*10000)/10000;
			var acc = 100 - (roundedAcc * 100);
			accuracies.push(acc);
		} else if (event.spawnSplash == true) // on purpose ***do not touch***
			note.parentStrum.spawnSplash(note);

		if (event.spawnHoldCover)
			note.parentStrum.spawnHoldCover();

		runSongEvent('noteHitPost', event);
	}

	function onNoteMissed(note:Note) {
		if (!Conductor.instrumental.playing && note.parent.isComputer) return;
		if (note.wasMissed) return;
		final event:NoteHitEvent = runSongEvent('noteMissed', new NoteHitEvent(note));
		if (event.cancelled) return;

		misses++;
		combo = 0;

		note.wasMissed = true; note.alpha *= 0.6;
		generalVocals.pause(); note.parent.vocals.pause();
		playMissSound();

		for (sustain in Note.filterTail(note.tail, true)) {
			sustain.wasMissed = true;
			sustain.alpha *= 0.6;
		}

		for (char in note.parent.characters)
			char.playSingAnim(note.id, true);

		if (note.parent.isPlayer) score += Math.round(Scoring.missScore);
		health -= Constants.DEFAULT_HEALTH_LOSS * (note.parent.isPlayer ? 1 : -1);

		note.parentStrum.holdCover?.playAnim('end', true);
		if (note.parent.isComputer) note.parentStrum.holdCover?.animation.finish();
		note.parentStrum.holdCover = null;

		runSongEvent('noteMissedPost', event);
	}

	function onSustainHit(sustain:Sustain) {
		if (!Conductor.instrumental.playing && sustain.parent.isComputer) return;
		if (sustain.wasHit && !sustain.parentNote.wasHit) return;
		final event:SustainHitEvent = runSongEvent('sustainHit', new SustainHitEvent(sustain));
		if (event.cancelled) return;

		sustain.wasHit = true;
		generalVocals.resume(); sustain.parent.vocals.resume();
		if (event.playStrumAnim) sustain.parentStrum.playStrumAnim('confirm', true);

		if (!event.animCancelled)
			for (char in sustain.parent.characters)
				char.playSingAnim(sustain.id, event.animationSuffix);

		if (sustain.parent.isPlayer)
			health += Constants.DEFAULT_HEALTH_GAIN;

		if (sustain.isEnd) {
			sustain.parentStrum.holdCover?.playAnim('end', true);
			if (sustain.parent.isComputer) sustain.parentStrum.holdCover?.animation.finish();
			sustain.parentStrum.holdCover = null;
			sustain.parentNote.destroy();
		}

		runSongEvent('sustainHitPost', event);
	}

	function onSustainMissed(sustain:Sustain) {
		if (!Conductor.instrumental.playing && sustain.parent.isComputer) return;
		if (sustain.wasMissed) return;
		final event:SustainHitEvent = runSongEvent('sustainMissed', new SustainHitEvent(sustain));
		if (event.cancelled) return;

		sustain.wasMissed = true; sustain.alpha *= 0.6;
		generalVocals.pause(); sustain.parent.vocals.pause();
		playMissSound();
		for (sustain in Note.filterTail(sustain.parentNote.tail, true)) {
			sustain.wasMissed = true;
			sustain.alpha *= 0.6;
		}

		for (char in sustain.parent.characters)
			char.playSingAnim(sustain.id, true);

		if (sustain.parent.isPlayer) score += Math.round(Scoring.missScore);
		health -= Constants.DEFAULT_HEALTH_LOSS * (sustain.parent.isPlayer ? 1 : -1);
		combo = 0;

		sustain.parentStrum.holdCover?.playAnim('end', true);
		if (sustain.parent.isComputer) sustain.parentStrum.holdCover?.animation.finish();
		sustain.parentStrum.holdCover = null;

		runSongEvent('sustainMissedPost', event);
	}

	var countdownTick = 0;


	function startCountdown():Void {

		// Start Dialogue
		if (!hasSeenDialogue) {
			var sD:Array<ConverstationPiece> = ParseUtil.jsonOrYaml('songs/$song/start-dialogue', null, 'null');
			if (sD != null) {
				var dialogueHandler = new DialogueHandler(sD);
				dialogueHandler.camera = camHUD;
				dialogueHandler.updateHitbox();
				dialogueHandler.screenCenter();
				dialogueHandler.y += 150;
				add(dialogueHandler);

				dialogueHandler.onDialogueEnd = ()->{
					dialogueHandler.destroy();
					inDialogue = false;
					hasSeenDialogue = true;
					startCountdown();
				}
				inDialogue = true;
				return;
			}
		}

		countdownTick = 0;
		var event:EventBase = runSongEvent('startCountdown', new EventBase());
		if (event.cancelled) return;
		countdownStarted = true;
		tickCountdown();
		FlxTween.num(0, Conductor.offset, ((countdownLength) * Conductor.beatLengthMs)/1000, { ease: countdownEase }, (v)->{
			Conductor.offset = ((countdownLength) * Conductor.beatLengthMs) - v;
		});
	}

	function tickCountdown() {
		countdownTimer.cancel();
		if (countdownTick == countdownLength-1) {
			countdownTimer = new FlxTimer().start(Conductor.beatLengthMs / 1000, _ -> startSong());
			return;
		}
		countdownTimer = new FlxTimer().start(Conductor.beatLengthMs / 1000, _ -> {
			if (countdownSounds[countdownTick] != null) NovaUtils.playSound('game/countdown/funkin/${countdownSounds[countdownTick]}');
			if (countdownSprites[countdownTick] != null) {
				var countdownSprite:NovaSprite = new NovaSprite(Paths.image('game/countdown/funkin/${countdownSprites[countdownTick]}'));
				countdownSprite.camera = camHUD;
				countdownSprite.scale.set(0.8, 0.8);
				countdownSprite.updateHitbox();
				countdownSprite.screenCenter();
				countdownSprite.alpha = 0;
				add(countdownSprite);
				var ms = Conductor.beatLengthMs / 1000;
				FlxTween.tween(countdownSprite, { alpha: 1 }, ms/4);
				FlxTween.tween(countdownSprite, { alpha: 0 }, ms/4, { startDelay: (ms/4)*3 });
				FlxTween.tween(countdownSprite, { y: countdownSprite.y + 200 }, ms, { ease: FlxEase.backIn, onComplete: (_)->{
					remove(countdownSprite);
					countdownSprite.destroy();
				}});
			}
			countdownTick++;
			tickCountdown();
			beatHit(0-countdownTick);
		});
		//
	}


	var scrollTween:FlxTween;
	function handleEvent(event:ChartEvent) {
		if (event.ran) return;
		event.ran = true;
		var eventName = event.type != null ? [null, 'Camera Movement'][event.type] : event.name;
		var scriptEvent:SongEvent = runSongEvent('onEvent', new SongEvent(eventName, event.params));
		if (scriptEvent.cancelled) return;

		switch (eventName) {
			case 'Alt Animation Toggle':
				var enableOnSing:Bool = event.params[0];
				var enableOnIdle:Bool = event.params[1];
				var strumLineID:Int = event.params[2];
				defaultSuffix[strumLineID] = enableOnSing ? 'alt' : null;
				for (i in strumLines.members[strumLineID].characters)
					i.idleSuffix = enableOnIdle ? 'alt' : null;

			case 'Change Character':
				var strumlineID:Int = event.params[0];
				var characterID:String = event.params[1];
				var characterIndex:Int = event.params[2];
				var updateIcon:Bool = event.params[3];

				var charToReplace:Character = strumLines.members[strumlineID].characters[characterIndex];
				var isPlayer = charToReplace.stagePosition == "boyfriend";
				var charToAdd:Character = new Character(characterID, isPlayer);
				charToAdd.stagePosition = charToReplace.stagePosition;
				charToAdd.x = charToReplace.x;
				charToAdd.y = charToReplace.y;
				charToAdd.z = charToReplace.z + 1;

				if (charToAdd.animationList.contains(charToReplace.prevPlayedAnim)) {
					charToAdd.playAnim(charToReplace.prevPlayedAnim);
					charToAdd.animation.curAnim.curFrame = charToReplace.animation.curAnim.curFrame;
				}

				var indexToAdd = members.indexOf(charToReplace) + 1;
				remove(charToReplace);
				strumLines.members[strumlineID].characters[characterIndex] = charToAdd;
				insert(indexToAdd, strumLines.members[strumlineID].characters[characterIndex]);
				characters.push(charToAdd);

				if (updateIcon)
					isPlayer ? iconPlayer.setIcon(charToAdd._data.healthIcon) : iconOpponent.setIcon(charToAdd._data.healthIcon);


			case 'Camera Modulo Change':
				camBopInterval = event.params[0] ?? 4;
				camBopOffset = event.params[1] ?? 0;
				camBopAmount = event.params[2] ?? 1;

			case 'Camera Position':
				scrollTween?.cancel();
				var x:Float = scriptEvent.params[0];
				var y:Float = scriptEvent.params[1];
				var duration:Float = scriptEvent.params[2];
				var ease:String = scriptEvent.params[3];
				var direction:String = scriptEvent.params[4];
				var targetEase = null;
				if (direction == null) targetEase = NovaUtils.easeFromString(ease, '');
				else targetEase = NovaUtils.easeFromString(ease, direction);

				scrollTween = FlxTween.tween(camFollowPoint, { x: x, y: y }, (Conductor.stepLengthMs / 1000) * duration, { ease: targetEase, onUpdate: _->{
					snapCamera();
				}});

			case 'Camera Tween Focus': // To tween to the target
				scrollTween?.cancel();
				var targetCharacter:Character = strumLines.members[scriptEvent.params[0]].characters[0];
				strumlineTarget = scriptEvent.params[0];

				var x = targetCharacter.getMidpoint().x + (targetCharacter.cameraOffsets ?? [0, 0])[0];
				var y = targetCharacter.getMidpoint().y + (targetCharacter.cameraOffsets ?? [0, 0])[1];

				var duration:Float = scriptEvent.params[1];
				var ease:String = scriptEvent.params[2];
				var direction:String = scriptEvent.params[5];
				var targetEase = null;
				if (direction == null) targetEase = NovaUtils.easeFromString(ease, '');
				else targetEase = NovaUtils.easeFromString(ease, direction);
				scrollTween = FlxTween.tween(camFollowPoint, { x: x, y: y }, (Conductor.stepLengthMs / 1000) * duration, { ease: targetEase, onUpdate: _->{
					snapCamera();
				}});

			case 'Camera Movement':
				scrollTween?.cancel();
				var targetCharacter:Character = strumLines.members[scriptEvent.params[0]].characters[0];
				strumlineTarget = scriptEvent.params[0];
				camFollowPoint.x = targetCharacter.getMidpoint().x + (targetCharacter.cameraOffsets ?? [0, 0])[0];
				camFollowPoint.y = targetCharacter.getMidpoint().y + (targetCharacter.cameraOffsets ?? [0, 0])[1];

			case 'Camera Zoom':
				if (scriptEvent.params[0]) {
					var targetCamera = ['camGame' => camGameBase].get(scriptEvent.params[2]);
					var	targetZoom = scriptEvent.params[1];
					var targetDuration = (Conductor.stepLengthMs/1000) * scriptEvent.params[3];
					var targetEase = NovaUtils.easeFromString(scriptEvent.params[4], scriptEvent.params[5] ?? '');
					FlxTween.cancelTweensOf(targetCamera);
					FlxTween.tween(targetCamera, { zoom: targetZoom }, targetDuration, { ease: targetEase });
				}

			case 'Play Animation':
				var targetCharacter:Character = strumLines.members[scriptEvent.params[0]].characters[0];
				targetCharacter.canDance = false;
				targetCharacter.canSing = false;
				targetCharacter.isSinging = false;
				targetCharacter.playAnim(scriptEvent.params[1], true);
				targetCharacter.animation.onFinish.addOnce(name -> {
					if (name == scriptEvent.params[1]) {
						targetCharacter.canDance = true;
						targetCharacter.canSing = true;
						targetCharacter.dance(true);
						if (!targetCharacter.hasNeitherAnims)
							targetCharacter.animation.finish();
					}
				});
		}


		if (event.name != null) {
			trace('debug:Ran song event named "<yellow>${event.name}<reset>" with parameters "<yellow>${event.params.join(", ")}<reset>"');
		} else if (event.type != null) {
			trace('debug:Ran song event named "<yellow>${[null, "Camera Movement"][event.type]}<reset>" with parameters "<yellow>${event.params.join(", ")}<reset>"');
		}

		runSongEvent('onEventPost', scriptEvent);
		// trace('debug:Ran event ');
		// trace('debug:$event');
	}

	function startSong(startDelay:Int = 0):Void {

		if (songStarted) return;

		var event = runSongEvent('startSong', runSongEvent('songStart', new EventBase()));

		if (event.cancelled) return;

		songStarted = true;
		Conductor.play(true, -Conductor.beatLengthMs * Math.abs(startDelay));
		ReplaySystem.includedKeys = [
			Options.data.controls.get('note_left')[0],
			Options.data.controls.get('note_left')[1],
			Options.data.controls.get('note_down')[0],
			Options.data.controls.get('note_down')[1],
			Options.data.controls.get('note_up')[0],
			Options.data.controls.get('note_up')[1],
			Options.data.controls.get('note_right')[0],
			Options.data.controls.get('note_right')[1]
		];
		if (playbackMode) ReplaySystem.playReplay(SONG.id);
		if (recordingMode) ReplaySystem.startRecording();
	}

	function endSong():Void {
		var event:EventBase = runSongEvent('endSong', runSongEvent('songEnd', new EventBase()));
		if (event.cancelled) return;
		songEnded = true;
		if (!hasChangedPracticeMode && !practiceMode) ScoreUtil.saveSongScore(songData.songName, difficulty, songData.variant, score);
		if (!hasChangedPracticeMode && !practiceMode) ScoreUtil.saveSongAccuracy(songData.songName, difficulty, songData.variant, accuracy);
		storyScore += score;
		if (playlist.length == 0 || !isStoryMode) {
			exitToMenu();
		} else {
			hasSeenCutscene = false;
			loadSong(playlist.shift(), difficulty, variation);
		}
		if (isStoryMode && playlist.length == 0) ScoreUtil.saveLevelScore(curStoryLevel, difficulty, storyScore);
	}

	public function pause() {
		if (inDialogue) return;
		var event:EventBase = runSongEvent('pause', stage.stageScripts.event('pause', new EventBase()));
		if (!event.cancelled) {
			countdownTimer.active = false;

			FlxTween.globalManager.forEach((tween:FlxTween)->{
				tween.active = false;
			});

			for (i in strumLines) {
				for (key in ['note_left', 'note_down', 'note_up', 'note_right']) {
					for (flxkey in Controls.bindMap.get(key)) {
						@:privateAccess i._on_release(new KeyboardEvent("", 0, flxkey), true);
					}
				}
			}

			pauseTime = Conductor.instrumental.time;
			var pauseMenu:PauseMenu = new PauseMenu();
			openSubState(pauseMenu);
		}
	}

	public function callSongScripts(func:String, ?params:Array<Dynamic>):Void {
		HXCHandler.instance.hxcScripts.callVariants(func, params);
		songScripts.callVariants(func, params);
		if (stage != null) stage.stageScripts.callVariants(func, params);
	}

	public function runSongEvent<T:violet.backend.scripting.events.EventBase>(func:String, event:T):T {
		HXCHandler.instance.hxcScripts.event(func, event);
		songScripts.event(func, event);
		return stage.stageScripts.event(func, event);
	}

	override function stepHit(curStep:Int) {
		super.stepHit(curStep);
		songScripts.set('curStep', curStep);
		songScripts.set('curBeat', curBeat);

		callSongScripts('stepHit', [curStep]);
		callSongScripts('postStepHit', [curStep]);
	}

	var camHUDTween:FlxTween;
	var camGameTween:FlxTween;



	override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);

		if (!Conductor.instrumental.playing) return;

		callSongScripts('beatHit', [curBeat]);

		if (curBeat % camBopInterval == camBopOffset || camBopInterval == 1) {
			camGameTween?.cancel();
			camHUDTween?.cancel();
			camGameOffset.zoom += 0.015 * camBopAmount;
			camHUD.zoom = (Conductor.instrumental.playing ? camHUD.zoom : 1) + (0.03 * camBopAmount);
			camGameTween = FlxTween.tween(camGameOffset, { zoom: 0 }, 1, { ease: FlxEase.expoOut });
			camHUDTween = FlxTween.tween(camHUD, { zoom: 1 }, 1, { ease: FlxEase.expoOut });
		}

		callSongScripts('postBeatHit', [curBeat]);
	}

	override function closeSubState() {
		super.closeSubState();
		countdownTimer.active = true;
	}

	public function updateOptions() {
		var event = runSongEvent('updateOptions', new EventBase());
		if (event.cancelled) return;

		ghostTapping = Options.data.ghostTapping;
		for (i=>strumLine in strumLines) {
			if (!strumLine.disableOptionsAffect) {
				strumLine.downscroll = Options.data.downscroll;
				strumLine.generateLanes();
				strumLine.setPosition(SONG.strumLines[i].strumPosition[0], SONG.strumLines[i].strumPosition[1], SONG.strumLines[i].strumPosIsPure);
			}
		}

		comboGroup.style = Options.data.kadePopups ? 'kade' : 'funkin';

		healthBar.y = Options.data.downscroll ? FlxG.height * 0.1 : FlxG.height * 0.9;
		scoreTxt.y = healthBar.y + healthBar.height + 5;
		iconPlayer.y = healthBar.y + (healthBar.height/2) - (iconPlayer.height/2);
		iconOpponent.y = healthBar.y + (healthBar.height/2) - (iconOpponent.height/2);

		if (iconOpponent._data.color != null && Options.data.coloredHealthBar)
			healthBar.leftColor = iconOpponent._data.color;
		else healthBar.leftColor = FlxColor.RED;

		if (iconPlayer._data.color != null && Options.data.coloredHealthBar)
			healthBar.rightColor = iconPlayer._data.color;
		else healthBar.rightColor = FlxColor.LIME;

		runSongEvent('postUpdateOptions', event);
	}

	override public function destroy():Void {
		if (recordingMode) ReplaySystem.stopRecording();
		if (recordingMode) ReplaySystem.saveRecording(SONG.id);
		if (playbackMode) ReplaySystem.stopReplay();
		instance = null;
		Conductor.offset = 0;
		super.destroy();
		for (i in SONG.events) i.ran = false;
		WindowUtil.suffix = '';
	}

	public static function loadSong(id:String, difficulty:String = 'normal', ?variation:String) {
		PlayState.song = id;
		PlayState.difficulty = difficulty;
		PlayState.variation = variation;
		FlxG.switchState(() -> new PlayState());
	}

	public static var staticExit:Void->Void;

	public dynamic function exitToMenu() {
		var onComplete = ()->{
			if (isStoryMode)
				FlxG.switchState(new StoryMenu().build());
			else
				FlxG.switchState(new FreeplayMenu().build());
		}
		if (subState != null) onComplete();
		else {
			for (i in FlxG.cameras.list)
				i.fade(FlxColor.BLACK, 0.5);
			FlxTimer.wait(0.6, onComplete);
		}
	}

}
