package backend;

import sys.thread.Condition;
import flixel.util.FlxSort;
import utils.SortUtil;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
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
import flixel.group.FlxGroup.FlxTypedGroup;
using utils.ArrayUtil;

typedef GlobalVariables = {
	var noteSkin:String;
	var scoreTxt:String; // Example "Misses: $misses | Accuracy: $accuracy | Score: $score"
}

class MusicBeatState extends FlxState {
    public var debugTexts:FlxTypedGroup<FlxText> = new FlxTypedGroup();

	public var curBeat:Int = 0;
	public var curStep:Int = 0;
	public var curMeasure:Int = 0;

	public var beat:Int = 0;
	public var step:Int = 0;
	public var measure:Int = 0;

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

		var scriptPath = 'data/scripts/states/${Main.className}';
		for(i in Paths.modPaths(scriptPath)) {
			if (Paths.fileExists('$i.hx')) {
				stateScripts.addScript(new FunkinScript('$i.hx'));
			}
			if (Paths.fileExists('$i.lua')) {
				stateScripts.addScript(new LuaScript('$i.lua'));
			}
		}

		call('create');
		call('onCreate');

		#if FLX_DEBUG
		//var trackerProfile = new TrackerProfile(MusicBeatState, defaultDebugVars.concat(debugVars).concat(["____________________"]), []);
		//FlxG.debugger.addTrackerProfile(trackerProfile);
		//FlxG.debugger.track(FlxG.state, "Current State");

		FlxG.watch.add(this, "stateScript", "State HScript:");
		#end


		Conductor.playMusic(Paths.music("freakyMenu"));

		//postCreate();

		add(debugTexts);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		curBeat = Conductor.curBeat;
		curStep = Conductor.curStep;
		curMeasure = Conductor.curMeasure;
		beat = Conductor.curBeat;
		step = Conductor.curBeat;
		measure = Conductor.curBeat;

		FlxG.autoPause = false;


		if (FlxG.keys.justPressed.F1) {
			debugPrint('Test ${FlxG.random.int()}');
		}

		if (FlxG.keys.justPressed.F2){
			WindowsAPI.showConsole();
		}

		if (FlxG.keys.justPressed.F3){
			WindowsAPI.hideConsole();
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

		for (i => txt in debugTexts.members) {
			txt.cameras = [FlxG.cameras.list.getLastOf()];
			txt.y = (((debugTexts.members.length-1)-i) * 30)+10;
		}
		remove(debugTexts);
		insert(FlxG.state.members.length, debugTexts);
	}

	public function refresh() {
		sort(SortUtil.byZIndex, FlxSort.ASCENDING);
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

	public function set(what:String, value:Dynamic) {
		if (stateScripts == null) return;
		stateScripts.set(what, value);
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

	public function stepHit(theStep:Int) {
		curStep = theStep;
		step = theStep;
	}
	public function beatHit(theBeat:Int) {
		curBeat = theBeat;
		beat = theBeat;
	}
	public function measureHit(theMeasure:Int) {
		curMeasure = theMeasure;
		measure = theMeasure;
	}

	public function debugPrint(text:String, color:String = "WHITE") {
		var txt:FlxText = new FlxText(10, 0, 0, text, 20);
		txt.color = FlxColor.fromString(color);
		txt.scrollFactor.set(0, 0);
		txt.cameras = [FlxG.cameras.list.getLastOf()];
		txt.y = (debugTexts.members.length * 30)+10;
		txt.borderStyle = OUTLINE;
		txt.borderSize = 2;
		FlxTween.tween(txt, {alpha: 0}, 2, {startDelay: 3});
		debugTexts.add(txt);
		log(text, {
			fileName: 'DebugPrint',//'$folderName:$fileName:$finalLine',
			lineNumber: 0,
			className: "",
			methodName: ""
		});
	}
}