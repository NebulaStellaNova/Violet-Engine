package violet.states;

import violet.backend.StateBackend;

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

		new haxe.ui.notifications.NotificationManager().addNotification({title: 'a', body: ''});

		FlxG.signals.preUpdate.add(() -> {
			if (Controls.resetState) {
				ModdingAPI.reloadRegistries();
				FlxG.resetState();
			}
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