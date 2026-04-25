package violet.states;

import violet.backend.utils.WindowUtil;
import violet.backend.options.Options;
import flixel.util.FlxStringUtil;
import violet.backend.utils.ParseUtil;
import violet.backend.scripting.GlobalPack;
import lemonui.utils.MathUtil;
import violet.states.menus.OptionsMenu;
import violet.backend.StateBackend;
import violet.backend.audio.Conductor;
import openfl.system.Capabilities;
import violet.backend.objects.ClassData;

class InitialState extends StateBackend { // for now

	var logo:NovaSprite = new NovaSprite(Paths.image('icons/dad'));
	var loadingBar:NovaSprite;

	static var stateRedirects:Array<RedirectPiece> = [];

	public static var fullscreen:Bool = false;

	public static var defaultParams = {
		x: 0,
		y: 0,
		width: 0,
		height: 0
	}

	public static var loadingPercent:Float = 0;

	override public function create():Void {
		FlxG.fixedTimestep = false;
		FlxSprite.defaultAntialiasing = true; // this ain't a pixel game... yeah ik week 6 exists!
		FlxG.cameras.useBufferLocking = true;
		super.create();


		#if CHECK_FOR_UPDATES
		// write this
		#end

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();
		#if FLX_DEBUG
		// for later use
		#end

		FlxG.signals.postStateSwitch.add(()->{
			if (!Std.isOfType(FlxG.state, PlayState)) {
				PlayState.hasSeenCutscene = false;
				PlayState.hasSeenDialogue = false;
				PlayState.isStoryMode = false;
				@:bypassAccessor PlayState.practiceMode = false;
				PlayState.playlist.resize(0);
				PlayState.storyScore = 0;
				PlayState.curStoryLevel = null;
			}
		});

		FlxG.signals.preStateSwitch.add(()->{
			var nextStateID = FlxStringUtil.getClassName(Type.getClass(@:privateAccess FlxG.game._nextState.createInstance()), true);
			for (data in stateRedirects) {
				if (data.state == nextStateID) {
					@:privateAccess FlxG.game._nextState = new ClassData(data.target).target;
					break;
				}
			}
			var title:String = "Friday Night Funkin': Violet Engine";
			for (i in ModdingAPI.getActiveMods()) {
				if (i.windowTitle != null) {
					title = i.windowTitle;
				}
			}
			WindowUtil.title = title;
		});

		FlxG.signals.preUpdate.add(() -> {

			if (OptionsMenu.instance != null)
				if (!OptionsMenu.instance.canSelectMenu) return;

			if (Controls.fullscreen) {
				fullscreen = !fullscreen;
				if (fullscreen) {

					defaultParams.x = lime.app.Application.current.window.x;
					defaultParams.y = lime.app.Application.current.window.y;
					defaultParams.width = lime.app.Application.current.window.width;
					defaultParams.height = lime.app.Application.current.window.height;
					lime.app.Application.current.window.borderless = true;
					lime.app.Application.current.window.resize(Math.round(Capabilities.screenResolutionX), Math.round(Capabilities.screenResolutionY)+8);
					lime.app.Application.current.window.x = 0;
					lime.app.Application.current.window.y = -4;
				} else {
					lime.app.Application.current.window.borderless = false;
					lime.app.Application.current.window.resize(defaultParams.width, defaultParams.height);
					lime.app.Application.current.window.x = defaultParams.x;
					lime.app.Application.current.window.y = defaultParams.y;
				}
			}

			if (!Options.data.developerMode) return;

			if (FlxG.keys.justPressed.F2/* Controls.console // Doesn't work for some reason, crashes when I try to add setting for it. */) {
				#if windows
				violet.external.windows.WinAPI.allocConsole();
				trace('sys:Hello World!');
				#end
			}

			if (Controls.reloadGame) {
				Conductor.pause();
				FlxG.sound.music.stop();
				for (i in FlxG.sound.list.members) i.stop();
				ModdingAPI.reloadModList();
				ModdingAPI.reloadRegistries();
				ModdingAPI.checkForHXC();
				GlobalPack.init();
				refreshRedirects();
				resetState();
			}
			if (Controls.resetState) resetState();
			if (Controls.shortcutState)
				FlxG.switchState(() -> new violet.states.menus.MainMenu());
		});

		loadingBar = new NovaSprite().makeGraphic(FlxG.width * 0.9, 20);
		loadingBar.scale.x = 0;
		add(loadingBar);

		logo.screenCenter();
		logo.antialiasing = true;
		add(logo);

		FlxTimer.wait(0.05, ()->{
			#if MOD_SUPPORT
			ModdingAPI.init();
			refreshRedirects();
			#end
			GlobalPack.init();
		});
		// FlxG.camera.visible = false;
	}

	public function resetState() {
		if (Std.isOfType(FlxG.state, ModState)) {
			var state:ModState = cast FlxG.state;
			FlxG.switchState(new ModState(state.id, state.args));
		} else {
			FlxG.resetState();
		}
	}

	public static function refreshRedirects() {
		stateRedirects.resize(0);
		for (i in ModdingAPI.getActiveMods()) {
			var thisOne:Array<RedirectPiece> = ParseUtil.jsonOrYaml('${ModdingAPI.MOD_FOLDER}/${i.folder}/data/config/stateRedirects', 'root', 'null') ?? (cast []); // bs mane
			if (i.stateRedirects != null) thisOne = thisOne.concat(i.stateRedirects);
			stateRedirects = stateRedirects.concat(thisOne);
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		logo.angle++;


		loadingBar.scale.x = MathUtil.lerp(loadingBar.scale.x, loadingPercent, 0.1);
		loadingBar.updateHitbox();
		loadingBar.y = FlxG.height - loadingBar.height - 20;
		loadingBar.screenCenter(X);

		if (Math.round(loadingBar.scale.x*100)/100 == 1) {
			FlxG.switchState(SplashState.new);
			FlxG.camera.visible = true;
		}
	}

}