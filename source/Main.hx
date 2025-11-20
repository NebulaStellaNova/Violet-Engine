package;

import thx.semver.Version;

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

	public function new() {
		violet.backend.CrashHandler.init();

		super();

		moonchart.Moonchart.DEFAULT_DIFF = 'normal';
		moonchart.Moonchart.CASE_SENSITIVE_DIFFS = moonchart.Moonchart.SPACE_SENSITIVE_DIFFS = false;
		#if EDIT_WINDOW_BORDER_COLOR
		hxwindowmode.WindowColorMode.setDarkMode();
		hxwindowmode.WindowColorMode.setWindowCornerType(1);
		hxwindowmode.WindowColorMode.redrawWindowHeader();
		#end
		#if ALLOW_VIDEOS
		hxvlc.util.Handle.init();
		#end
		#if DISCORD_RICH_PRESENCE
		// write this
		#end

		engineVersion = lime.app.Application.current.meta.get('version');
		latestVersion = engineVersion;

		addChild(new flixel.FlxGame(1280, 720, violet.states.InitialState));
		addChild(new openfl.display.FPS(FlxColor.WHITE));
		FlxG.game.focusLostFramerate = 30;
		FlxG.mouse.useSystemCursor = true;
	}
}