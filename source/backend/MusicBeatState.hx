package backend;

import backend.rulescript.FunkinScript;
import backend.filesystem.Paths;
import rulescript.parsers.HxParser;
import flixel.FlxState;
import flixel.FlxG;

import backend.rulescript.Script;

class MusicBeatState extends FlxState {

	var stateScript:FunkinScript;

    override public function create()
	{
		super.create();
		//stateScript = new Script(new HxParser());

		
		var scriptPath = "assets/data/scripts/states/" + Main.className + ".hx";
		if (Paths.fileExists(scriptPath)) {
			stateScript = new FunkinScript(Paths.readStringFromPath(scriptPath));
			stateScript.call("create");
			stateScript.call("onCreate"); 
			for (i in Reflect.fields(FlxG.state)) {
				stateScript.variables.set(i, Reflect.field(FlxG.state, i));
			}
			postCreate();
		}

		//FlxG.signals.postStateSwitch.add(postCreate);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (stateScript != null) {
			stateScript.call("update", [elapsed]);
			stateScript.call("onUpdate", [elapsed]);
		}

		if (FlxG.keys.justPressed.F5) {
			FlxG.resetState();
		}
	}

	public function postCreate() {
		stateScript.call("postCreate");
		stateScript.call("onCreatePost");
	}

}