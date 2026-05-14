package violet.states;

import violet.backend.filesystem.HXCHandler;
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
import violet.backend.console.Logs;

class LoadingState extends StateBackend { // for now

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
	public static var loadingText:String = "";
	public var loadingTxt:NovaText;
	public var loadingPercentTxt:NovaText;
	public var traceTxt:NovaText;

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
				PlayState.storyScoreDiscarded = false;
				PlayState.curStoryLevel = null;
			}
		});

		FlxG.signals.preStateSwitch.add(()->{
			var nextStateID = FlxStringUtil.getClassName(Type.getClass(@:privateAccess FlxG.game._nextState.createInstance()), true);
			for (data in stateRedirects) {
				if (data.state == nextStateID) {
					@:privateAccess FlxG.game._nextState = new ModState(data.target);
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
				reloadEverything();
				resetState();
			}
			if (Controls.resetState) resetState();
			if (Controls.shortcutState)
				FlxG.switchState(() -> new violet.states.menus.MainMenu());
		});

		traceTxt = new NovaText(100, 50, 0, "", Paths.font('vcr.ttf'));
		traceTxt.size = 35;
		traceTxt.alpha = 0.5;
		add(traceTxt);

		Logs.onTrace.add(tracey);

		loadingBar = new NovaSprite().makeGraphic(FlxG.width - 200, 20);
		loadingBar.scale.x = 0;
		add(loadingBar);

		loadingTxt = new NovaText(0, 0, 0, "Initializing...", Paths.font('vcr.ttf'));
		loadingTxt.size = 50;
		add(loadingTxt);

		loadingPercentTxt = new NovaText(0, 0, 0, "", Paths.font('vcr.ttf'));
		loadingPercentTxt.size = 50;
		add(loadingPercentTxt);

		FlxTimer.wait(0.05, ()->{
			#if MOD_SUPPORT
			ModdingAPI.init();
			refreshRedirects();
			#end
			GlobalPack.init();
		});

		var it = null;
		it = ()->{
			try {
				ModdingAPI.reloadModList();
				@:bypassAccessor ModdingAPI.activeModsIds = FlxG.save.data.enabledModIds;
				new HXCHandler();
				ModdingAPI.reloadRegistries();
				ModdingAPI.checkForHXC();
				GlobalPack.init();
				refreshRedirects();
			} catch (e:Dynamic) {
				trace(e);
			}
			Main.threadCallacks.remove(it);
		}
		Main.threadCallacks.addOnce(it);
		// FlxG.camera.visible = false;
	}

	var textArray = [];
	public function tracey(v:String) {
		if (v.startsWith('Registering')) return;
		textArray.push(v);
	}

	public static function reloadEverything() {
		ModdingAPI.reloadModList();
		ModdingAPI.reloadRegistries();
		ModdingAPI.checkForHXC();
		GlobalPack.init();
		refreshRedirects();
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
			if (i.stateRedirects != null) {
				for (field in i.stateRedirects.keys()) {
					stateRedirects.push({
						state: field,
						target: i.stateRedirects.get(field)
					});
				}
			}
		}
	}

	var lerpedNum:Float = 0;
	var ran = false;

	override function update(elapsed:Float) {
		super.update(elapsed);

		lerpedNum = lerp(lerpedNum, loadingPercent, 0.1);

		loadingBar.scale.x = MathUtil.lerp(loadingBar.scale.x, loadingPercent, 0.1);
		loadingBar.updateHitbox();
		loadingBar.x = 100;
		loadingBar.y = FlxG.height - loadingBar.height - 50;

		loadingPercentTxt.text = '${Math.round(lerpedNum*100)}%';
		loadingPercentTxt.updateHitbox();
		loadingPercentTxt.y = loadingBar.y -  loadingBar.height - 20;
		loadingPercentTxt.x = (FlxG.width - 100) - loadingPercentTxt.width;

		loadingTxt.text = loadingText;
		loadingTxt.updateHitbox();
		loadingTxt.y = loadingBar.y -  loadingBar.height - 20;
		loadingTxt.x = loadingBar.x;


		while (textArray.length > 34 && textArray.length != 0) textArray.shift();
		traceTxt.text = textArray.join('\n');
		traceTxt.updateHitbox();

		if (Math.round(loadingBar.scale.x*100)/100 == 1 && !ran) {
			ran = true;
			Logs.onTrace.remove(tracey);
			FlxG.camera.fade(()->{
				FlxTimer.wait(0.2, ()->{
					FlxG.switchState(SplashState.new);
					FlxG.camera.visible = true;
				});
			});
		}
	}

}
