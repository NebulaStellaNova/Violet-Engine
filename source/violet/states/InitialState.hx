package violet.states;

class InitialState extends flixel.FlxState { // for now
	override public function create():Void {
		FlxG.fixedTimestep = false;
		flixel.FlxSprite.defaultAntialiasing = true; // this ain't a pixel game... yeah ik week 6 exists!
		FlxG.cameras.useBufferLocking = true;

		super.create();

		#if MOD_SUPPORT
		Modding.init();
		#end
		#if CHECK_FOR_UPDATES
		// write this
		#end

		FlxG.scaleMode = new flixel.system.scaleModes.RatioScaleMode();
		#if FLX_DEBUG
		// for later use
		#end

		FlxG.signals.preUpdate.add(() -> {
			if (FlxG.keys.justPressed.F5)
				FlxG.resetState();
			if (FlxG.keys.justPressed.F6)
				FlxG.switchState(() -> new violet.states.menus.MainMenu());
		});

		FlxG.switchState(() -> new TitleState());
	}
}