package backend;

import backend.audio.Conductor;
import backend.scripts.LuaScript;
import backend.scripts.FunkinScript;
import backend.filesystem.Paths;
import flixel.FlxState;
import flixel.FlxG;

import flixel.util.FlxStringUtil;
import states.substates.DebugSubState;
import flixel.system.debug.watch.Tracker;

typedef GlobalVariables = {
	var noteSkin:String;
} 

class MusicBeatState extends FlxState {

	var debugSubState = null;

	public var stateScript:FunkinScript;
	public var globalVariables:GlobalVariables;

	var defaultDebugVars:Array<String> = ["stateScript"];
	public var debugVars:Array<String> = [];
	var ____________________ = "                  ";
	//var stateLuaScript:LuaScript;

    override public function create() {
		globalVariables = Paths.parseJson("globalVariables", "data/config");
		super.create();
		Conductor.init();

		var luaScriptPath = "assets/data/scripts/states/" + Main.className + ".lua";
		var scriptPath = "assets/data/scripts/states/" + Main.className + ".hx";
		if (Paths.fileExists(scriptPath)) {
			stateScript = new FunkinScript(Paths.readStringFromPath(scriptPath));
			call("create");
			call("onCreate");
			stateScript.superInstance = this;
		}
		if (Paths.fileExists(luaScriptPath)) {
			//stateLuaScript = new LuaScript(Paths.readStringFromPath(luaScriptPath));
		}

		#if FLX_DEBUG
        //var trackerProfile = new TrackerProfile(MusicBeatState, defaultDebugVars.concat(debugVars).concat(["____________________"]), []);
        //FlxG.debugger.addTrackerProfile(trackerProfile);
        //FlxG.debugger.track(FlxG.state, "Current State");

		FlxG.watch.add(this, "stateScript", "State HScript:");
        #end


		Conductor.playMusic(Paths.music("freakyMenu"));

		//postCreate();

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (stateScript != null) {
			call("update", [elapsed]);
			call("onUpdate", [elapsed]);
		}

		if (FlxG.keys.justPressed.F5) {
			FlxG.resetState();
		}
		if (FlxG.keys.justPressed.F4) {
			switchState(new ClassData("source:MainMenuState").target);
		}

		#if debug
		if (FlxG.keys.justPressed.BACKSLASH) {
			if (debugSubState == null) {
				debugSubState = new DebugSubState();
				FlxG.state.openSubState(debugSubState);
			} else {
				debugSubState.onClose();
				debugSubState.close();
				debugSubState = null;
			}
			FlxG.state.persistentUpdate = true;
			FlxG.state.persistentDraw = true;
		}
		#end
	}

	public function postCreate() {
		call("postCreate");
		call("onCreatePost");
	}

	public function runEvent(func:String, event:Dynamic) {
		if (stateScript == null) return event;
		stateScript.call(func, [event]);
		//stateLuaScript.call(func, [event]);
		return event;
	}

	public function call(func, ?params) {
		if (stateScript == null) return;
		stateScript.call(func, params ?? []);
		//stateLuaScript.call(func, params ?? []);
	}

	public function set(what, value) {
		if (stateScript == null) return;
		stateScript.set(what, value);
		//stateLuaScript.set(what, value);
	}

	public function switchState(targetClass:Dynamic) {
		var redirects:Array<Dynamic> = Paths.parseJson("stateRedirects", "data/config");
		var className = FlxStringUtil.getClassName(targetClass, true);
		var switched = false;
		for (i in redirects) {
			if (i.state == className) {
				log('Redirecting State "$className" to "${FlxStringUtil.getClassName(new ClassData(i.target).target, true)}"', DebugMessage);
				FlxG.switchState(new ClassData(i.target).target);
				switched = true;
			}
		}
		if (!switched)
			FlxG.switchState(targetClass);
	}
}