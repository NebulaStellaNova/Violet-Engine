package;

import flixel.FlxState;
import flixel.util.FlxStringUtil;
import lime.app.Application;
import thx.semver.Version;
import violet.backend.display.DebugDisplay;
import violet.backend.options.Options;
import violet.backend.utils.ParseUtil;
import violet.boot.DiscordRPC;
import violet.data.Constants;
import hxvlc.flixel.FlxVideoSprite;

typedef StupidSignalMember = {
	var callback:Void->Void;
	var removeAfterCall:Bool;
}

class StupidSignal {

	final members:Array<StupidSignalMember> = [];

	public function new() {}

	public function add(callback:Void->Void):Void {
		for (member in members) if (member.callback == callback) return;
		members.push({callback: callback, removeAfterCall: false});
	}
	public function addOnce(callback:Void->Void):Void {
		for (member in members) if (member.callback == callback) return;
		members.push({callback: callback, removeAfterCall: true});
	}

	public function remove(callback:Void->Void):Void {
		final _members = members.copy();
		for (member in _members) {
			if (member.callback == callback)
				members.remove(member);
		}
		_members.resize(0);
	}

	public function dispatch(?intervalCallback:Void->Void):Void {
		for (member in members) {
			member.callback();
			if (member.removeAfterCall)
				members.remove(member);
			if (intervalCallback != null)
				intervalCallback();
		}
	}

}

class Main extends openfl.display.Sprite {

	public static var threadCallacks:StupidSignal = new StupidSignal();

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

		lemonui.themes.ThemeManager.currentTheme = lemonui.themes.Theme.DarkTheme.instance;
		lemonui.themes.ThemeManager.currentTheme.styles.fontRegular = Paths.font('Inconsolata-Medium.ttf');
		lemonui.themes.ThemeManager.currentTheme.styles.fontBold = Paths.font('Inconsolata-Bold.ttf');

		moonchart.Moonchart.DEFAULT_DIFF = 'normal';
		moonchart.Moonchart.CASE_SENSITIVE_DIFFS = moonchart.Moonchart.SPACE_SENSITIVE_DIFFS = false;
		Paths.init();
		Cache.init();
		#if EDIT_WINDOW_BORDER_COLOR
		hxwindowmode.WindowColorMode.setDarkMode();
		hxwindowmode.WindowColorMode.setWindowCornerType(1);
		hxwindowmode.WindowColorMode.redrawWindowHeader();
		#end

		#if ALLOW_VIDEOS
		hxvlc.util.Handle.init();
		#end
		#if DISCORD_RICH_PRESENCE
		DiscordRPC.init();
		#end

		@:privateAccess {
			Constants.ENGINE_VERSION = Application.current.meta.get('version');
			#if CHECK_FOR_UPDATES
			Constants.LATEST_ENGINE_VERSION = Constants.ENGINE_VERSION;
			Constants.UPDATE_AVAILABLE = Constants.LATEST_ENGINE_VERSION > Constants.ENGINE_VERSION;
			#end
		}

		Options.init();

		hxhardware.CPU.init();


		var gameWidth = 1280; // Mobile Width = 1600;
		var gameHeight = 720;

		var startFPS:Int = Options.data.vsync ? #if !linux Application.current.window.displayMode.refreshRate #else 60 #end : Std.int(Options.data.fps);
		new flixel.FlxGame(gameWidth, gameHeight, violet.states.InitialState, startFPS, startFPS, true);
		FlxG.sound.volume = FlxG.save.data.volume ?? 0.4;
		@:privateAccess FlxG.game._customSoundTray = violet.backend.display.VioletSoundTray;
		addChild(FlxG.game);
		addChild(new DebugDisplay());
		FlxG.game.focusLostFramerate = 30;
		FlxG.mouse.useSystemCursor = true;

		#if FLX_DEBUG
		// literally just cause nebs pause bind is backslash
		FlxG.debugger.toggleKeys.remove(BACKSLASH);
		#end

		sys.thread.Thread.create(() -> {
			while (true) {
				try {
					threadCallacks.dispatch(() -> Sys.sleep(FlxG.elapsed));
				} catch(error:haxe.Exception)
					trace('debug:Error in thread callback: $error');
			}
		});

		Application.current.onExit.add(_ -> ModdingAPI.powerDown());

		#if windows
		violet.external.windows.WinAPI.setDarkMode(violet.external.windows.WinAPI.isSystemDarkMode());
		#end
	}
}