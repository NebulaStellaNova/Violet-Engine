package backend.audio;

import flixel.FlxG;

class Conductor {

	public static var bpm(default, null):Float = 100;

	public static var curStep(default, null):Int = 0;
	
	public static var curBeat(default, null):Int = 0;

	public static var curMeasure(default, null):Int = 0;

	public static function init() {
		FlxG.signals.preUpdate.add(update);
	}

	public static function update() {
		
	}
}