package violet.backend;

import flixel.FlxBasic;
import violet.backend.audio.Conductor;
import violet.backend.objects.IsBopper;
import violet.backend.scripting.events.EventBase;
import violet.backend.utils.NovaUtils;

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

		NovaUtils.NOTIFICATION_MANAGER = null;

		Conductor.init();

		instance = this;

		#if SCRIPT_SUPPORT
		stateScripts.parent = this;
		for (path in #if MOD_SUPPORT ModdingAPI.STATE_PATHS #else ['data/scripts/states'] #end) {
			checkForScripts([Paths.ASSETS_FOLDER, path].join("/") + '/${Main.stateClassName}');
			#if MOD_SUPPORT
			for (mod in ModdingAPI.getActiveMods())
				checkForScripts([ModdingAPI.MOD_FOLDER, mod.folder, path].join("/") + '/${Main.stateClassName}');
			#end
		}
		#end
		callInScripts('create');

		new flixel.util.FlxTimer().start(0.1, _ -> nextFrame = true);
	}

	#if SCRIPT_SUPPORT
	public function checkForScripts(string:String, ?pack:ScriptPack) {
		pack ??= stateScripts;

		#if CAN_LUA_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("lua")) {
			if (Paths.fileExists('$string.$ext', true)) {
				var script = new violet.backend.scripting.LuaScript('$string.$ext');
				pack.addScript(script);
			}
		}
		#end

		#if CAN_HAXE_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("hx")) {
			if (Paths.fileExists('$string.$ext', true)) {
				var script = new violet.backend.scripting.FunkinScript('$string.$ext');
				pack.addScript(script);
			}
		}
		#end

		#if CAN_HAXE_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("py")) {
			if (Paths.fileExists('$string.$ext', true)) {
				var script = new violet.backend.scripting.PythonScript('$string.$ext');
				pack.addScript(script);
			}
		}
		#end
	}
	#end

	var nextFrame = false;

	public var notificationManager = new haxe.ui.notifications.NotificationManager();
	var errIndex:Int = 0;
	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.keys.justPressed.TAB)
			violet.states.PlayState.loadSong('test');

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

	public function callInScripts<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		return #if SCRIPT_SUPPORT stateScripts.call(funcName, args, def) ?? #end def;
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
		forEachAlive(sprite -> {
			if (sprite is IsBopper)
				cast(sprite, IsBopper).stepHit(curStep);
		});
		callInScripts('stepHit', [curStep]);
	}

	public function beatHit(curBeat:Int) {
		forEachAlive(sprite -> {
			if (sprite is IsBopper)
				cast(sprite, IsBopper).beatHit(curBeat);
		});
		callInScripts('beatHit', [curBeat]);
	}

	public function measureHit(curMeasure:Int) {
		forEachAlive(sprite -> {
			if (sprite is IsBopper)
				cast(sprite, IsBopper).measureHit(curMeasure);
		});
		callInScripts('measureHit', [curMeasure]);
	}

	override public function destroy():Void {
		instance = null;
		super.destroy();
	}
}