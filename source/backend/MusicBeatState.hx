package backend;

import backend.filesystem.Paths;
import rulescript.parsers.HxParser;
import flixel.FlxState;
import flixel.FlxG;

import backend.rulescript.Script;

class MusicBeatState extends FlxState {

	var stateScript:Script;

    override public function create()
	{
		super.create();
		stateScript = new Script(new HxParser());

		FlxG.signals.postStateSwitch.add(postCreate);

		var scriptPath = "assets/data/scripts/states/" + Main.className + ".hx";
		if (Paths.fileExists(scriptPath)) {
			stateScript.execute(Paths.readStringFromPath(scriptPath));
			stateScript.init();
			stateScript.call("create");
			stateScript.call("onCreate");
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.F5) {
			FlxG.resetState();
		}
	}

	public function postCreate() {
		stateScript.initVars();
	}

}