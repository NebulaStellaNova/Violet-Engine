package violet.backend;

import violet.backend.scripting.GlobalPack;
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

	public static var instance:SubStateBackend;

	override public function create() {
		super.create();

		instance = this;

		#if SCRIPT_SUPPORT
		subStateScripts.parent = this;
		for (path in #if MOD_SUPPORT ModdingAPI.STATE_PATHS #else ['data/scripts/states'] #end)
			ModdingAPI.checkForScripts(path, getScriptName(), subStateScripts);
		#end
		callInScripts('create');
	}

	public function getScriptName():String {
		return Main.subStateClassName;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		callInScripts('update');
	}

	public function callInScripts<T>(funcName:String, ?args:Array<Dynamic>, ?def:T):T {
		#if SCRIPT_SUPPORT if (GlobalPack.instance != null && !funcName.toLowerCase().contains('create')) GlobalPack.instance.callVariants(funcName, args); #end
		return #if SCRIPT_SUPPORT subStateScripts.callVariants(funcName, args, def) ?? #end def;
	}

	public function runEvent<T:EventBase>(func:String, event:T):T {
		#if SCRIPT_SUPPORT
		if (subStateScripts == null) return event;
		return subStateScripts.event(func, event);
		#else
		return event;
		#end
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