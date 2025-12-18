package violet.backend;

#if SCRIPT_SUPPORT
import violet.backend.scripting.ScriptPack;
#end

class SubStateBackend extends flixel.FlxSubState {

	#if SCRIPT_SUPPORT
	public var subStateScripts:ScriptPack = new ScriptPack();
	#end

	public var usesLoadingScreen = false;
	public var stuffToLoad:Array<flixel.FlxBasic> = [];

	override public function create() {
		super.create();


		subStateScripts.parent = this;

		#if (MOD_SUPPORT && SCRIPT_SUPPORT)
		for (path in ModdingAPI.STATE_PATHS) {
			checkForScripts([Paths.ASSETS_FOLDER, path].join("/") + '/${Main.subStateClassName}');
			for (mod in ModdingAPI.getActiveMods())
				checkForScripts([ModdingAPI.MOD_FOLDER, mod.folder, path].join("/") + '/${Main.subStateClassName}');
		}
		callInScripts('create');
		#end
		new flixel.util.FlxTimer().start(0.1, (_)->{
			nextFrame = true;
		});
	}

	var nextFrame = false;

	public function callInScripts(what) {
		subStateScripts.call(what);
	}

	public function checkForScripts(string:String) {
		var filePath:String = string;

		#if CAN_LUA_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("lua")) {
			if (Paths.fileExists('$filePath.$ext', true)) {
				var script = new violet.backend.scripting.LuaScript('$filePath.$ext');
				subStateScripts.addScript(script);
			}
		}
		#end

		#if CAN_HAXE_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("hx")) {
			if (Paths.fileExists('$filePath.$ext', true)) {
				var script = new violet.backend.scripting.FunkinScript('$filePath.$ext');
				subStateScripts.addScript(script);
			}
		}
		#end

		#if CAN_HAXE_SCRIPT
		for (ext in ModdingAPI.EXT_ALIASES.get("py")) {
			if (Paths.fileExists('$filePath.$ext', true)) {
				var script = new violet.backend.scripting.PythonScript('$filePath.$ext');
				subStateScripts.addScript(script);
			}
		}
		#end
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

	override public function add(objORcall:flixel.FlxBasic) {
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