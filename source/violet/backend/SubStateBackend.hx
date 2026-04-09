package violet.backend;

import lemonui.utils.MathUtil;
import flixel.FlxBasic;
import violet.backend.audio.Conductor;
import violet.backend.objects.IsBopper;
import violet.backend.scripting.events.EventBase;

#if SCRIPT_SUPPORT
import violet.backend.scripting.ScriptPack;
#end

class SubStateBackend extends flixel.FlxSubState {

	#if SCRIPT_SUPPORT
	public var subStateScripts:ScriptPack = new ScriptPack();
	#end

	/**
	 * Alias for `MathUtil.lerp`
	 */
	public function lerp(a:Float, b:Float, ratio:Float, fpsSensitive:Bool = true) return MathUtil.lerp(a, b, ratio, fpsSensitive);

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


	public var usesLoadingScreen = false;
	public var stuffToLoad:Array<FlxBasic> = [];

	public static var instance:SubStateBackend;

	override public function create() {
		super.create();

		instance = this;

		#if SCRIPT_SUPPORT
		subStateScripts.parent = this;
		for (path in #if MOD_SUPPORT ModdingAPI.STATE_PATHS #else ['data/scripts/states'] #end) {
			checkForScripts([Paths.ASSETS_FOLDER, path].join("/") + '/${Main.subStateClassName}');
			#if MOD_SUPPORT
			for (mod in ModdingAPI.getActiveMods())
				checkForScripts([ModdingAPI.MOD_FOLDER, mod.folder, path].join("/") + '/${Main.subStateClassName}');
			#end
		}
		#end
		callInScripts('create');
	}

	#if SCRIPT_SUPPORT
	public function checkForScripts(string:String, ?pack:ScriptPack) {
		pack ??= subStateScripts;

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

	override public function update(elapsed:Float) {
		super.update(elapsed);

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

	public function callInScripts<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		return #if SCRIPT_SUPPORT subStateScripts.call(funcName, args, def) ?? #end def;
	}

	public function runEvent<T:EventBase>(func:String, event:T):T {
		#if SCRIPT_SUPPORT
		if (subStateScripts == null) return event;
		return subStateScripts.event(func, event);
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