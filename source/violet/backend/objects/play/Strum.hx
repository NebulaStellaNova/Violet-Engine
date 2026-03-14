package violet.backend.objects.play;

import violet.backend.audio.Conductor;
import violet.data.notestyles.NoteStyle;
import violet.data.notestyles.NoteStyleRegistry;

class Strum extends NovaSprite {
	/**
	 * The parent strumline.
	 */
	public final parent:StrumLine;

	/**
	 * The style the strum will use.
	 */
	public var style(default, set):String;
	inline function set_style(value:String):String {
		if (style != value)
			reloadStyle(value);
		return style = value;
	}
	var styleMeta:NoteStyle;

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
	public final holdCovers:Array<NovaSprite> = [];
	public var holdCover:NovaSprite;

	public function new(parent:StrumLine, id:Int) {
		super();
		this.parent = parent;
		ID = id;
		style = null;
		this.styleMeta = NoteStyleRegistry.getNoteStyleByID(parent.noteStyle ?? 'default');

		final daScale:Float = styleMeta.strumProperties.scale;
		scale.set(daScale, daScale);
		scale.scale(parent.strumScale);
		updateHitbox();
	}

	public function reloadStyle(?style:String):Void {
		final lastAnim:String = animation?.name ?? 'static';
		final wasReversed:Bool = animation?.curAnim?.reversed ?? false;
		// final lastFrame:Array<Int> = [animation?.curAnim?.curFrame ?? 0, animation?.curAnim?.numFrames ?? 1];

		this.anims.clear();
		animation.destroyAnimations();
		final style:String = style ?? this.style ?? parent.noteStyle ?? 'default';
		this.styleMeta = NoteStyleRegistry.getNoteStyleByID(style);
		loadSprite(styleMeta.getStrumAssetPath());
		for (data in styleMeta.getStrumAnimations(ID, parent.keyCount))
			addAnimFromData(data);
		final partOffsets:Array<Float> = styleMeta.getStrumOffsets();
		globalOffset.set(partOffsets[0], partOffsets[1]);
		this.antialiasing = styleMeta.isStrumPixel();

		playAnim(lastAnim, true, wasReversed);
		// animation.curAnim.curFrame = Math.round(flixel.math.FlxMath.remapToRange(lastFrame[0], 0, lastFrame[1], 0, animation.curAnim.numFrames));
		final daScale:Float = styleMeta.strumProperties.scale;
		scale.set(daScale, daScale);
		scale.scale(parent.strumScale);
		updateHitbox(); alpha = styleMeta.strumProperties.alpha;
		blend = styleMeta.strumProperties.blendMode;
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
			holdCover.setPosition(this.x - (holdCover.width/2), parent.y - (holdCover.height/2));
			final partOffsets:Array<Float> = styleMeta.getHoldCoverOffsets();
			holdCover.x += partOffsets[0]; holdCover.y += partOffsets[1];
			holdCover.centerOrigin();
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
		final splash:NovaSprite = new NovaSprite(styleMeta.getSplashAssetPath());
		for (data in styleMeta.getSplashAnimations(ID, parent.keyCount))
			splash.addAnimFromData(data);

		splash.playAnim(FlxG.random.getObject(splash.animationList), true);
		final daScale:Float = styleMeta.splashProperties.scale;
		splash.scale.set(daScale, daScale);
		splash.scale.scale(parent.strumScale);
		splash.updateHitbox();
		splash.centerOffsets();
		splash.centerOrigin();
		splash.animation.onFinish.add(name -> {
			this.splashes.remove(splash);
			splash.destroy();
		});
		splash.x = this.x - (splash.width/2);
		final partOffsets:Array<Float> = styleMeta.getSplashOffsets();
		splash.x += partOffsets[0];
		if (parent.downscroll) {
			splash.y = FlxG.height - (parent.y + (splash.height/2));
			splash.y -= partOffsets[1];
		} else {
			splash.y = parent.y - (splash.height/2);
			splash.y += partOffsets[1];
		}
		splash.antialiasing = styleMeta.isSplashPixel();
		splash.alpha = styleMeta.splashProperties.alpha;
		splash.blend = styleMeta.splashProperties.blendMode;
		this.splashes.push(splash);
		this.parent.add(splash);
	}


	public function spawnHoldCover():Void {
		if (holdCover != null) {
			holdCover.playAnim('end', true);
			holdCover.animation.finish();
		}
		final holdCover:NovaSprite = holdCover = new NovaSprite(styleMeta.getHoldCoverAssetPath());
		for (data in styleMeta.getHoldCoverAnimations(ID, parent.keyCount))
			holdCover.addAnimFromData(data);

		holdCover.playAnim('start', true);
		final daScale:Float = styleMeta.holdCoverProperties.scale;
		holdCover.scale.set(daScale, daScale);
		holdCover.scale.scale(parent.strumScale);
		holdCover.updateHitbox();
		holdCover.centerOffsets();
		holdCover.centerOrigin();
		holdCover.animation.onFinish.add(name -> {
			switch (name) {
				case 'start':
					holdCover.playAnim('hold', true);
				case 'end':
					this.parent.remove(holdCover);
					this.holdCovers.remove(holdCover);
					holdCover.destroy();
			}
		});
		holdCover.antialiasing = styleMeta.isHoldCoverPixel();
		holdCover.alpha = styleMeta.holdCoverProperties.alpha;
		holdCover.blend = styleMeta.holdCoverProperties.blendMode;
		this.holdCovers.push(holdCover);
		this.parent.add(holdCover);
	}
}
