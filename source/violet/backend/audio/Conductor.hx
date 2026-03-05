package violet.backend.audio;

import violet.backend.utils.NovaUtils;
import flixel.addons.sound.FlxRhythmConductor;
import flixel.addons.sound.MusicTimeChangeEvent;

using flixel.addons.sound.FlxRhythmConductorUtil;


using StringTools;

class Conductor {

	public static var curBeat(get, never):Int;
	static function get_curBeat() return FlxRhythmConductor.instance.currentBeat;

	public static var curBeatFloat(get, never):Float;
	static function get_curBeatFloat() return FlxRhythmConductor.instance.currentBeatTime;

	public static var curStep(get, never):Int;
	static function get_curStep() return FlxRhythmConductor.instance.currentStep;

	public static var curStepFloat(get, never):Float;
	static function get_curStepFloat() return FlxRhythmConductor.instance.currentStepTime;

	public static var curMeasure(get, never):Int;
	static function get_curMeasure() return FlxRhythmConductor.instance.currentMeasure;

	public static var curMeasureFloat(get, never):Float;
	static function get_curMeasureFloat() return FlxRhythmConductor.instance.currentMeasureTime;

	public static var songPosition(get, never):Float;
	static function get_songPosition() return FlxRhythmConductor.instance.musicPosition;

	public static var BPM(get, never):Float;
	static function get_BPM() return FlxRhythmConductor.instance.currentBpm;

	public static var stepsPerMeasure(get, never):Float;
	static function get_stepsPerMeasure() return FlxRhythmConductor.instance.stepsPerMeasure;

	public static var beatsPerMeasure(get, never):Float;
	static function get_beatsPerMeasure() return FlxRhythmConductor.instance.beatsPerMeasure;

	public static var stepLengthMs(get, never):Float;
	static function get_stepLengthMs() return FlxRhythmConductor.instance.stepLengthMs;


	public static var initialized:Bool = false;

	public static var vocalTracks:Array<FlxSound> = [];

	public static function init():Void {
		if (initialized) return;
		resetConductor();
		initCallbacks();
		initialized = true;
	}

	public static function resetConductor() {
		FlxRhythmConductor.reset();
		FlxRhythmConductor.instance.connectWatch(true);
	}

	public static function initCallbacks() {
		FlxRhythmConductor.instance.onBeatHit.add((beat:Int, backward:Bool) -> { StateBackend.instance.beatHit(beat); });
		FlxRhythmConductor.instance.onStepHit.add((step:Int, backward:Bool) -> { StateBackend.instance.stepHit(step); });
		FlxRhythmConductor.instance.onMeasureHit.add((measure:Int, backward:Bool) -> { StateBackend.instance.measureHit(measure); });
	}

	public static function initCallbacksSubState() {
		FlxRhythmConductor.instance.onBeatHit.add((beat:Int, backward:Bool) -> { if (SubStateBackend.instance != null) SubStateBackend.instance.beatHit(beat); });
		FlxRhythmConductor.instance.onStepHit.add((step:Int, backward:Bool) -> { if (SubStateBackend.instance != null) SubStateBackend.instance.stepHit(step); });
		FlxRhythmConductor.instance.onMeasureHit.add((measure:Int, backward:Bool) -> { if (SubStateBackend.instance != null) SubStateBackend.instance.measureHit(measure); });
	}

	public static function setInitialBPM(bpm:Float, tsn:Int = 4, tsd:Int = 4) {
		FlxRhythmConductor.instance.loadMeta([
			new MusicTimeChangeEvent(0, bpm, tsn, tsd)
		]);
	}

	public static function update() {
		FlxRhythmConductor.instance.update(null);
	}

	public static function playSong(id:String, ?variation:String) {
		NovaUtils.playMusic('$id/song/Inst${variation == null ? '' : '-$variation'}', 'songs');

	}

}