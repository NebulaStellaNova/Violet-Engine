package backend.audio;

import backend.filesystem.Paths;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.sound.FlxSoundGroup;
import flixel.tweens.FlxTween;

using StringTools;

typedef AudioData = {
	var artist:String;
	var name:String;
	var bpm:Float;
	var signature:Array<Int>;
	var ?offset:Float;
}

typedef BPMChange = {
	var stepTime:Float;
	var songTime:Float;
	var bpm:Float;
	var beatsPM:Int;
	var stepsPB:Int;
}

// rename this if you like
typedef CheckpointTyping = {
	var time:Float;
	var bpm:Float;
	var signature:Array<Int>;
}

/**
 * HEY NEBS, there are certain things in the class left sorta blank for you to figure out how you wanna do certain things. The conductor should work one you iron those things out.
 * @author @rodney528
 */
@:access(flixel.system.frontEnds.SoundFrontEnd.loadHelper)
class Conductor {

	static var initialized:Bool = false;

	public static var curMusic:String = null;

	public static var _onComplete:Void->Void;

	/**
	 * Default/Current AudioData I suppose. - Nebula
	 */
	public static var data(default, null):AudioData = {
		artist: "Kawai Sprite",
		name: "Freaky Menu",
		bpm: 102,
		signature: [4, 4]
	}
	/**
	 * The sound group all conductor audio is tied to.
	 */
	public static var soundGroup(default, null):FlxSoundGroup;
	/**
	 * The audio tied to the conductor.
	 */
	public static var audio(default, null):FlxSound;
	/**
	 * Used to sync up other audio instances to said conductor. Mainly used for vocals in songs.
	 */
	public static var extra(default, null):Array<FlxSound> = [];

	/**
	 * States if the conductor should update the time itself.
	 * Mostly used for when the song time is under or above the audio time length.
	 */
	public static var autoSetTime(get, never):Bool;
	inline static function get_autoSetTime():Bool {
		if (time > 0 && (time < audio.length || audioEnded))
			return false;
		return true;
	}

	/**
	 * States if the conductor audio is playing or not.
	 */
	public static var playing(default, null):Bool = false;

	/**
	 * The conductor's volume level.
	 */
	public static var volume(get, set):Float;
	inline static function get_volume():Float
		return soundGroup.volume;
	inline static function set_volume(value:Float):Float
		return soundGroup.volume = value;

	#if FLX_PITCH
	/**
	 * Set pitch, which also alters the playback speed. Default is 1.
	 */
	public static var pitch(get, set):Float;
	inline static function get_pitch():Float
		return audio == null ? 1 : audio.pitch;
	inline static function set_pitch(value:Float):Float {
		if (audio == null) return 1;
		audio.pitch = value;
		for (sound in extra)
			sound.pitch = audio.pitch;
		return value;
	}
	#end

	// BPM's.
	/**
	 * Starting BPM.
	 */
	public static var startBpm(default, null):Float = 100;
	/**
	 * Previous bpm. (is the `startBpm` on start)
	 */
	public static var prevBpm(default, null):Float = 100;
	/**
	 * The beats per second, bpm for short.
	 */
	public static var bpm(default, null):Float = 100;

	/**
	 * The current step.
	 */
	public static var curStep(default, null):Int = 0;
	/**
	 * The current beat.
	 */
	public static var curBeat(default, null):Int = 0;
	/**
	 * The current measure.
	 */
	public static var curMeasure(default, null):Int = 0;

	/**
	 * The current step, as a float instead.
	 */
	public static var curStepFloat(default, null):Float = 0;
	/**
	 * The current beat, as a float instead.
	 */
	public static var curBeatFloat(get, never):Float;
	inline static function get_curBeatFloat():Float
		return curStepFloat / stepsPerBeat;
	/**
	 * The current measure, as a float instead.
	 */
	public static var curMeasureFloat(get, never):Float;
	inline static function get_curMeasureFloat():Float
		return curBeatFloat / beatsPerMeasure;

	// time signature
	/**
	 * The number of beats per measure.
	 */
	public static var beatsPerMeasure(default, null):Int = 4;
	/**
	 * The number of steps per beat.
	 */
	public static var stepsPerBeat(default, null):Int = 4;

	/**
	 * How long a step is in milliseconds.
	 */
	public static var stepTime(get, never):Float;
	inline static function get_stepTime():Float
		return beatTime / stepsPerBeat;
	/**
	 * How long a beat is in milliseconds.
	 */
	public static var beatTime(get, never):Float;
	inline static function get_beatTime():Float
		return 60 / bpm * 1000;
	/**
	 * How long a measure is in milliseconds.
	 */
	public static var measureTime(get, never):Float;
	inline static function get_measureTime():Float
		return beatTime * beatsPerMeasure;

	/**
	 * Current position of the song in milliseconds.
	 */
	public static var time(default, null):Float = 0;
	/**
	 * Previous time.
	 */
	public static var prevTime(default, null):Float;
	/**
	 * The audio offset.
	 */
	public static var timeOffset(default, null):Float = 0;

	/**
	 * Array of all the BPM changes that will occur.
	 */
	public static var bpmChanges(default, null):Array<BPMChange> = [];

	public static function init():Void {
		if (initialized) return;
		initialized = true;
		soundGroup = new FlxSoundGroup();

		audio = FlxG.sound.list.add(new FlxSound());
		audio.autoDestroy = false;

		FlxG.signals.preUpdate.add(update);
		FlxG.signals.focusGained.add(onFocus);
		FlxG.signals.focusLost.add(onFocusLost);

	}

	static var audioEnded:Bool = false;
	inline static function onCompleteFunc():Void {
		if (_onComplete != null) {
			_onComplete();
			_onComplete = null;
		}
		playing = false;
		audioEnded = true;
	}

	inline static function destroySound(sound:FlxSound):Void {
		if (sound.group != null)
			if (soundGroup.sounds.contains(sound))
				soundGroup.remove(sound);
			else if (sound.group.sounds.contains(sound))
				sound.group.remove(sound);
		sound.destroy();
	}


	/**
	 * Y'know, do the thing.
	 */
	inline public static function playMusic(path:String, forced:Bool = false):Void {
		var splitPath = path.split("/");
		var fileName = splitPath[splitPath.length-1];
		if (curMusic == fileName && !forced) return;
		curMusic = fileName;
		trace(fileName);
		if (Paths.fileExists(path + ".ogg")) {
			loadMusic('$path.ogg');
			play();
		} else if (Paths.folderExists(path)) {
			loadMusic('$path/$fileName.ogg');
			play();
		}
	}

	/**
	 * An internal function for playing the conductor audio.
	 */
	inline static function _play():Void {
		audioEnded = false;
		if (!autoSetTime)
			for (sound in soundGroup.sounds)
				sound.play(time);
		playing = true;
		resyncVocals();
	}
	/**
	 * Play's the conductor audio from a specified time of your choosing.
	 * @param startTime The song starting time.
	 * @param startVolume The song starting volume.
	 */
	inline public static function playFromTime(startTime:Float = 0, startVolume:Float = 1):Void {
		time = startTime;
		play(startVolume);
	}
	/**
	 * Play's the conductor audio.
	 * @param startVolume The song starting volume.
	 */
	inline public static function play(startVolume:Float = 1):Void {
		volume = startVolume;
		_play();
	}

	/**
	 * Pause's the conductor audio.
	 */
	inline public static function pause():Void {
		soundGroup.pause();
		playing = false;
	}

	/**
	 * Resume's the conductor audio.
	 */
	inline public static function resume():Void {
		if (!autoSetTime)
			soundGroup.resume();
		playing = true;
		resyncVocals(true);
	}

	/**
	 * Stop's the conductor audio.
	 */
	inline public static function stop():Void {
		for (sound in soundGroup.sounds)
			sound.stop();
		playing = false;
	}

	/**
	 * Reset's the conductor.
	 */
	public static function reset():Void {
		stop();
		for (sound in extra)
			destroySound(sound);
		extra = [];

		prevTime = time = curStepFloat = curStep = curBeat = curMeasure = 0;
		bpmChanges = [];
		changeBPM();
		startBpm = prevBpm = bpm;
	}

	/**
	 * Pulled the fade code from FlxSound, lmao.
	 */
	static var fadeTween:FlxTween;
	/**
	 * Fades in the conductor audio.
	 * Note: Always starts from 0.
	 * @param duration The amount of time the fade in should take.
	 * @param to The value to tween to.
	 */
	inline public static function fadeIn(duration:Float = 1, to:Float = 1, ?onComplete:FlxTween->Void):Void {
		if (!playing)
			play();

		stopFade();
		fadeTween = FlxTween.num(0, to, duration, {onComplete: onComplete}, (value:Float) -> volume = value);
	}
	/**
	 * Fades out the conductor audio.
	 * @param duration The amount of time the fade out should take.
	 * @param to The value to tween to.
	 */
	inline public static function fadeOut(duration:Float = 1, to:Float = 0, ?onComplete:FlxTween->Void):Void {
		stopFade();
		fadeTween = FlxTween.num(volume, to, duration, {onComplete: onComplete}, (value:Float) -> volume = value);
	}
	/**
	 * Stops the fade tween dead in it's tracks.
	 * @param returnValue Do you wish to have the conductor volume return to a different value?
	 */
	inline public static function stopFade(?returnValue:Float):Void {
		if (fadeTween != null)
			fadeTween.cancel();
		if (returnValue != null)
			volume = returnValue;
	}

	/**
	 * Sets the music it should play.
	 * @param music The name of the audio file.
	 * @param afterLoad Function that runs after the audio has loaded.
	 */
	public static function loadMusic(music:String, ?afterLoad:FlxSound->Void):Void {
		reset();
		if (audio == null)
			audio = FlxG.sound.list.add(new FlxSound());

		audio.loadEmbedded(music);
		FlxG.sound.loadHelper(audio, 1, soundGroup);
		audio.persist = true;

		if (Paths.fileExists(music.replace(".ogg", ".json"))) {
			try {
				data = Paths.parseJson(music.replace(".ogg", ".json"));
			} catch (e:Dynamic) {
				// do nothing
			}
		}

		applyBPMChanges();

		#if FLX_PITCH pitch = pitch; #end
		if (afterLoad != null)
			afterLoad(audio);

	}

	/**
	 * Sets the song inst it should play.
	 * @param song The name of the song.
	 * @param variant The variant of the song to play.
	 * @param afterLoad Function that runs after the audio has loaded.
	 */
	public static function loadSong(song:String, variant:String = '', ?afterLoad:FlxSound->Void):Void {
		if (curMusic == song + (variant != '' ? '-$variant' : '')) return;
		curMusic = song + (variant != '' ? '-$variant' : '');
		reset();
		if (audio == null)
			audio = FlxG.sound.list.add(new FlxSound());

		audio.loadEmbedded('assets/songs/$song/song/${variant != '' ? '$variant/' : ''}Inst.ogg');
		FlxG.sound.loadHelper(audio, 1, soundGroup);
		audio.persist = true;

		applyBPMChanges();

		#if FLX_PITCH pitch = pitch; #end
		if (afterLoad != null)
			afterLoad(audio);
	}

	/**
	 * Adds an extra music track to run.
	 * @param music The name of the audio file.
	 * @param afterLoad Function that runs after the audio has loaded.
	 * @return `FlxSound` ~ Added audio track.
	 */
	public static function addExtraAudio(music:String, ?afterLoad:FlxSound->Void):FlxSound {
		var file:String = '';//Paths.music(music);
		// if (!Paths.fileExists(file)) {
		// 	log('Failed to find audio "${music.format()}".', WarningMessage);
		// 	return null;
		// }
		var music:FlxSound = FlxG.sound.list.add(new FlxSound());

		// music.loadEmbedded(Assets.music(file));
		FlxG.sound.loadHelper(music, 1, soundGroup);
		music.persist = true;

		#if FLX_PITCH music.pitch = pitch; #end
		extra.push(music);
		if (afterLoad != null)
			afterLoad(music);
		return music;
	}

	/**
	 * Adds a vocal track to run, used for songs.
	 * @param song The name of the song.
	 * @param suffix The vocal suffix.
	 * @param variant The variant of the vocals to play.
	 * @param afterLoad Function that runs after the audio has loaded.
	 * @return `FlxSound` ~ Added vocal track.
	 */
	public static function addVocalTrack(song:String, suffix:String = '', variant:String = '', ?afterLoad:FlxSound->Void):FlxSound {
		var file:String = Paths.vocal(song, suffix, variant);
		if (!Paths.fileExists(file)) {
			//log('Failed to find ${suffix.isNullOrEmpty() ? 'base ' : ''}vocal track for song "$song"${variant == 'normal' ? '' : ', variant "$variant"'}${suffix.isNullOrEmpty() ? '' : ' with a suffix of "$suffix"'}.', WarningMessage);
			return null;
		}
		var vocals:FlxSound = FlxG.sound.list.add(new FlxSound());

		vocals.loadEmbedded(Paths.vocal(song, suffix, variant));
		FlxG.sound.loadHelper(vocals, 1, soundGroup);
		vocals.persist = true;

		#if FLX_PITCH vocals.pitch = pitch; #end
		extra.push(vocals);
		if (afterLoad != null)
			afterLoad(vocals);
		return vocals;
	}

	static var _printResyncMessage(null, null):Bool = false;
	/**
	 * Resync's the extra tracks to the inst time when called.
	 * @param force If true, it will force the vocals to resync.
	 */
	inline public static function resyncVocals(force:Bool = false):Void {
		if ((force || !playing) && !autoSetTime) return;
		_printResyncMessage = false;
		for (sound in soundGroup.sounds) {
			// idea from psych
			if (audio.time < sound.length) {
				if (force || Math.abs(time - sound.time) > 25) {
					sound.pause();
					sound.time = time;
					sound.play();
					_printResyncMessage = true;
				}
			} else if (sound.playing)
				sound.pause();
		}
		if (_printResyncMessage)
			trace(force ? 'Manually resynced Conductor.' : 'Conductor resynced all tracks to it\'s time.');
	}

	public static function update():Void {
		if (!playing)
			return;

		if (audio == null) {
			prevTime = audio == null ? 0 : (audio.playing ? audio.time : time);
			return;
		} else { // jic
			if (audio.onComplete != onCompleteFunc)
				audio.onComplete = onCompleteFunc;
		}

		if (!audio.playing && !autoSetTime)
			audio.play();
		if (audio.playing && autoSetTime)
			audio.pause();

		if (audio.playing && !audioEnded) {
			if (prevTime != (prevTime = audio.time))
				time = prevTime; // update conductor
			else time += FlxG.elapsed * 1000;
			resyncVocals();
		} else time += FlxG.elapsed * 1000;

		if (bpm > 0 || beatsPerMeasure > 0 || stepsPerBeat > 0) {
			var lastChange:BPMChange = {
				stepTime: 0,
				songTime: 0,
				bpm: 0,
				beatsPM: 0,
				stepsPB: 0
			}
			for (change in bpmChanges)
				if (time >= change.songTime)
					lastChange = change;

			if (
				(lastChange.bpm > 0 && bpm != lastChange.bpm) /* ||
				(lastChange.beatsPM > 0 && beatsPerMeasure != lastChange.beatsPM) ||
				(lastChange.stepsPB > 0 && stepsPerBeat != lastChange.stepsPB) */
			) changeBPM(lastChange.bpm);

			// beat and measure versions update automatically
			curStepFloat = lastChange.stepTime + ((time - lastChange.songTime) / stepTime);

			// update step
			if (curStep != (curStep = Math.floor(curStepFloat))) {
				var oldStep:Int = curStep;
				var oldBeat:Int = curBeat;
				var oldMeasure:Int = curMeasure;
				if (curStep < oldStep && oldStep - curStep < 2)
					return;

				// update beat and measure
				var updateBeat:Bool = curBeat != (curBeat = Math.floor(curBeatFloat));
				var updateMeasure:Bool = updateBeat && (curMeasure != (curMeasure = Math.floor(curMeasureFloat)));

				if (curStep > oldStep)
					for (i in oldStep...curStep)
						stepHit(i + 1);
				if (updateBeat && curBeat > oldBeat)
					for (i in oldBeat...curBeat)
						beatHit(i + 1);
				if (updateMeasure && curMeasure > oldMeasure)
					for (i in oldMeasure...curMeasure)
						measureHit(i + 1);
			}
		}
	}

	static var _wasPlaying(null, null):Bool = false;
	inline static function onFocus():Void {
		if (FlxG.autoPause) {
			playing = _wasPlaying;
			if (_wasPlaying)
				soundGroup.resume();
		}
	}
	inline static function onFocusLost():Void {
		if (FlxG.autoPause) {
			_wasPlaying = playing;
			soundGroup.pause();
		}
	}

	/**
	 * Runs when the next step happens.
	 * @param curStep The current step.
	 */
	inline public static function stepHit(curStep:Int):Void {
		// cast (FlxG.state, MusicBeatState).stepHit(curStep);
	}
	/**
	 * Runs when the next beat happens.
	 * @param curBeat The current beat.
	 */
	inline public static function beatHit(curBeat:Int):Void {
		// cast (FlxG.state, MusicBeatState).beatHit(curBeat);
	}
	/**
	 * Runs when the next measure happens.
	 * @param curMeasure The current measure.
	 */
	inline public static function measureHit(curMeasure:Int):Void {
		//
	}

	/**
	 * Changes the current BPM of this part of the song.
	 * @param bpm New "beats per minute" number.
	 * @param beatsPerMeasure New "beats per measure" number.
	 * @param stepsPerBeat New "steps per beat" number.
	 */
	inline public static function changeBPM(bpm:Float = 100, beatsPerMeasure:Int = 4, stepsPerBeat:Int = 4):Void {
		prevBpm = Conductor.bpm;

		Conductor.bpm = bpm;
		Conductor.beatsPerMeasure = beatsPerMeasure;
		Conductor.stepsPerBeat = stepsPerBeat;
	}

	/**
	 * Renders any bpm change that happen throughout the song.
	 */
	public static function applyBPMChanges():Void {
		bpmChanges = [
			{
				stepTime: 0,
				songTime: 0,
				bpm: data.bpm,
				beatsPM: data.signature[0],
				stepsPB: data.signature[1]
			}
		];
		changeBPM(startBpm = prevBpm = data.bpm, data.signature[0], data.signature[1]);
	}
}