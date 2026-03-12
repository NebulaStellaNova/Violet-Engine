package violet.backend;

import flixel.input.keyboard.FlxKey;

/**
 * This class handles user controls, without it how would you do anything?
 */
class Controls {
	// Shortcut vars
	/**
	 * Left note press.
	 */
	public static var noteLeft(get, never):Bool;
	inline static function get_noteLeft():Bool
		return pressed('note_left');
	/**
	 * Down note press.
	 */
	public static var noteDown(get, never):Bool;
	inline static function get_noteDown():Bool
		return pressed('note_down');
	/**
	 * Up note press
	 */
	public static var noteUp(get, never):Bool;
	inline static function get_noteUp():Bool
		return pressed('note_up');
	/**
	 * Right note press.
	 */
	public static var noteRight(get, never):Bool;
	inline static function get_noteRight():Bool
		return pressed('note_right');

	/**
	 * Left note held.
	 */
	public static var noteLeftHeld(get, never):Bool;
	inline static function get_noteLeftHeld():Bool
		return held('note_left');
	/**
	 * Down note held.
	 */
	public static var noteDownHeld(get, never):Bool;
	inline static function get_noteDownHeld():Bool
		return held('note_down');
	/**
	 * Up note held.
	 */
	public static var noteUpHeld(get, never):Bool;
	inline static function get_noteUpHeld():Bool
		return held('note_up');
	/**
	 * Right note held.
	 */
	public static var noteRightHeld(get, never):Bool;
	inline static function get_noteRightHeld():Bool
		return held('note_right');

	/**
	 * Left note released.
	 */
	public static var noteLeftReleased(get, never):Bool;
	inline static function get_noteLeftReleased():Bool
		return released('note_left');
	/**
	 * Down note released.
	 */
	public static var noteDownReleased(get, never):Bool;
	inline static function get_noteDownReleased():Bool
		return released('note_down');
	/**
	 * Up note released.
	 */
	public static var noteUpReleased(get, never):Bool;
	inline static function get_noteUpReleased():Bool
		return released('note_up');
	/**
	 * Right note released.
	 */
	public static var noteRightReleased(get, never):Bool;
	inline static function get_noteRightReleased():Bool
		return released('note_right');

	/**
	 * When you press left to move through ui elements
	 */
	public static var uiLeft(get, never):Bool;
	inline static function get_uiLeft():Bool
		return pressed('ui_left');
	/**
	 * When you press down to move through ui elements
	 */
	public static var uiDown(get, never):Bool;
	inline static function get_uiDown():Bool
		return pressed('ui_down') || FlxG.mouse.wheel < 0;
	/**
	 * When you press up to move through ui elements
	 */
	public static var uiUp(get, never):Bool;
	inline static function get_uiUp():Bool
		return pressed('ui_up') || FlxG.mouse.wheel > 0;
	/**
	 * When you press right to move through ui elements
	 */
	public static var uiRight(get, never):Bool;
	inline static function get_uiRight():Bool
		return pressed('ui_right');

	/**
	 * When you hold left to move through ui elements
	 */
	public static var uiLeftPress(get, never):Bool;
	inline static function get_uiLeftPress():Bool
		return held('ui_left');
	/**
	 * When you hold down to move through ui elements
	 */
	public static var uiDownPress(get, never):Bool;
	inline static function get_uiDownPress():Bool
		return held('ui_down');
	/**
	 * When you hold up to move through ui elements
	 */
	public static var uiUpPress(get, never):Bool;
	inline static function get_uiUpPress():Bool
		return held('ui_up');
	/**
	 * When you hold up to move through ui elements
	 */
	public static var uiRightPress(get, never):Bool;
	inline static function get_uiRightPress():Bool
		return held('ui_right');

	/**
	 * When you release left to move through ui elements
	 */
	public static var uiLeftReleased(get, never):Bool;
	inline static function get_uiLeftReleased():Bool
		return released('ui_left');
	/**
	 * When you release down to move through ui elements
	 */
	public static var uiDownReleased(get, never):Bool;
	inline static function get_uiDownReleased():Bool
		return released('ui_down');
	/**
	 * When you release up to move through ui elements
	 */
	public static var uiUpReleased(get, never):Bool;
	inline static function get_uiUpReleased():Bool
		return released('ui_up');
	/**
	 * When you release right to move through ui elements
	 */
	public static var uiRightReleased(get, never):Bool;
	inline static function get_uiRightReleased():Bool
		return released('ui_right');

	/**
	 * When "accept" is pressed.
	 */
	public static var accept(get, never):Bool;
	inline static function get_accept():Bool
		return pressed('accept') || FlxG.mouse.justPressed;
	/**
	 * When "back" is pressed.
	 */
	public static var back(get, never):Bool;
	inline static function get_back():Bool
		return pressed('back') || FlxG.mouse.justPressedRight;
	/**
	 * When "paused" is pressed.
	 */
	public static var pause(get, never):Bool;
	inline static function get_pause():Bool
		return pressed('pause');
	/**
	 * When "reset" is pressed.
	 */
	public static var reset(get, never):Bool;
	inline static function get_reset():Bool
		return pressed('reset');

	/**
	 * When "fullscreen" is pressed.
	 */
	public static var fullscreen(get, never):Bool;
	inline static function get_fullscreen():Bool
		return pressed('fullscreen');

	/**
	 * When "botplay" is pressed.
	 */
	public static var botplay(get, never):Bool;
	inline static function get_botplay():Bool
		return pressed('botplay');
	/**
	 * When "resetState" is pressed.
	 */
	public static var resetState(get, never):Bool;
	inline static function get_resetState():Bool
		return pressed('resetState');
	/**
	 * When "debugDisplay" is pressed.
	 */
	public static var debugDisplay(get, never):Bool;
	inline static function get_debugDisplay():Bool
		return pressed('debugDisplay');
	/**
	 * When "shortcutState" is pressed.
	 */
	public static var shortcutState(get, never):Bool;
	inline static function get_shortcutState():Bool
		return pressed('shortcutState');
	/**
	 * When "reloadGame" is pressed.
	 */
	public static var reloadGame(get, never):Bool;
	inline static function get_reloadGame():Bool
		return pressed('reloadGame');

	// Rest of class
	/**
	 * The binds that are contained within controls.
	 */
	public static var bindMap(default, null):Map<String, Array<FlxKey>> = []; // Setup in Options.hx
	/**
	 * Pressed input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public static function pressed(key:String):Bool
		return FlxG.keys.anyJustPressed(bindCheck(key));
	/**
	 * Held input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public static function held(key:String):Bool
		return FlxG.keys.anyPressed(bindCheck(key));
	/**
	 * Released input.
	 * @param key The key name.
	 * @return Bool
	 */
	inline public static function released(key:String):Bool
		return FlxG.keys.anyJustReleased(bindCheck(key));

	inline static function bindCheck(key:String):Array<FlxKey>
		return active && bindMap.exists(key) ? bindMap.get(key) : [];

	/**
	 * States whether that inputs will work.
	 */
	public static var active:Bool = true;
}