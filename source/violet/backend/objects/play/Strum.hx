package violet.backend.objects.play;

import violet.backend.audio.Conductor;
import violet.data.noteskin.NoteSkin;
import violet.data.noteskin.NoteSkinRegistry;

class Strum extends NovaSprite {
	/**
	 * The parent strumline.
	 */
	public final parent:StrumLine;

	/**
	 * The skin the strum will use.
	 */
	public var skin(default, set):String;
	inline function set_skin(value:String):String {
		if (skin != value)
			reloadSkin(value);
		return skin = value;
	}
	var skinMeta:NoteSkin;

	/**
	 * Used to help "glowLength".
	 */
	public var lastHit:Float = Math.NEGATIVE_INFINITY;
	/**
	 * The amount of time in steps the animation can be forced to last.
	 * If set to 0 the animation that is played plays out normally.
	 */
	public var glowLength:Float = 1.2;

	/**
	 * If true after the "glowlength" is reached the animation will go back to "static".
	 */
	public var willReset:Bool = false;

	public final splashes:Array<NovaSprite> = [];
	public var holdCover:NovaSprite;

	public function new(parent:StrumLine, id:Int) {
		super();
		this.parent = parent;
		ID = id;
		skin = 'default';
	}

	public function reloadSkin(?skin:String):Void {
		final lastAnim:String = animation?.name ?? 'static';
		final wasReversed:Bool = animation?.curAnim?.reversed ?? false;
		// final lastFrame:Array<Int> = [animation?.curAnim?.curFrame ?? 0, animation?.curAnim?.numFrames ?? 1];

		this.anims.clear();
		animation.destroyAnimations();
		final skin:String = skin ?? this.skin ?? 'default';
		this.skinMeta = NoteSkinRegistry.getNoteSkinByID(skin);
		loadSprite(skinMeta.getStrumAssetPath());
		for (data in skinMeta.getStrumAnimations(ID, parent.keyCount))
			addAnimFromData(data);
		var lol:Array<Float> = skinMeta.getStrumOffsets();
		globalOffset.set(lol[0], lol[1]);

		playAnim(lastAnim, true, wasReversed); updateHitbox();
		// animation.curAnim.curFrame = Math.round(flixel.math.FlxMath.remapToRange(lastFrame[0], 0, lastFrame[1], 0, animation.curAnim.numFrames));
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (willReset && animation?.name != 'static')
			if (glowLength > 0 ? (lastHit + (Conductor.stepLengthMs * glowLength) < Conductor.songPosition) : (animation.name == null || animation.finished)) {
				var targetAnim = parent.isComputer ? 'static' : 'press';
				if (animation.name != targetAnim) playStrumAnim(targetAnim, true);
			}

		if (holdCover == null) return;
		if (holdCover.exists && holdCover.animation.name != 'end') {
			holdCover.x = this.x - (holdCover.width/2);
			holdCover.y = this.y - (holdCover.height/2);
			holdCover.x += skinMeta.getHoldCoverOffsets()[0];
			holdCover.y += skinMeta.getHoldCoverOffsets()[1] * (parent.downscroll ? 0 : 1);
			if (parent.downscroll) holdCover.y = FlxG.height - holdCover.y - holdCover.height;
		}
	}

	override public function draw():Void {
		if (parent.downscroll) {
			final prevY:Float = y;
			y = FlxG.height - y - height;
			globalOffset.y *= -1;
			super.draw();
			globalOffset.y *= -1;
			y = prevY;
		} else super.draw();
	}

	public function playStrumAnim(name:String, reset:Bool = false, forced:Bool = true, reversed:Bool = false, frame:Int = 0):Void {
		if (this.animation.exists(name)) {
			playAnim(name, forced, reversed, frame);
			if (!this.anims.exists(name)) this.offset.set();
			centerOffsets();
			centerOrigin();
			if (reset) lastHit = Conductor.songPosition;
			willReset = reset;
		}
	}

	public function spawnSplash():Void {
		final splash:NovaSprite = new NovaSprite(skinMeta.getSplashAssetPath()); // cast parent.recycle(NovaSprite, () -> return new NovaSprite(skinMeta.getSplashAssetPath()));
		// if (splash.filePath != skinMeta.getSplashAssetPath())
		// 	splash.loadSprite(skinMeta.getSplashAssetPath()); // jic

		for (data in skinMeta.getSplashAnimations(ID, parent.keyCount))
			splash.addAnimFromData(data);
		// splash.visible = true;

		splash.playAnim(FlxG.random.getObject(splash.animationList), true);
		splash.centerOffsets();
		splash.centerOrigin();
		splash.animation.onFinish.add(name -> {
			this.splashes.remove(splash);
			// splash.visible = false;
			splash.destroy();
		});
		splash.x = this.x - (splash.width/2);
		splash.y = this.y - (splash.height/2);
		splash.x += skinMeta.getSplashOffsets()[0];
		splash.y += skinMeta.getSplashOffsets()[1] * (parent.downscroll ? 0 : 1);
		if (parent.downscroll) splash.y = FlxG.height - splash.y - splash.height;
		this.splashes.push(splash);
		this.parent.add(splash);
	}


	public function spawnHoldCover():Void {
		if (holdCover != null) {
			holdCover.playAnim('end', true);
			holdCover.animation.finish();
		}
		final holdCover:NovaSprite = holdCover = new NovaSprite(skinMeta.getHoldCoverAssetPath()); // cast parent.recycle(NovaSprite, () -> return new NovaSprite(skinMeta.getHoldCoverAssetPath()));
		// if (holdCover.filePath != skinMeta.getHoldCoverAssetPath())
		// 	holdCover.loadSprite(skinMeta.getHoldCoverAssetPath()); // jic

		for (data in skinMeta.getHoldCoverAnimations(ID, parent.keyCount))
			holdCover.addAnimFromData(data);
		// holdCover.visible = true;

		holdCover.playAnim('start', true);
		holdCover.animation.onFinish.add(name -> {
			switch (name) {
				case 'start':
					holdCover.playAnim('hold', true);
				case 'end':
					this.parent.remove(holdCover);
					// holdCover.visible = false;
					holdCover.destroy();
			}
		});
		holdCover.centerOffsets();
		holdCover.centerOrigin();
		this.parent.add(holdCover);
	}
}
