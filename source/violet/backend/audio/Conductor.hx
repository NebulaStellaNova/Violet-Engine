package violet.backend.audio;

import flixel.addons.sound.FlxRhythmConductor;
import flixel.addons.sound.MusicTimeChangeEvent;
import violet.backend.utils.NovaUtils;

using StringTools;
using flixel.addons.sound.FlxRhythmConductorUtil;

class Conductor {

	/**
	 * The current song position in steps.
	 */
	public static var curStep(get, never):Int;
	static function get_curStep():Int return FlxRhythmConductor.instance.currentStep;
	/**
	 * The precise song position in steps.
	 */
	public static var curStepFloat(get, never):Float;
	static function get_curStepFloat():Float return FlxRhythmConductor.instance.currentStepTime;

	/**
	 * The current song position in beats.
	 */
	public static var curBeat(get, never):Int;
	static function get_curBeat():Int return FlxRhythmConductor.instance.currentBeat;
	/**
	 * The precise song position in beats.
	 */
	public static var curBeatFloat(get, never):Float;
	static function get_curBeatFloat():Float return FlxRhythmConductor.instance.currentBeatTime;

	/**
	 * The current song position in measures.
	 */
	public static var curMeasure(get, never):Int;
	static function get_curMeasure():Int return FlxRhythmConductor.instance.currentMeasure;
	/**
	 * The precise song position in measures.
	 */
	public static var curMeasureFloat(get, never):Float;
	static function get_curMeasureFloat():Float return FlxRhythmConductor.instance.currentMeasureTime;

	/**
	 * The current song position in milliseconds.
	 */
	public static var songPosition(get, never):Float;
	static function get_songPosition():Float return FlxRhythmConductor.instance.musicPosition;
	/**
	 * Same as songPosition, but for timing stuff other than audio tracks.
	 */
	public static var framePosition(get, never):Float;
	static function get_framePosition():Float return FlxRhythmConductor.instance.frameMusicPosition;

	/**
	 * The current BPM of the song.
	 */
	public static var currentBpm(get, never):Float;
	static function get_currentBpm():Float return FlxRhythmConductor.instance.currentBpm;

	/**
	 * The number of steps per measure.
	 */
	public static var stepsPerMeasure(get, never):Float;
	static function get_stepsPerMeasure():Float return FlxRhythmConductor.instance.stepsPerMeasure;
	/**
	 * The number of beats per measure.
	 */
	public static var beatsPerMeasure(get, never):Float;
	static function get_beatsPerMeasure():Float return FlxRhythmConductor.instance.beatsPerMeasure;

	/**
	 * The length of a step in milliseconds.
	 */
	public static var stepLengthMs(get, never):Float;
	static function get_stepLengthMs():Float return FlxRhythmConductor.instance.stepLengthMs;
	/**
	 * The length of a beat in milliseconds.
	 */
	public static var beatLengthMs(get, never):Float;
	static function get_beatLengthMs():Float return FlxRhythmConductor.instance.beatLengthMs;
	/**
	 * The length of a measure in milliseconds.
	 */
	public static var measureLengthMs(get, never):Float;
	static function get_measureLengthMs():Float return FlxRhythmConductor.instance.measureLengthMs;

	public static var onComplete:Void->Void;
	static function _onComplete():Void {
		Conductor.pause();
		if (onComplete != null)
			onComplete();
		onComplete = null;
	}

	/**
	 * The instrumental track of the song.
	 */
	public static var instrumental(get, never):FlxSound;
	static function get_instrumental():FlxSound {
		if (FlxRhythmConductor.instance.target != null)
			FlxRhythmConductor.instance.target.onComplete = _onComplete;
		return FlxRhythmConductor.instance.target;
	}
	/**
	 * Additional tracks of the song.
	 */
	public static final additionalTracks:Array<FlxSound> = [];
	public static function addAdditionalTrack(track:FlxSound):FlxSound {
		if (track == null) return new FlxSound();
		track.persist = instrumental.persist;
		additionalTracks.push(track);
		return track;
	}

	static var initialized:Bool = false;
	public static function init():Void {
		if (initialized) return;
		resetConductor();
		initCallbacks();
		initialized = true;
	}

	public static function resetConductor():Void {
		for (track in additionalTracks) {
			track.stop();
			track.destroy();
		}
		additionalTracks.resize(0);
		FlxRhythmConductor.reset();
		FlxRhythmConductor.instance.connectWatch(true);
	}

	public static function initCallbacks():Void {
		FlxRhythmConductor.instance.onStepHit.add((step:Int, backward:Bool) -> StateBackend.instance.stepHit(step));
		FlxRhythmConductor.instance.onBeatHit.add((beat:Int, backward:Bool) -> StateBackend.instance.beatHit(beat));
		FlxRhythmConductor.instance.onMeasureHit.add((measure:Int, backward:Bool) -> StateBackend.instance.measureHit(measure));
	}
	public static function initCallbacksSubState():Void {
		FlxRhythmConductor.instance.onStepHit.add((step:Int, backward:Bool) -> if (SubStateBackend.instance != null) SubStateBackend.instance.stepHit(step));
		FlxRhythmConductor.instance.onBeatHit.add((beat:Int, backward:Bool) -> if (SubStateBackend.instance != null) SubStateBackend.instance.beatHit(beat));
		FlxRhythmConductor.instance.onMeasureHit.add((measure:Int, backward:Bool) -> if (SubStateBackend.instance != null) SubStateBackend.instance.measureHit(measure));
	}

	public static function setInitialBPM(bpm:Float, tsn:Int = 4, tsd:Int = 4):Void {
		FlxRhythmConductor.instance.loadMeta([new MusicTimeChangeEvent(0, bpm, tsn, tsd)]);
	}

	public static function pause():Void {
		instrumental?.pause();
		for (track in additionalTracks)
			track?.pause();
	}
	public static function play(forceRestart:Bool = false, startTime:Float = 0.0):Void {
		instrumental.play(forceRestart, startTime);
		for (track in additionalTracks)
			track.play(forceRestart, startTime);
	}

	public static function update():Void {
		FlxRhythmConductor.instance.update(null);
		for (track in additionalTracks)
			if (!instrumental.playing)
				track.pause();
			// setting the volume variable was NOT working so we doing pause and resume
			else if (track.playing && instrumental.time < track.length) {
				if (Math.abs(songPosition - track.time) > 5)
					track.time = songPosition;
			} else if (track.playing)
				track.pause();
	}

	public static function playSong(id:String, ?variation:String, threaded:Bool = false):Void {
		inline function result() {
			NovaUtils.playMusic('$id/song/Inst${variation == '' ? '' : '-$variation'}', 'songs');
			final songMetaData = violet.data.song.SongRegistry.getSongByID(id);
			Conductor.setInitialBPM(songMetaData.bpm, songMetaData.stepsPerBeat, songMetaData.beatsPerMeasure);
			instrumental.looped = false;
		}
		/* if (threaded)
			Main.threadCallacks.addOnce(() -> result());
		else */ result();
	}

	public static function stop() {
		instrumental.stop();
		for (i in additionalTracks) {
			i.stop();
		}
	}

}