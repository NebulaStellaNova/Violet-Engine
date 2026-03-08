package violet.states;

import violet.backend.objects.play.ScoreTxt;
import violet.backend.objects.play.HealthIcon;
import violet.data.Constants;
import flixel.math.FlxMath;
import violet.backend.utils.MathUtil;
import violet.backend.objects.play.HealthBar;
import violet.data.Scoring;
import violet.data.Scoring.Judgement;
import violet.data.chart.ChartData.ChartEvent;
import violet.data.stage.Stage;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import violet.backend.audio.Conductor;
import violet.backend.objects.play.Note;
import violet.backend.objects.play.StrumLine;
import violet.backend.objects.play.Sustain;
import violet.data.character.Character;
import violet.data.chart.Chart;
import violet.data.chart.ChartRegistry;

#if SCRIPT_SUPPORT
import violet.backend.scripting.ScriptPack;
#end

typedef CountdownAssets = {
	/**
	 * Countdown images.
	 */
	var images:Array<String>;
	/**
	 * Countdown sounds.
	 */
	var sounds:Array<String>;
}

class PlayState extends violet.backend.StateBackend {

	public static var instance:PlayState;
	public static var SONG:Chart;
	public static var song:String;
	public static var difficulty:String;
	public static var variation:Null<String>;

	#if SCRIPT_SUPPORT
	public var songScripts:ScriptPack = new ScriptPack();
	#end

	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var stage:Stage;
	public var characters:Array<Character> = [];

	public var strumLines:FlxTypedGroup<StrumLine>;
	public var generalVocals:FlxSound;

	public var defaultCamZoom:Float = 0.7;

	public var score:Int = 0;
	public var healthBar:HealthBar;
	public var health:Float;

	public var iconPlayer:HealthIcon;
	public var iconOpponent:HealthIcon;

	public var scoreTxt:ScoreTxt;

	/**
	 * The amount of beats the countdown lasts for.
	 */
	public var countdownLength(default, set):Int = 4;
	inline function set_countdownLength(value:Int):Int
		return countdownLength = Std.int(Math.max(value, 1));
	/**
	 * This timer that tracks the countdown steps.
	 */
	public final countdownTimer:FlxTimer = new FlxTimer();
	/**
	 * The assets what will be used in the countdown.
	 */
	public var countdownAssets:CountdownAssets;
	/**
	 * Sets up the listings for the countdownAssets variable.
	 * @param root The path to the assets.
	 * @param parts List of assets to get from root var path.
	 * @param suffix Adds a suffix to each item of the parts array.
	 * @return Array<String> ~ The mod paths of the items.
	 */
	inline public static function getCountdownAssetList(root:String = 'countdown/funkin', parts:Array<String>, ?suffix:String):Array<String> {
		return [
			for (part in parts) {
				final asset:String = part == null ? null : '${haxe.io.Path.addTrailingSlash(root)}$part${flixel.util.FlxStringUtil.isNullOrEmpty(suffix) ? '' : '-$suffix'}';
				// attempts to cache the asset, I don't feel like adding a bool to specify this shit
				if (Paths.fileExists(Paths.image(asset), true)) Cache.image(asset);
				if (Paths.fileExists(Paths.sound(asset), true)) Cache.sound(asset);
				asset;
			}
		];
	}

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

		FlxG.cameras.reset(camGame = new FlxCamera());
		camHUD = new FlxCamera();
		camHUD.bgColor = FlxColor.TRANSPARENT;
		FlxG.cameras.add(camHUD, false);

		#if SCRIPT_SUPPORT
		songScripts.parent = this;
		final scriptPaths:Array<String> = ['$song/scripts', '$song/scripts/$difficulty'];
		if (variation != null) scriptPaths.push('$song/scripts/$variation');
		for (path in scriptPaths) {
			for (folder in Paths.readFolder(path)) {
				checkForScripts([Paths.ASSETS_FOLDER, haxe.io.Path.withoutExtension(folder)].join("/"), songScripts);
				#if MOD_SUPPORT
				for (mod in ModdingAPI.getActiveMods())
					checkForScripts([ModdingAPI.MOD_FOLDER, mod.folder, haxe.io.Path.withoutExtension(folder)].join("/"), songScripts);
				#end
			}
		}
		#end

		strumLines = new FlxTypedGroup<StrumLine>();

		SONG = ChartRegistry.getChart(song, difficulty, variation);
		Conductor.playSong(song, variation); Conductor.pause();
		if (SONG.meta.needsVoices) generalVocals = Conductor.addAdditionalTrack(FlxG.sound.load(Cache.sound(Paths.vocal(PlayState.song, null, PlayState.variation), 'root', null, true), FlxG.sound.defaultMusicGroup));
		else generalVocals = Conductor.addAdditionalTrack(new FlxSound());
		StrumLine.generalScrollSpeed = SONG.scrollSpeed ?? 1;
		for (i => data in SONG.strumLines) {
			if (data == null) continue;

			/* var chars = [];
			var charPosName:String = data.position == null ? (switch(data.type) {
				case 0: "dad";
				case 1: "boyfriend";
				case 2: "girlfriend";
			}) : data.position;
			if (data.characters != null) for(k=>charName in data.characters) {
				var char = new Character(0, 0, charName, stage.isCharFlipped(stage.characterPoses[charName] != null ? charName : charPosName, strumLine.type == 1));
				stage.applyCharStuff(char, charPosName, k);
				chars.push(char);
			} */

			var strumLine = new StrumLine(data);
			strumLine.cameras = [camHUD];
			strumLine.visible = data.visible;
			strumLine.ID = i;
			// strumLine.y -= 50;
			strumLines.add(strumLine);

			for(i=>charName in data.characters) {
				var char = new Character(i * 50, 0, charName, i == 1);
				char.alpha = 0.5;
				char.stagePosition = data.charStagePosition;
				if (data.charStagePosition == "boyfriend" && iconPlayer == null) {
					iconPlayer = new HealthIcon(char._data.healthIcon);
					iconPlayer.flipX = !iconPlayer.flipX;
				} else if (data.charStagePosition == "dad" && iconOpponent == null) {
					iconOpponent = new HealthIcon(char._data.healthIcon);
				}
				strumLine.characters.push(char);
				characters.push(char);
				// add(char);
			}

			// note interactions
			final ghostTapping:Bool = true;
			strumLine._onVoidTap = (id:Int) -> {
				if (!ghostTapping) FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
				strumLine.strums.members[id].playStrumAnim('press', ghostTapping);
			}
			strumLine._onNoteHit = (note:Note) -> {
				if (note.wasHit) return;
				note.wasHit = true;
				note.visible = false;
				generalVocals.resume(); strumLine.vocals.resume();
				note.parentStrum.playStrumAnim('confirm', true);
				for (char in note.parent.characters)
					char.playSingAnim(note.id);

				if (note.parent.isPlayer) {
					var judgement:Judgement = Scoring.judgeNoteHit(note.time - Conductor.songPosition);
					if (judgement.rating == "sick" || judgement.rating == "killer") note.parentStrum.spawnSplash();
					score += Math.round(judgement.score);
					health += Constants.DEFAULT_HEALTH_GAIN;
				}

			}
			strumLine._onSustainHit = (sustain:Sustain) -> {
				if (sustain.wasHit && !sustain.parentNote.wasHit) return;
				sustain.wasHit = true;
				// sustain.visible = false;
				generalVocals.resume(); strumLine.vocals.resume();
				sustain.parentStrum.playStrumAnim('confirm', true);
				for (char in sustain.parent.characters)
					char.playSingAnim(sustain.id);
				if (strumLine.isPlayer)
					health += Constants.DEFAULT_HEALTH_GAIN;
			}
			strumLine._onNoteMissed = (note:Note) -> {
				if (note.wasMissed) return;
				note.wasMissed = true;
				note.alpha *= 0.6;
				FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
				generalVocals.pause(); strumLine.vocals.pause();
				for (sustain in Note.filterTail(note.tail, true)) {
					sustain.wasMissed = true;
					sustain.alpha *= 0.6;
				}
				for (char in note.parent.characters)
					char.playSingAnim(note.id, true);

				health -= Constants.DEFAULT_HEALTH_LOSS;
			}
			strumLine._onSustainMissed = (sustain:Sustain) -> {
				if (sustain.wasMissed) return;
				sustain.wasMissed = true;
				sustain.alpha *= 0.6;
				FlxG.sound.play(Cache.sound('miss/${FlxG.random.int(1, 3)}'), 0.7);
				generalVocals.pause(); strumLine.vocals.pause();
				for (sustain in Note.filterTail(sustain.parentNote.tail, true)) {
					sustain.wasMissed = true;
					sustain.alpha *= 0.6;
				}
				for (char in sustain.parent.characters)
					char.playSingAnim(sustain.id, true);
			}
		}
		add(strumLines);
		Conductor.onComplete = endSong;

		stage = new Stage(SONG.stage);
		defaultCamZoom = stage._data.zoom;
		camGame.zoom = defaultCamZoom;

		healthBar = new HealthBar();
		healthBar.y = /* isDownscroll ? FlxG.height * 0.1 :  */FlxG.height * 0.9;
		healthBar.screenCenter(X);
		healthBar.camera = camHUD;
		healthBar.leftColor = FlxColor.RED;
		healthBar.rightColor = FlxColor.LIME;
		add(healthBar);

		scoreTxt = new ScoreTxt();
		scoreTxt.x = healthBar.x + healthBar.width - scoreTxt.width;
		scoreTxt.y = healthBar.y + healthBar.height + 5;
		scoreTxt.camera = camHUD;
		add(scoreTxt);

		iconPlayer.camera = camHUD;
		add(iconPlayer);

		iconOpponent.camera = camHUD;
		add(iconOpponent);

		health = 0.75; // when I set it to 0.5, it MAGICALLY gets set to 0.25 and idk why

		countdownAssets = {
			images: getCountdownAssetList([null, 'ready', 'set', 'go']),
			sounds: getCountdownAssetList(['introTHREE', 'introTWO', 'introONE', 'introGO'])
		}

		callSongScripts('create');

		// startCountdown();
		startSong();

		for (strumLine in strumLines)
			strumLine.generateNotes(Conductor.songPosition);

		callSongScripts('postCreate');
	}

	var healthLerp:Float = 0.5;
	var scoreLerp:Float = 0;

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		scoreLerp = MathUtil.lerp(scoreLerp, score, 0.1);
		scoreTxt.value = Math.round(scoreLerp);

		health = FlxMath.bound(health, 0, 1);

		healthLerp = MathUtil.lerp(healthLerp, health, 0.1);
		healthBar.position = healthLerp;

		iconPlayer.scale.x = iconPlayer.scale.y = MathUtil.lerp(iconPlayer.scale.y, iconPlayer._data.scale, 0.2);
		iconOpponent.scale.x = iconOpponent.scale.y = MathUtil.lerp(iconOpponent.scale.y, iconOpponent._data.scale, 0.2);
		iconPlayer.updateHitbox();
		iconOpponent.updateHitbox();

		iconPlayer.x = healthBar.x + healthBar.defaultWidth * (1-healthLerp);
		iconPlayer.y = healthBar.y + (healthBar.height/2) - (iconPlayer.height/2);

		iconOpponent.x = healthBar.x + healthBar.defaultWidth * (1-healthLerp) - iconOpponent.width;
		iconOpponent.y = healthBar.y + (healthBar.height/2) - (iconOpponent.height/2);

		for (i in SONG.events) {
			if (i.time <= Conductor.songPosition) {
				handleEvent(i);
			}
		}
	}

	function startCountdown(?saidAssets:CountdownAssets):Void {
		saidAssets ??= countdownAssets;
		final assets:CountdownAssets = {
			images: saidAssets.images.copy(),
			sounds: saidAssets.sounds.copy()
		}
		assets.images.reverse();
		assets.sounds.reverse();

		countdownStarted = true;
		if (countdownLength >= 1) {
			countdownTimer.start(Conductor.beatLengthMs / 1000, timer -> {
				if (!songStarted)
					startSong(countdownLength);

				final assetIndex:Int = timer.loopsLeft - 1;

				final soundAsset:String = assets.sounds[assetIndex];
				if (Paths.fileExists(Paths.sound(soundAsset), true))
					FlxG.sound.play(Cache.sound(soundAsset));

				final imageAsset:String = assets.images[assetIndex];
				if (Paths.fileExists(Paths.image(imageAsset), true)) {
					final sprite:NovaSprite = new NovaSprite(imageAsset);
					sprite.cameras = [camHUD];
					sprite.screenCenter();
					add(sprite);

					FlxTween.tween(sprite, {alpha: 0}, Conductor.beatLengthMs / 1.2 / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: tween ->
							sprite.destroy()
					});
				}
			}, countdownLength + 1);
		}
	}


	function handleEvent(event:ChartEvent) {
		if (event.ran) return;
		event.ran = true;

		switch (event.type) {
			case 1:
				var targetCharacter:Character = strumLines.members[event.params[0]].characters[0];
				FlxTween.cancelTweensOf(camGame.scroll);
				FlxTween.tween(camGame.scroll, {
					x: targetCharacter.x + targetCharacter.cameraOffsets[0],
					y: targetCharacter.y + targetCharacter.cameraOffsets[1]
				}, 0.75, { ease: FlxEase.quartOut });
		}


		if (event.name != null) {
			trace('debug:Ran song event named "${event.name}" with parameters "${event.params.join(", ")}"');
		} else if (event.type != null) {
			trace('debug:Ran song event named "${[null, "Camera Movement"][event.type]}" with parameters "${event.params.join(", ")}"');
		}

		// trace('debug:Ran event ');
		// trace('debug:$event');
	}

	function startSong(startDelay:Int = 0):Void {
		songStarted = true;
		Conductor.play(true, -Conductor.beatLengthMs * Math.abs(startDelay));
	}

	function endSong():Void {
		songEnded = true;
		FlxG.switchState(violet.states.menus.MainMenu.new);
	}

	public function callSongScripts<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		return #if SCRIPT_SUPPORT songScripts.call(funcName, args, def) ?? #end def;
	}

	public function runSongEvent<T:violet.backend.scripting.events.EventBase>(func:String, event:T):T {
		#if SCRIPT_SUPPORT
		if (songScripts == null) return event;
		return songScripts.event(func, event);
		#else
		return event;
		#end
	}

	override function beatHit(curBeat:Int) {
		super.beatHit(curBeat);

		iconOpponent.scale.x = iconOpponent.scale.y = iconOpponent._data.scale * 1.2;
		iconPlayer.scale.x = iconPlayer.scale.y = iconPlayer._data.scale * 1.2;

		if (curBeat % 4 == 0) {
			FlxTween.cancelTweensOf(camGame);
			camGame.zoom = defaultCamZoom + 0.025;
			camHUD.zoom = 1 + 0.035;
			FlxTween.tween(camGame, { zoom: defaultCamZoom }, 1, { ease: FlxEase.quartOut });
			FlxTween.tween(camHUD, { zoom: 1 }, 1, { ease: FlxEase.quartOut });
		}
	}



	override public function destroy():Void {
		instance = null;
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