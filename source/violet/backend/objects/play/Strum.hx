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

	public final splashes:Array<StrumElement> = [];
	public final holdCovers:Array<StrumElement> = [];
	public var holdCover:StrumElement;

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
			final partOffsets:Array<Float> = styleMeta.getHoldCoverOffsets();
			holdCover.setPosition(this.x - (holdCover.width/2) + partOffsets[0], this.y - (holdCover.height/2) + partOffsets[1]);
		}
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
		final splash:StrumElement = new StrumElement(this, styleMeta.getSplashAssetPath());
		for (data in styleMeta.getSplashAnimations(ID, parent.keyCount))
			splash.addAnimFromData(data);

		splash.playAnim(FlxG.random.getObject(splash.animationList), true);
		splash.setScale(styleMeta.splashProperties.scale);
		splash.animation.onFinish.add(name -> {
			this.splashes.remove(splash);
			splash.destroy();
		});
		final partOffsets:Array<Float> = styleMeta.getSplashOffsets();
		splash.setPosition(this.x - (splash.width/2) + partOffsets[0], this.y - (splash.height/2) + partOffsets[1]);
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
		final holdCover:StrumElement = holdCover = new StrumElement(this, styleMeta.getHoldCoverAssetPath());
		for (data in styleMeta.getHoldCoverAnimations(ID, parent.keyCount))
			holdCover.addAnimFromData(data);

		holdCover.playAnim('start', true);
		holdCover.setScale(styleMeta.holdCoverProperties.scale);
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
		final partOffsets:Array<Float> = styleMeta.getHoldCoverOffsets();
		holdCover.setPosition(this.x - (holdCover.width/2) + partOffsets[0], this.y - (holdCover.height/2) + partOffsets[1]);
		holdCover.antialiasing = styleMeta.isHoldCoverPixel();
		holdCover.alpha = styleMeta.holdCoverProperties.alpha;
		holdCover.blend = styleMeta.holdCoverProperties.blendMode;
		this.holdCovers.push(holdCover);
		this.parent.add(holdCover);
	}
}
