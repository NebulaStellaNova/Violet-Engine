package violet.backend;

import flixel.FlxBasic;
import flixel.FlxState;
import flixel.FlxCamera;


#if SCRIPT_SUPPORT
import violet.backend.scripting.ScriptPack;
#end

class StateBackend extends flixel.FlxState {

	#if SCRIPT_SUPPORT
	public var stateScripts:ScriptPack = new ScriptPack();
	#end

	public var usesLoadingScreen = false;
	public var stuffToLoad:Array<FlxBasic> = [];

	override public function create() {
		super.create();


		stateScripts.parent = this;

		#if (MOD_SUPPORT && SCRIPT_SUPPORT)
		for (mod in ModdingAPI.getActiveMods()) {
			for (path in ModdingAPI.STATE_PATHS) {
				var filePath:String = '${['mods', mod.folder, path].join('/')}/${Main.stateClassName}';

				#if CAN_LUA_SCRIPT
				if (Paths.fileExists('$filePath.lua', true)) {
					var script = new violet.backend.scripting.LuaScript('$filePath.lua');
					stateScripts.addScript(script);
				}
				#end

				#if CAN_HAXE_SCRIPT
				if (Paths.fileExists('$filePath.hx', true)) {
					var script = new violet.backend.scripting.FunkinScript('$filePath.hx');
					stateScripts.addScript(script);
				}
				#end

				#if CAN_HAXE_SCRIPT
				if (Paths.fileExists('$filePath.py', true)) {
					var script = new violet.backend.scripting.PythonScript('$filePath.py');
					stateScripts.addScript(script);
				}
				#end
			}
		}
		callInScripts('create');
		#end
		new flixel.util.FlxTimer().start(0.1, (_)->{
			nextFrame = true;
		});
	}

	var nextFrame = false;

	public function callInScripts(what) {
		stateScripts.call(what);
	}

	var notificationManager = new haxe.ui.notifications.NotificationManager();
	var errIndex:Int = 0;
	override public function update(_) {
		super.update(_);

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

	/* public function runEvent<T:EventBase>(func:String, event:T):T {
		if (stateScripts == null) return event;
		return stateScripts.event(func, event);
	} */

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
}