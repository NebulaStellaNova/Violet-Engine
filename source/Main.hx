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

typedef StupidSignalMember<T> = {
    var callback:T;
    var removeAfterCall:Bool;
}

class StupidSignal<T:haxe.Constraints.Function> {
    final members:Array<StupidSignalMember<T>> = [];
    public var dispatch:T;
    public var intervalCallback:Void->Void;

    public function new() {
        dispatch = cast Reflect.makeVarArgs(function(args:Array<Dynamic>) {
            var _members = members.copy();

            for (member in _members) {
                Reflect.callMethod(null, member.callback, args);

                if (member.removeAfterCall) {
                    members.remove(member);
                }
                if (intervalCallback != null) {
                    intervalCallback();
                }
            }
        });
    }

    public function add(callback:T):Void {
        for (member in members) if (Reflect.compareMethods(member.callback, callback)) return;
        members.push({callback: callback, removeAfterCall: false});
    }

    public function addOnce(callback:T):Void {
        for (member in members) if (Reflect.compareMethods(member.callback, callback)) return;
        members.push({callback: callback, removeAfterCall: true});
    }

    public function remove(callback:T):Void {
        var i = members.length;
        while (i-- > 0) {
            if (Reflect.compareMethods(members[i].callback, callback)) {
                members.splice(i, 1);
            }
        }
    }
}

class Main extends openfl.display.Sprite {

	public static var threadCallacks:StupidSignal<Void->Void> = new StupidSignal<Void->Void>();

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
		new flixel.FlxGame(gameWidth, gameHeight, violet.states.LoadingState, startFPS, startFPS, true);
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
					threadCallacks.dispatch();
					Sys.sleep(FlxG.elapsed);
				} catch(error:haxe.Exception)
					trace('debug:Error in thread callback: $error');
			}
		});

		Application.current.onExit.add(_ -> ModdingAPI.powerDown());

		#if windows
		violet.external.windows.WinAPI.setDarkMode(violet.external.windows.WinAPI.isSystemDarkMode());
		#end

		FlxG.mouse.visible = false;
	}

}