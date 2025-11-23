package violet.backend;

import flixel.FlxBasic;
import flixel.FlxState;
import flixel.util.FlxStringUtil;
import violet.backend.utils.ParseUtil;

class StateBackend extends flixel.FlxState {
	public var usesLoadingScreen = false;
	public var stuffToLoad:Array<FlxBasic> = [];

	override public function add(objORcall:FlxBasic) {
		if (usesLoadingScreen) {
			stuffToLoad.push(objORcall);
		} else {
			super.add(objORcall);
		}
		return objORcall;
	}
}