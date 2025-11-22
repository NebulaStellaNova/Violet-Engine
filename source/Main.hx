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
		violet.backend.console.Logs.init();

		super();

		moonchart.Moonchart.DEFAULT_DIFF = 'normal';
		moonchart.Moonchart.CASE_SENSITIVE_DIFFS = moonchart.Moonchart.SPACE_SENSITIVE_DIFFS = false;
		Paths.init();
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
		var fpsCounter:openfl.display.FPS = new openfl.display.FPS(10, 10, FlxColor.WHITE);
		fpsCounter.setTextFormat(new openfl.text.TextFormat(30));
		fpsCounter.width = FlxG.width;
		addChild(fpsCounter);
		FlxG.game.focusLostFramerate = 30;
		FlxG.mouse.useSystemCursor = true;
	}

	public static function switchState(targetClass:Dynamic) {
        if (targetClass is flixel.FlxState) {
            FlxG.switchState(targetClass);
        }
		FlxG.state.closeSubState();
        var redirects:Array<Dynamic> = violet.backend.utils.ParseUtil.json("stateRedirects", "data/config");
        var className = flixel.util.FlxStringUtil.getClassName(targetClass, true);
        var switched = false;
        for (i in redirects) {
            if (i.state == className) {
                trace('debug:Redirecting State "$className" to "${flixel.util.FlxStringUtil.getClassName(new violet.backend.objects.ClassData(i.target).target, true)}"');
                FlxG.switchState(new violet.backend.objects.ClassData(i.target).target);
                switched = true;
            }
        }
        if (!switched)
            FlxG.switchState(targetClass);

	}
}