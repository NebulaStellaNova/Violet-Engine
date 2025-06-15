package backend;

import apis.WindowsAPI;
import backend.scripts.ScriptPack;
import scripting.events.SelectionEvent;
import scripting.events.SongEvent;
import scripting.events.EventBase;
import backend.audio.Conductor;
import backend.scripts.LuaScript;
import backend.scripts.FunkinScript;
import backend.filesystem.Paths;
import flixel.FlxState;
import flixel.FlxG;

import flixel.util.FlxStringUtil;
import states.substates.DebugSubState;
import flixel.system.debug.watch.Tracker;
import backend.scripts.LuaScript;

typedef GlobalVariables = {
	var noteSkin:String;
	var scoreTxt:String; // Example "Misses: $misses | Accuracy: $accuracy | Score: $score"
}

class MusicBeatState extends FlxState {
	var previousStep:Int = -1;
	var previousBeat:Int = -1;
	var previousMeasure:Int = -1;

	var debugSubState:DebugSubState;

	public var stateScripts:ScriptPack = new ScriptPack();
	public var globalVariables:GlobalVariables;

	var defaultDebugVars:Array<String> = ["stateScript"];
	public var debugVars:Array<String> = [];
	var ____________________ = "                  ";

	override public function create() {
		globalVariables = Paths.parseJson("globalVariables", "data/config");
		super.create();
		Conductor.init();

		var luaScriptPath = "assets/data/scripts/states/" + Main.className + ".lua";
		var scriptPath = "assets/data/scripts/states/" + Main.className + ".hx";
		if (Paths.fileExists(scriptPath)) {
			var stateScript = new FunkinScript(Paths.readStringFromPath(scriptPath));
			stateScript.call("create");
			stateScript.call("onCreate");
			stateScripts.addScript(stateScript);
		}
		if (Paths.fileExists(luaScriptPath)) {
			var stateLuaScript = new LuaScript(luaScriptPath);
			stateLuaScript.call("create");
			stateLuaScript.call("onCreate");
			stateScripts.addScript(stateLuaScript);
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


		if (FlxG.keys.justPressed.F2){
			WindowsAPI.openConsole();
		}

		if (FlxG.keys.justPressed.F3){
			WindowsAPI.closeConsole();
		}

		call("update", [elapsed]);
		call("onUpdate", [elapsed]);


		if (previousStep != Conductor.curStep) {
			stepHit(Conductor.curStep);
			previousStep = Conductor.curStep;
		}
		if (previousBeat != Conductor.curBeat) {
			beatHit(Conductor.curBeat);
			previousBeat = Conductor.curBeat;
		}
		if (previousMeasure != Conductor.curMeasure) {
			measureHit(Conductor.curMeasure);
			previousMeasure = Conductor.curMeasure;
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
	public function runEvent<T:EventBase>(func:String, event:T):T {
		if (stateScripts == null) return event;
		return stateScripts.event(func, event);
	}

	public function call<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		if (stateScripts == null) return def;
		return stateScripts.call(funcName, args, def);
	}

	public function set(what, value) {
		if (stateScripts == null) return;
		//stateScripts.set(what, value);
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

	public function stepHit(curStep:Int) {
		//
	}
	public function beatHit(curBeat:Int) {
		//
	}
	public function measureHit(curMeasure:Int) {
		//
	}
}