package violet.states;

import lemonui.utils.MathUtil;
import violet.states.menus.OptionsMenu;
import violet.backend.StateBackend;
import violet.backend.audio.Conductor;
import openfl.system.Capabilities;

class InitialState extends StateBackend { // for now

	var logo:NovaSprite = new NovaSprite(Paths.image("icons/dad"));
	var loadingBar:NovaSprite;

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

		defaultParams.x = lime.app.Application.current.window.x;
		defaultParams.y = lime.app.Application.current.window.y;
		defaultParams.width = lime.app.Application.current.window.width;
		defaultParams.height = lime.app.Application.current.window.height;

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
				PlayState.isStoryMode = false;
				PlayState.playlist = [];
			}
		});

		FlxG.signals.preUpdate.add(() -> {

			if (OptionsMenu.instance != null)
				if (!OptionsMenu.instance.canSelectMenu) return;

			if (Controls.fullscreen) {
				fullscreen = !fullscreen;
				if (fullscreen) {
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

			if (Controls.reloadGame) {
				Conductor.pause();
				ModdingAPI.reloadRegistries();
				FlxG.resetState();
			}
			if (Controls.resetState)
				FlxG.resetState();
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
			#end
		});
		// FlxG.camera.visible = false;
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