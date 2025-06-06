package states.substates;

import flixel.FlxSubState;

class DebugSubState extends FlxSubState {

    public function thePrint(what, type) {
        log(what, type); // So if you spam button it looks nice in console :D
    }

    override public function create()
	{
		super.create();
        thePrint("Debug Mode Enabled", DebugMessage);
    }

    public function onClose() {
        thePrint("Debug Mode Disabled", DebugMessage);
    }
}