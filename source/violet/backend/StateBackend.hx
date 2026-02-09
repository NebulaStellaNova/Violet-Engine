package violet.backend;

import flixel.FlxBasic;

import violet.backend.audio.Conductor;
import violet.backend.scripting.events.EventBase;

#if SCRIPT_SUPPORT
import violet.backend.scripting.ScriptPack;
#end

class StateBackend extends flixel.FlxState {

	#if SCRIPT_SUPPORT
	public var stateScripts:ScriptPack = new ScriptPack();
	#end

	public var curBeat(get, never):Int;
	function get_curBeat() return Conductor.curBeat;

	public var curStep(get, never):Int;
	function get_curStep() return Conductor.curStep;

	public var curMeasure(get, never):Int;
	function get_curMeasure() return Conductor.curMeasure;

	public var beat(get, never):Int;
	function get_beat() return Conductor.curBeat;

	public var step(get, never):Int;
	function get_step() return Conductor.curStep;

	public var measure(get, never):Int;
	function get_measure() return Conductor.curMeasure;


	public var usesLoadingScreen:Bool = false;
	public var stuffToLoad:Array<FlxBasic> = [];

	public static var instance:StateBackend;

	override public function create() {
		super.create();

		Conductor.init();

		instance = this;

		#if SCRIPT_SUPPORT stateScripts.parent = this; #end
		#if (MOD_SUPPORT && SCRIPT_SUPPORT)
		for (path in ModdingAPI.STATE_PATHS) {
			checkForScripts([Paths.ASSETS_FOLDER, path].join("/") + '/${Main.stateClassName}');
			for (mod in ModdingAPI.getActiveMods())
				checkForScripts([ModdingAPI.MOD_FOLDER, mod.folder, path].join("/") + '/${Main.stateClassName}');
		}
		callInScripts('create');
		#end

		new flixel.util.FlxTimer().start(0.1, (_)->{
			nextFrame = true;
		});
	}

	public function checkForScripts(string:String) {
		var filePath:String = string;

		#if CAN_LUA_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("lua")) {
			if (Paths.fileExists('$filePath.$ext', true)) {
				var script = new violet.backend.scripting.LuaScript('$filePath.$ext');
				stateScripts.addScript(script);
			}
		}
		#end

		#if CAN_HAXE_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("hx")) {
			if (Paths.fileExists('$filePath.$ext', true)) {
				var script = new violet.backend.scripting.FunkinScript('$filePath.$ext');
				stateScripts.addScript(script);
			}
		}
		#end

		#if CAN_HAXE_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("py")) {
			if (Paths.fileExists('$filePath.$ext', true)) {
				var script = new violet.backend.scripting.PythonScript('$filePath.$ext');
				stateScripts.addScript(script);
			}
		}
		#end
	}

	var nextFrame = false;

	public function callInScripts<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		return #if SCRIPT_SUPPORT stateScripts.call(funcName, args, def) ?? #end def;
	}

	var notificationManager = new haxe.ui.notifications.NotificationManager();
	var errIndex:Int = 0;
	override public function update(elapsed:Float) {
		super.update(elapsed);

		Conductor.update();

		if (nextFrame) {
			if (errIndex > violet.backend.CrashHandler.notifList.length - 1) {
				nextFrame = false;
			} else {
				notificationManager.addNotification({
					title: violet.backend.CrashHandler?.notifList[errIndex]?.title,
					body: violet.backend.CrashHandler?.notifList[errIndex]?.description,
					type: haxe.ui.notifications.NotificationType.Error,
					expiryMs: 5000,
					actions: []
				});
			}
			errIndex++;
		}
		callInScripts('update');
	}

	override public function add(objORcall:FlxBasic) {
		if (usesLoadingScreen) {
			stuffToLoad.push(objORcall);
		} else {
			super.add(objORcall);
		}
		return objORcall;
	}

	public function runEvent<T:EventBase>(func:String, event:T):T {
		#if SCRIPT_SUPPORT
		if (stateScripts == null) return event;
		return stateScripts.event(func, event);
		#else
		return event;
		#end
	}

	public function debugPrint(text:String, color:String = "WHITE") {
		/* var txt:FlxText = new FlxText(10, 0, 0, text, 20);
		txt.color = FlxColor.fromString(color);
		txt.scrollFactor.set(0, 0);
		txt.cameras = [FlxG.cameras.list.getLastOf()];
		txt.y = (debugTexts.members.length * 30)+10;
		txt.borderStyle = OUTLINE;
		txt.borderSize = 2;
		FlxTween.tween(txt, {alpha: 0}, 2, {startDelay: 3});
		debugTexts.add(txt);
		violet.backend.console.Logs.log(text, {
			fileName: 'DebugPrint',//'$folderName:$fileName:$finalLine',
			lineNumber: 0,
			className: "",
			methodName: ""
		}); */
	}

	public function stepHit(curStep:Int) {
		callInScripts('stepHit', [curStep]);
	}

	public function beatHit(curBeat:Int) {
		callInScripts('beatHit', [curBeat]);
	}

	public function measureHit(curMeasure:Int) {
		callInScripts('measureHit', [curMeasure]);
	}
}