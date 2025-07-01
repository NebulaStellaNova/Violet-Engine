package states.substates;

import flixel.util.FlxTimer;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSubState;

class TransitionSubState extends FlxSubState {

	public function new(type:String, func) {
		super();
        FlxG.camera.fade(FlxColor.BLACK, 0.2, type == "in", ()->{ func(); close(); });
	}

}