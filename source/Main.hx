package;

import flixel.FlxState;
import flixel.util.FlxStringUtil;
import lime.app.Application;
import thx.semver.Version;
import violet.backend.display.DebugDisplay;
import violet.backend.utils.ParseUtil;

class Main extends openfl.display.Sprite {
	/**
	 * The current version of the engine.
	 */
	public static var engineVersion(default, null):Version;
	/**
	 * The latest version of the engine.
	 */
	public static var latestVersion(default, null):Version;
	#if CHECK_FOR_UPDATES
	/**
	 * If true a new update was released for the engine!
	 */
	public static var updateAvailable(default, null):Bool = false;
	#end

	/**
	 * Name of the current state's class.
	 */
	public static var stateClassName(get, never):String;
	private static function get_stateClassName():String return FlxStringUtil.getClassName(FlxG.state, true);

	/**
	 * Name of the current sub-state's class.
	 */
	public static var subStateClassName(get, never):String;
	private static function get_subStateClassName():String return FlxStringUtil.getClassName(FlxG.state.subState, true);

	public static var instance(default, null):openfl.display.Sprite;

	public function new() {
		violet.backend.CrashHandler.init();
		violet.backend.console.Logs.init();

		super();
		instance = this;

		haxe.ui.Toolkit.init();
		haxe.ui.Toolkit.theme = 'dark'; // don't be cringe
		haxe.ui.Toolkit.styleSheet.parse(".body, .label, .link, .textfield, .textarea { font-name: \"Inconsolata\"; font-size: 14px; font-bold: true; }");
		// Toolkit.theme = 'light'; // embrace cringe
		haxe.ui.Toolkit.autoScale = false;

		/* FlxG.signals.postStateSwitch.add(()->{
			@:privateAccess violet.backend.CrashHandler.notificationManager = null;//new haxe.ui.notifications.NotificationManager();
		}); */

		moonchart.Moonchart.DEFAULT_DIFF = 'normal';
		moonchart.Moonchart.CASE_SENSITIVE_DIFFS = moonchart.Moonchart.SPACE_SENSITIVE_DIFFS = false;
		Paths.init();
		Cache.init();
		#if EDIT_WINDOW_BORDER_COLOR
		hxwindowmode.WindowColorMode.setDarkMode();
		hxwindowmode.WindowColorMode.setWindowCornerType(1);
		hxwindowmode.WindowColorMode.redrawWindowHeader();
		#end

		violet.external.windows.WinAPI.setDarkMode(violet.external.windows.WinAPI.isSystemDarkMode());

		#if ALLOW_VIDEOS
		hxvlc.util.Handle.init();
		#end
		#if DISCORD_RICH_PRESENCE
		// write this
		#end

		engineVersion = lime.app.Application.current.meta.get('version');
		latestVersion = engineVersion;

		var startFPS:Int = Application.current.window.displayMode.refreshRate;
		addChild(new flixel.FlxGame(1280, 720, violet.states.InitialState, startFPS, startFPS, true));
		addChild(new DebugDisplay());
		FlxG.game.focusLostFramerate = 30;
		FlxG.mouse.useSystemCursor = true;
	}

	public static function switchState(targetClass:Dynamic) {
		if (targetClass is flixel.FlxState)
			FlxG.switchState(targetClass);
		FlxG.state.closeSubState();
		var redirects:Array<Dynamic> = ParseUtil.json("stateRedirects", "data/config");
		var className = FlxStringUtil.getClassName(targetClass, true);
		var switched = false;
		for (i in redirects) {
			if (i.state == className) {
				trace('debug:Redirecting State "$className" to "${FlxStringUtil.getClassName(new ClassData(i.target).target, true)}"');
				FlxG.switchState(new ClassData(i.target).target);
				switched = true;
			}
		}
		if (!switched)
			FlxG.switchState(targetClass);
	}
}