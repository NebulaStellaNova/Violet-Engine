package violet.backend.scripting.hxc;

import violet.backend.scripting.events.CountdownTickEvent;
import violet.backend.scripting.events.SongEvent;
import violet.backend.scripting.events.NoteHitEvent;
import violet.backend.scripting.events.EventBase;

typedef ModuleParams = {
	?state:Class<Dynamic>
}

class ScriptedModule extends Module implements rulescript.scriptedClass.RuleScriptedClass {}

@:strictScriptedConstructor
class Module {
	/**
	 * Whether the module is currently active.
	 */
	public var active(default, set):Bool = true;

	function set_active(value:Bool):Bool {
		return this.active = value;
	}

	public var moduleId(default, null):String = 'UNKNOWN';

	/**
	 * Determines the order in which modules receive events.
	 * You can modify this to change the order in which a given module receives events.
	 *
	 * Priority 1 is processed before Priority 1000, etc.
	 */
	public var priority(default, set):Int = 1000;

	function set_priority(value:Int):Int {
		this.priority = value;
		return value;
	}

	public var state:Null<Class<Dynamic>> = null;

	public function new(moduleId:String, priority:Int = 1000, ?params:ModuleParams):Void {
		this.moduleId = moduleId;
		this.priority = priority;

		if (params != null) {
			this.state = params.state ?? null;
		}
	}

	public function toString():String {
		return 'Module(' + this.moduleId + ')';
	}

	// TODO: Half of these aren't actually being called!!!!!!!

	/**
	 * Called when ANY script event is dispatched.
	 */
	public function onScriptEvent(event) {}

	/**
	 * Called when the module is first created.
	 * This happens before the title screen appears!
	 */
	public function onCreate(event) {}

	/**
	 * Called when a module is destroyed.
	 * This currently only happens when reloading modules with F5.
	 */
	public function onDestroy(event) {}

	/**
	 * Called every frame.
	 */
	public function onUpdate(event:{elapsed:Float}) {}

	/**
	 * Called when the game is paused.
	 */
	public function onPause(event:EventBase) {}

	/**
	 * Called when the game is resumed.
	 */
	public function onResume(event) {}

	/**
	 * Called when the song begins.
	 */
	public function onSongStart(event) {}

	/**
	 * Called when the song ends.
	 */
	public function onSongEnd(event) {}

	/**
	 * Called when the player dies.
	 */
	public function onGameOver(event) {}

	/**
	 * Called when a note has been hit.
	 * This gets dispatched for both the player and opponent strumlines.
	 */
	public function onNoteHit(event:NoteHitEvent) {}

	/**
	 * Called when a note has been missed.
	 * This gets dispatched for both the player and opponent strumlines.
	 */
	public function onNoteMiss(event:NoteHitEvent) {}

	/**
	 * Called when the player presses a key without any notes present.
	 */
	public function onNoteGhostMiss(event:NoteHitEvent) {}

	/**
	 * Called when a step is hit in the song.
	 */
	public function onStepHit(event:{step:Int}) {}

	/**
	 * Called when a beat is hit in the song.
	 */
	public function onBeatHit(event:{beat:Int}) {}

	/**
	 * Called when a song event is triggered.
	 */
	public function onSongEvent(event:SongEvent) {}

	/**
	 * Called when the countdown begins.
	 */
	public function onCountdownStart(event:EventBase) {}

	/**
	 * Called for every step in the countdown.
	 */
	public function onCountdownStep(event:CountdownTickEvent) {}

	/**
	 * Called when the countdown ends, but BEFORE the song starts.
	 */
	public function onCountdownEnd(event:EventBase) {}

	/**
	 * Called when the song's chart has been parsed and loaded.
	 */
	// public function onSongLoaded(event:SongLoadScriptEvent) {}

	/**
	 * Called when the game is about to switch to a new state.
	 */
	// public function onStateChangeBegin(event:StateChangeScriptEvent) {}

	/**
	 * Called after the game has switched to a new state.
	 */
	// public function onStateChangeEnd(event:StateChangeScriptEvent) {}

	/**
	 * Called when the game regains focus.
	 * This does not get called if "Pause on Unfocus" is disabled.
	 */
	// public function onFocusGained(event:FocusScriptEvent) {}

	/**
	 * Called when the game loses focus.
	 * This does not get called if "Pause on Unfocus" is disabled.
	 */
	// public function onFocusLost(event:FocusScriptEvent) {}

	/**
	 * Called when the game is about to open a substate.
	 */
	// public function onSubStateOpenBegin(event:SubStateScriptEvent) {}

	/**
	 * Called when a substate has been opened.
	 */
	// public function onSubStateOpenEnd(event:SubStateScriptEvent) {}

	/**
	 * Called when the game is about to close a substate.
	 */
	// public function onSubStateCloseBegin(event:SubStateScriptEvent) {}

	/**
	 * Called when a substate has been closed.
	 */
	// public function onSubStateCloseEnd(event:SubStateScriptEvent) {}

	/**
	 * Called when the song has been restarted.
	 */
	// public function onSongRetry(event:SongRetryEvent) {}

	/**
	 * Called when any state is created.
	 */
	// public function onStateCreate(event) {}

	/**
	 * Called when a capsule is selected.
	 */
	// public function onCapsuleSelected(event:CapsuleScriptEvent):Void {}

	/**
	 * Called when the current difficulty is changed.
	 */
	// public function onDifficultySwitch(event:CapsuleScriptEvent):Void {}

	/**
	 * Called when a song is selected.
	 */
	// public function onSongSelected(event:CapsuleScriptEvent):Void {}

	/**
	 * Called when the intro for Freeplay finishes.
	 */
	// public function onFreeplayIntroDone(event:FreeplayScriptEvent):Void {}

	/**
	 * Called when the Freeplay outro begins.
	 */
	// public function onFreeplayOutro(event:FreeplayScriptEvent):Void {}

	/**
	 * Called when Freeplay is closed.
	 */
	// public function onFreeplayClose(event:FreeplayScriptEvent):Void {}

	/**
	 * Called when a character is selected.
	 */
	// public function onCharacterSelect(event:CharacterSelectScriptEvent):Void {}

	/**
	 * Called when the user presses BACK after confirming a character.
	 */
	// public function onCharacterDeselect(event:CharacterSelectScriptEvent):Void {}

	/**
	 * Called when a character has been confirmed.
	 */
	// public function onCharacterConfirm(event:CharacterSelectScriptEvent):Void {}
}
