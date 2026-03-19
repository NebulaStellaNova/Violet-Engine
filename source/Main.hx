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


		lemonui.Constants.FONT_REGULAR = Paths.font('Inconsolata-Medium.ttf');
		lemonui.Constants.FONT_BOLD = Paths.font('Inconsolata-Bold.ttf');

		// violet.boot.HaxeUIHelper.init();

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

		#if windows
		violet.external.windows.WinAPI.setDarkMode(violet.external.windows.WinAPI.isSystemDarkMode());
		#end

		#if ALLOW_VIDEOS
		hxvlc.util.Handle.init();
		#end
		#if DISCORD_RICH_PRESENCE
		DiscordRPC.init();
		#end

		@:privateAccess {
			Constants.ENGINE_VERSION = lime.app.Application.current.meta.get('version');
			#if CHECK_FOR_UPDATES
			Constants.LATEST_ENGINE_VERSION = lime.app.Application.current.meta.get('version');
			Constants.UPDATE_AVAILABLE = false;
			#end
		}

		Options.init();

		hxhardware.CPU.init();

		var startFPS:Int = Application.current.window.displayMode.refreshRate;
		new flixel.FlxGame(1280, 720, violet.states.InitialState, startFPS, startFPS, true);
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
	}

	public static function switchState(targetClass:Dynamic) {
		if (targetClass is flixel.FlxState)
			FlxG.switchState(targetClass);
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