package violet.states;

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

	public function new(initialZoom:Float) {
		zoom = initialZoom;
	}
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
	public static var isStoryMode:Bool = false;
	public static var curStoryLevel:String;
	public static var storyScore:Int = 0;

	public var staticAccess = PlayState;

	public var countdownEase:Float->Float = FlxEase.linear;

	public var inCutscene = false;

	#if SCRIPT_SUPPORT
	public var songScripts:ScriptPack = new ScriptPack();
	#end

	public var camHUD:FlxCamera;
	public var camGame:NovaCamera;

	public var stage:Stage;
	public var characters:Array<Character> = [];

	public var strumLines:FlxTypedGroup<StrumLine>;
	public var generalVocals:FlxSound;

	public var defaultCamZoom:Float = 0.7;

	public var misses:Int = 0;

	public var score:Int = 0;
	public var healthBar:HealthBar;
	public var health:Float;

	public var iconPlayer:HealthIcon;
	public var iconOpponent:HealthIcon;

	public var scoreTxt:ScoreTxt;

	public var playAsOpponent:Bool = Options.data.playAsOpponent;
	public var ghostTapping:Bool = Options.data.ghostTapping;

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

		ModdingAPI.checkForScripts('songs', songScripts);
		ModdingAPI.checkForScripts('data/scripts/songs', songScripts);
		ModdingAPI.checkForScripts('songs/$song/scripts', songScripts);
		ModdingAPI.checkForScripts('songs/$song/scripts/$difficulty', songScripts);
		songScripts.parent = this;
		callSongScripts('onLoaded');

		// Start Dialogue
		var sD:Array<ConverstationPiece> = ParseUtil.jsonOrYaml('songs/$song/start-dialogue');
		var dialogueHandler = new DialogueHandler(sD);
		dialogueHandler.camera = camHUD;
		dialogueHandler.updateHitbox();
		dialogueHandler.screenCenter();
		dialogueHandler.y += 150;
		add(dialogueHandler);


		strumLines = new FlxTypedGroup<StrumLine>();

		SONG = ChartRegistry.getChart(song, difficulty, variation);
		songData = SongRegistry.getSongByID(song);
		variation = songData.variant;

		Conductor.playSong(songData.songName, variation); Conductor.pause();
		Conductor.offset = (countdownLength) * Conductor.beatLengthMs;
		if (SONG.meta.needsVoices) generalVocals = Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(songData.songName, null, PlayState.variation), 'root', null, true), FlxG.sound.defaultMusicGroup));
		else generalVocals = Conductor.addAdditionalTrack(new FlxSound());

		StrumLine.generalScrollSpeed = SONG.scrollSpeed ?? 1;
		for (i => data in SONG.strumLines) {
			if (data == null) continue;

			var strumLine = new StrumLine(data);
			strumLine.cameras = [camHUD];
			strumLine.visible = data.visible;
			strumLine.ID = i;
			strumLines.add(strumLine);

			for(i=>charName in data.characters) {
				var char = new Character(i * 50, 0, charName, i == 1);
				char.alpha = 0.5;
				char.stagePosition = data.charStagePosition;
				if (data.charStagePosition == "boyfriend" && iconPlayer == null) {
					iconPlayer = new HealthIcon(char._data.healthIcon);
					iconPlayer.flipX = !iconPlayer.flipX;
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

		comboGroup = new ComboGroup();
		comboGroup.camera =  camGame;
		comboGroup.x = 1100;
		comboGroup.y = 300;

		stage = new Stage(SONG.stage);
		stage.stageScripts.parent = this;
		stage.load(characters);
		defaultCamZoom = stage._data.zoom;
		camGameBase.zoom = defaultCamZoom;

		healthBar = new HealthBar();
		healthBar.y = Options.data.downscroll ? FlxG.height * 0.1 : FlxG.height * 0.9;
		healthBar.camera = camHUD;
		healthBar.screenCenter(X);
		add(healthBar);

		if (iconOpponent == null) iconOpponent = new HealthIcon('face'); // Null safety
		if (iconPlayer == null) iconPlayer = new HealthIcon('face'); // Null safety

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
		iconOpponent.isOpponent = true;
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
		DebugDisplay.registerVariable("Current Song", "song");
		DebugDisplay.registerVariable("Current Difficulty", "difficulty");
		DebugDisplay.registerVariable("Current Variantion", "variation");
		if (playlist.length != 0) DebugDisplay.registerVariable("Playlist Items", "playlist");
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

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		callSongScripts("update", [elapsed]);
		callSongScripts("onUpdate", [elapsed]);

		var camTargetX:Float = camFollowPoint.x - (FlxG.width/2);
		var camTargetY:Float = camFollowPoint.y - (FlxG.height/2);

		camGame.zoom = camGameBase.zoom + camGameOffset.zoom;
		for (i in cameraOffsets) {
			camGame.zoom += i.zoom;
			camTargetX += i.x ?? 0;
			camTargetY += i.y ?? 0;
		}

		camGame.scroll.x = camGame.followLerp == 0 ? camTargetX : lerp(camGame.scroll.x, camTargetX, camGame.followLerp);
		camGame.scroll.y = camGame.followLerp == 0 ? camTargetY : lerp(camGame.scroll.y, camTargetY, camGame.followLerp);

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

		if (health == 0 || Controls.reset) {
			FlxG.switchState(new GameOverState(strumLines.members[1].characters[0]));
		}

		callSongScripts("postUpdate", [elapsed]);
		callSongScripts("onUpdatePost", [elapsed]);
	}

	function onVoidTap(id:Int, strumLine:StrumLine) {
		strumLine.strums.members[id].playStrumAnim('press', ghostTapping);
		if (!ghostTapping) {
			FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
			for (char in strumLine.characters)
				char.playSingAnim(id, true);
			score += Math.round(Scoring.missScore);
			health -= Constants.DEFAULT_HEALTH_LOSS;
		}
	}

	function onNoteHit(note:Note) {
		if (!Conductor.instrumental.playing && note.parent.isComputer) return;
		if (note.wasHit) return;
		final event:NoteHitEvent = runSongEvent("noteHit", new NoteHitEvent(note));
		if (event.cancelled) return;

		note.wasHit = true; note.visible = false;
		generalVocals.resume(); note.parent.vocals.resume();
		if (event.playStrumAnim) note.parentStrum.playStrumAnim('confirm', true);

		if (!event.animCancelled)
			for (char in note.parent.characters)
				char.playSingAnim(note.id, event.animationSuffix);

		if (note.parent.isPlayer) {
			final judgement:Judgement = Scoring.judgeNoteHit(note.time - Conductor.framePosition);
			if (judgement.splash && event.spawnSplash != false) note.parentStrum.spawnSplash(note);
			score += Math.round(judgement.score);
			health += Constants.DEFAULT_HEALTH_GAIN;
			comboGroup.popupRating(judgement.rating, 0);
		} else if (event.spawnSplash == true) // on purpose ***do not touch***
			note.parentStrum.spawnSplash(note);

		if (event.spawnHoldCover)
			note.parentStrum.spawnHoldCover();

		runSongEvent("noteHitPost", event);
	}

	function onNoteMissed(note:Note) {
		if (!Conductor.instrumental.playing && note.parent.isComputer) return;
		if (note.wasMissed) return;
		final event:NoteHitEvent = runSongEvent("noteMissed", new NoteHitEvent(note));
		if (event.cancelled) return;

		misses++;

		note.wasMissed = true; note.alpha *= 0.6;
		generalVocals.pause(); note.parent.vocals.pause();
		FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);

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
	}

	function onSustainHit(sustain:Sustain) {
		if (!Conductor.instrumental.playing && sustain.parent.isComputer) return;
		if (sustain.wasHit && !sustain.parentNote.wasHit) return;
		final event:SustainHitEvent = runSongEvent("sustainHit", new SustainHitEvent(sustain));
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
		}
	}

	function onSustainMissed(sustain:Sustain) {
		if (!Conductor.instrumental.playing && sustain.parent.isComputer) return;
		if (sustain.wasMissed) return;
		// final event:NoteHitEvent = runSongEvent("sustainMissed", new NoteHitEvent(sustain));
		// if (event.cancelled) return;

		sustain.wasMissed = true; sustain.alpha *= 0.6;
		generalVocals.pause(); sustain.parent.vocals.pause();
		FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
		for (sustain in Note.filterTail(sustain.parentNote.tail, true)) {
			sustain.wasMissed = true;
			sustain.alpha *= 0.6;
		}

		for (char in sustain.parent.characters)
			char.playSingAnim(sustain.id, true);

		if (sustain.parent.isPlayer) score += Math.round(Scoring.missScore);
		health -= Constants.DEFAULT_HEALTH_LOSS * (sustain.parent.isPlayer ? 1 : -1);

		sustain.parentStrum.holdCover?.playAnim('end', true);
		if (sustain.parent.isComputer) sustain.parentStrum.holdCover?.animation.finish();
		sustain.parentStrum.holdCover = null;
	}

	var countdownTick = 0;

	function startCountdown():Void {
		countdownTick = 0;
		var event:EventBase = runSongEvent("startCountdown", new EventBase());
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
		var eventName = event.type != null ? [null, "Camera Movement"][event.type] : event.name;
		var scriptEvent:SongEvent = runSongEvent("onEvent", new SongEvent(eventName, event.params));
		if (scriptEvent.cancelled) return;

		switch (eventName) {
			case "Camera Modulo Change":
				camBopInterval = event.params[0] ?? 4;
				camBopOffset = event.params[1] ?? 0;
				camBopAmount = event.params[2] ?? 1;

			case "Camera Position":
				scrollTween?.cancel();
				var x:Float = scriptEvent.params[0];
				var y:Float = scriptEvent.params[1];
				var duration:Float = scriptEvent.params[3];
				var ease:String = scriptEvent.params[4];
				var direction:String = scriptEvent.params[5] ?? 'Out';
				var targetEase = NovaUtils.easeFromString(ease, direction);
				scrollTween = FlxTween.tween(camFollowPoint, { x: x, y: y }, (Conductor.stepLengthMs / 1000) * duration, { ease: targetEase, onUpdate: _->{
					FlxG.camera.snapToTarget();
				}});

			case "Camera Movement":
				scrollTween?.cancel();
				var targetCharacter:Character = strumLines.members[scriptEvent.params[0]].characters[0];
				strumlineTarget = scriptEvent.params[0];
				camFollowPoint.x = targetCharacter.getMidpoint().x + (targetCharacter.cameraOffsets ?? [0, 0])[0];
				camFollowPoint.y = targetCharacter.getMidpoint().y + (targetCharacter.cameraOffsets ?? [0, 0])[1];

			case "Camera Zoom":
				if (scriptEvent.params[0]) {
					var targetCamera = ["camGame" => camGameBase].get(scriptEvent.params[2]);
					var	targetZoom = scriptEvent.params[1];
					var targetDuration = (Conductor.stepLengthMs/1000) * scriptEvent.params[3];
					var targetEase = NovaUtils.easeFromString(scriptEvent.params[4], scriptEvent.params[5] ?? 'Out');
					FlxTween.cancelTweensOf(targetCamera);
					FlxTween.tween(targetCamera, { zoom: targetZoom }, targetDuration, { ease: targetEase });
				}

			case "Play Animation":
				var targetCharacter:Character = strumLines.members[scriptEvent.params[0]].characters[0];
				targetCharacter.canDance = false;
				targetCharacter.isSinging = false;
				targetCharacter.playAnim(scriptEvent.params[1], true);
				targetCharacter.animation.onFinish.addOnce(name -> {
					if (name == scriptEvent.params[1]) {
						targetCharacter.canDance = true;
						targetCharacter.dance(true);
						targetCharacter.animation.finish();
					}
				});
		}


		if (event.name != null) {
			trace('debug:Ran song event named "<yellow>${event.name}<reset>" with parameters "<yellow>${event.params.join(", ")}<reset>"');
		} else if (event.type != null) {
			trace('debug:Ran song event named "<yellow>${[null, "Camera Movement"][event.type]}<reset>" with parameters "<yellow>${event.params.join(", ")}<reset>"');
		}

		// trace('debug:Ran event ');
		// trace('debug:$event');
	}

	function startSong(startDelay:Int = 0):Void {

		if (songStarted) return;

		var event = runSongEvent('startSong', new EventBase());
		event = runSongEvent('songStart', event);

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
		var event:EventBase = runSongEvent("endSong", new EventBase());
		event = runSongEvent("songEnd", event);
		if (event.cancelled) return;
		songEnded = true;
		ScoreUtil.saveSongScore(songData.songName, difficulty, songData.variant, score);
		storyScore += score;
		if (isStoryMode && playlist.length == 0) ScoreUtil.saveLevelScore(curStoryLevel, difficulty, storyScore);
		if (playlist.length == 0 || !isStoryMode) {
			FlxG.switchState(MainMenu.new);
			FlxG.switchState(new FreeplayMenu().build());
		} else {
			hasSeenCutscene = false;
			loadSong(playlist.shift(), difficulty, variation);
		}
	}

	public function pause() {
		var event:EventBase = runSongEvent("pause", new EventBase());
		event = stage.stageScripts.event("pause", event);
		if (!event.cancelled) {
			countdownTimer.active = false;

			FlxTween.globalManager.forEach((tween:FlxTween)->{
				tween.active = false;
			});

			var pauseMenu:PauseMenu = new PauseMenu();
			openSubState(pauseMenu);
		}
	}

	public function callSongScripts(func:String, ?params:Array<Dynamic>):Void {
		HXCHandler.instance.hxcScripts.call(func, params);
		songScripts.call(func, params);
		if (stage != null) stage.stageScripts.call(func, params);
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

	override public function destroy():Void {
		if (recordingMode) ReplaySystem.stopRecording();
		if (recordingMode) ReplaySystem.saveRecording(SONG.id);
		if (playbackMode) ReplaySystem.stopReplay();
		instance = null;
		Conductor.offset = 0;
		super.destroy();
		for (i in SONG.events) i.ran = false;
	}

	public static function loadSong(id:String, difficulty:String = "normal", ?variation:String) {
		PlayState.song = id;
		PlayState.difficulty = difficulty;
		PlayState.variation = variation;
		FlxG.switchState(() -> new PlayState());
	}

}