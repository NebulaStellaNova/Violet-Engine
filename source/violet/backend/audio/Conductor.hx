package violet.backend.audio;

import flixel.addons.sound.FlxRhythmConductor;
import flixel.addons.sound.MusicTimeChangeEvent;

using flixel.addons.sound.FlxRhythmConductorUtil;


using StringTools;

class Conductor {

	public static var curBeat(get, never):Int;
	static function get_curBeat() return FlxRhythmConductor.instance.currentBeat;

	public static var curStep(get, never):Int;
	static function get_curStep() return FlxRhythmConductor.instance.currentStep;

	public static var curMeasure(get, never):Int;
	static function get_curMeasure() return FlxRhythmConductor.instance.currentMeasure;

	public static var BPM:Float = 0;

	public static var initialized:Bool = false;

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

	public static function setInitialBPM(bpm:Float, tsn:Int = 4, tsd:Int = 4) {
		BPM = bpm;
		FlxRhythmConductor.instance.loadMeta([
			new MusicTimeChangeEvent(0, bpm, tsn, tsd)
		]);
	}

	public static function update() {
		FlxRhythmConductor.instance.update(null);
	}

}