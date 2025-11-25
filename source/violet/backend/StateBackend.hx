package violet.backend;

import flixel.FlxBasic;
import flixel.FlxState;

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

		#if (MOD_SUPPORT && SCRIPT_SUPPORT)
		for (mod in ModdingAPI.getActiveMods()) {
			for (path in ModdingAPI.STATE_PATHS) {
				var filePath:String = '${['mods', mod.folder, path].join('/')}/${Main.stateClassName}';
				#if CAN_HAXE_SCRIPT
				if (Paths.fileExists('$filePath.hx')) {
					stateScripts.addScript(new violet.backend.scripting.FunkinScript('$filePath.hx'));
				}
				#end

				#if CAN_LUA_SCRIPT
				if (Paths.fileExists('$filePath.lua')) {
					stateScripts.addScript(new violet.backend.scripting.LuaScript('$filePath.lua'));
				}
				#end

				#if CAN_HAXE_SCRIPT
				if (Paths.fileExists('$filePath.py')) {
					stateScripts.addScript(new violet.backend.scripting.PythonScript('$filePath.py'));
				}
				#end
			}
		}
		#end
	}

	override public function add(objORcall:FlxBasic) {
		if (usesLoadingScreen) {
			stuffToLoad.push(objORcall);
		} else {
			super.add(objORcall);
		}
		return objORcall;
	}

}