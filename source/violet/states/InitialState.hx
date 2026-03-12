package violet.states;

import violet.states.menus.OptionsMenu;
import violet.backend.StateBackend;
import violet.backend.audio.Conductor;

class InitialState extends StateBackend { // for now
	override public function create():Void {
		FlxG.fixedTimestep = false;
		FlxSprite.defaultAntialiasing = true; // this ain't a pixel game... yeah ik week 6 exists!
		FlxG.cameras.useBufferLocking = true;

		super.create();

		#if MOD_SUPPORT
		ModdingAPI.init();
		#end
		#if CHECK_FOR_UPDATES
		// write this
		#end

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();
		#if FLX_DEBUG
		// for later use
		#end

		var i:Int = 0;
		function attemptNotif():Void {
			try {
				new haxe.ui.notifications.NotificationManager().addNotification({title: 'a', body: ''});
			} catch(error:haxe.Exception) {
				if (i == 20) {
					trace('warning:Failed to initialize notification manager after 20 attempts, giving up.');
					return;
				}
				i++;
				attemptNotif();
			}
		}
		attemptNotif();

		FlxG.signals.preUpdate.add(() -> {
			if (OptionsMenu.instance != null)
				if (!OptionsMenu.instance.canSelectMenu) return;
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

		FlxG.camera.visible = false;
		new flixel.util.FlxTimer().start(0.05, (_)->{
			FlxG.switchState(SplashState.new);
			FlxG.camera.visible = true;
		});
	}
}